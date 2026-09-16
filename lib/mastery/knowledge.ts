import { getAdminClient } from "@/lib/supabase/admin";

/**
 * Calculates the authoritative knowledge score for a specific skill.
 * 
 * Evidence sources:
 * 1. Lesson completion percentage
 * 2. Best quiz score
 * 
 * Repeated attempts do not erase previous high marks. 
 * A failed quiz does not ruin a strong lesson completion score, but it won't boost it.
 * 
 * @param userId - The user ID
 * @param skillId - The skill ID
 * @returns A number between 0 and 100 representing the knowledge score
 */
export async function calculateKnowledgeEvidence(userId: string, skillId: string): Promise<number> {
  const admin = getAdminClient();

  // 1. Calculate Lesson Evidence
  const { data: lessons } = await admin
    .from("lessons")
    .select("id")
    .eq("skill_id", skillId)
    .eq("is_published", true);

  const totalLessons = lessons?.length ?? 0;
  let lessonScore: number | null = null;

  if (totalLessons > 0) {
    const lessonIds = lessons!.map(l => l.id);
    const { count: completedCount } = await admin
      .from("user_lesson_progress")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userId)
      .in("lesson_id", lessonIds)
      .eq("status", "completed");

    lessonScore = Math.min(Math.round(((completedCount ?? 0) / totalLessons) * 100), 100);
  }

  // 2. Calculate Quiz Evidence
  const { data: bestQuiz } = await admin
    .from("quiz_attempts")
    .select("score")
    .eq("user_id", userId)
    .eq("skill_id", skillId)
    .order("score", { ascending: false })
    .limit(1)
    .maybeSingle();

  const quizScore: number | null = bestQuiz ? Number(bestQuiz.score) : null;

  // 3. Combine Evidence
  if (lessonScore !== null && quizScore !== null) {
    return Math.round((lessonScore + quizScore) / 2);
  } else if (lessonScore !== null) {
    return lessonScore;
  } else if (quizScore !== null) {
    return quizScore;
  }

  return 0;
}