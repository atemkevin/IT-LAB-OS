/**
 * lib/learning/quizzes.ts
 *
 * Quiz fetching (client-safe) and server-side grading.
 * Server-only.
 */
import { getAdminClient } from "@/lib/supabase/admin";
import type { QuizQuestion, QuizOption } from "@/lib/database.types";
import type { SafeQuizQuestion, QuizResult, QuizQuestionResult } from "./types";

/**
 * Fetch quiz questions for a skill WITHOUT is_correct (client-safe).
 * Uses admin client to query quiz_options (no learner RLS on that table).
 * Strips is_correct before returning.
 */
export async function getSafeQuizQuestions(skillId: string): Promise<SafeQuizQuestion[]> {
  const admin = getAdminClient();

  const { data: questions, error } = await admin
    .from("quiz_questions")
    .select("*")
    .eq("skill_id", skillId)
    .eq("is_published", true)
    .order("sort_order");

  if (error || !questions?.length) return [];

  const questionIds = questions.map((q: QuizQuestion) => q.id);

  const { data: options } = await admin
    .from("quiz_options")
    .select("id, question_id, option_text, sort_order")
    .in("question_id", questionIds)
    .order("sort_order");

  type OptionRow = { id: string; question_id: string; option_text: string; sort_order: number };
  const optionsByQuestion = new Map<string, OptionRow[]>();
  for (const opt of (options ?? []) as OptionRow[]) {
    const list = optionsByQuestion.get(opt.question_id) ?? [];
    list.push(opt);
    optionsByQuestion.set(opt.question_id, list);
  }

  return questions.map((q: QuizQuestion) => ({
    id: q.id,
    prompt: q.prompt,
    questionType: q.question_type as "single" | "multi" | "scenario",
    explanation: q.explanation,
    sortOrder: q.sort_order,
    options: (optionsByQuestion.get(q.id) ?? []).map((o: OptionRow) => ({
      id: o.id,
      optionText: o.option_text,
      sortOrder: o.sort_order,
    })),
  }));
}

/**
 * Grade a quiz submission server-side.
 * Fetches correct answers from DB using admin client (is_correct never sent to client).
 * Saves quiz_attempt and mastery_evidence.
 *
 * @param skillId - the skill being quizzed
 * @param userId - authenticated user
 * @param answers - map of question_id to selected option_id(s)
 */
export async function gradeQuiz(
  skillId: string,
  userId: string,
  answers: Record<string, string[]>
): Promise<QuizResult> {
  const admin = getAdminClient();

  const questionIds = Object.keys(answers);

  // Fetch questions
  const { data: questions } = await admin
    .from("quiz_questions")
    .select("*")
    .in("id", questionIds);

  // Fetch options WITH is_correct (admin only)
  const { data: options } = await admin
    .from("quiz_options")
    .select("*")
    .in("question_id", questionIds);

  if (!questions?.length || !options) {
    throw new Error("Quiz data not found");
  }

  // Build correct answer map: question_id -> Set of correct option_ids
  const correctMap = new Map<string, Set<string>>();
  for (const opt of options) {
    if (opt.is_correct) {
      const set = correctMap.get(opt.question_id) ?? new Set<string>();
      set.add(opt.id);
      correctMap.set(opt.question_id, set);
    }
  }

  // Grade each question
  const results: QuizQuestionResult[] = questions.map((q: QuizQuestion) => {
    const selected = new Set(answers[q.id] ?? []);
    const correct = correctMap.get(q.id) ?? new Set<string>();

    // For single: correct if selected set == correct set
    // For multi: all correct options selected and no wrong ones
    const isCorrect =
      selected.size === correct.size &&
      [...selected].every((id) => correct.has(id));

    return {
      questionId: q.id,
      prompt: q.prompt,
      isCorrect,
      explanation: q.explanation,
      selectedOptionIds: answers[q.id] ?? [],
      correctOptionIds: [...correct],
    };
  });

  const correctCount = results.filter((r) => r.isCorrect).length;
  const questionCount = results.length;
  const score = questionCount > 0 ? Math.round((correctCount / questionCount) * 100) : 0;
  const passed = score >= 70;

  // Save quiz attempt
  await admin.from("quiz_attempts").insert({
    user_id: userId,
    skill_id: skillId,
    answers: answers,
    score,
    correct_count: correctCount,
    question_count: questionCount,
  });

  // Create mastery evidence if passed
  let masteryEvidenceCreated = false;
  if (passed) {
    await admin.from("mastery_evidence").insert({
      user_id: userId,
      skill_id: skillId,
      evidence_type: "quiz",
      score,
      metadata: { correct_count: correctCount, question_count: questionCount },
    });
    masteryEvidenceCreated = true;
  }

  return {
    score,
    correctCount,
    questionCount,
    passed,
    results,
    masteryEvidenceCreated,
  };
}
