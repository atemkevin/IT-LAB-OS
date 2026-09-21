/**
 * lib/learning/missions.ts
 *
 * Daily mission generation engine.
 * Server-only. Uses admin client for writes (daily_missions has no INSERT RLS policy — intentional).
 */
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { todayString } from "@/lib/utils";
import type { DailyMission, MissionTaskProgress, UserSkillProgress } from "@/lib/database.types";

export interface MissionTask {
  key: string;
  title: string;
  description: string;
  type: "lesson" | "practice" | "quiz" | "troubleshooting";
  ref_id?: string;
  skill_slug?: string;
}

export interface MissionData {
  id: string;
  missionDate: string;
  durationMinutes: number;
  title: string;
  objective: string;
  context: string;
  tasks: MissionTask[];
  hints: string[];
  successCriteria: string[];
  recommendationReason: string;
  status: string;
}

/**
 * Get today's mission for a user. If none exists, generate one.
 * Idempotent — checks for existing mission first.
 */
export async function getTodayMission(userId: string): Promise<MissionData | null> {
  const supabase = await createClient();
  const today = todayString();

  // Check if today's mission already exists
  const { data: existing } = await supabase
    .from("daily_missions")
    .select("*")
    .eq("user_id", userId)
    .eq("mission_date", today)
    .maybeSingle();

  if (existing) {
    return mapMissionData(existing as DailyMission);
  }

  // No mission for today — generate one
  return generateDailyMission(userId);
}

/**
 * Get today's mission with task progress.
 */
export async function getTodayMissionWithProgress(
  userId: string,
): Promise<{ mission: MissionData | null; taskProgress: MissionTaskProgress[] }> {
  const supabase = await createClient();

  const mission = await getTodayMission(userId);

  if (!mission) {
    return { mission: null, taskProgress: [] };
  }

  const { data: progressRows } = await supabase
    .from("mission_task_progress")
    .select("*")
    .eq("user_id", userId)
    .eq("mission_id", mission.id);

  return {
    mission,
    taskProgress: (progressRows ?? []) as MissionTaskProgress[],
  };
}

/**
 * Pure function to build mission tasks from skill context.
 * Exported for unit testing without Supabase mocking.
 */
export function buildMissionTasks(
  skillName: string,
  skillDescription: string | null,
  skillMasteryScore: number,
  skillMasteryState: string | undefined,
  knowledgeScore: number,
  practiceScore: number,
  lessons: { id: string; title: string }[],
  practiceTasks: { id: string; title: string }[],
  skillSlug?: string,
): MissionTask[] {
  const tasks: MissionTask[] = [];

  if (lessons.length > 0) {
    const lessonIndex = knowledgeScore < 50 ? 0 : Math.min(Math.floor(knowledgeScore / 50), lessons.length - 1);
    const lesson = lessons[lessonIndex];
    tasks.push({
      key: "review-lesson",
      title: `Review: ${lesson.title}`,
      description: `Study the lesson "${lesson.title}" to strengthen your understanding of ${skillName}.`,
      type: "lesson",
      ref_id: lesson.id,
      skill_slug: skillSlug,
    });
  }

  if (practiceTasks.length > 0 && practiceScore < 70) {
    const task = practiceTasks[0];
    tasks.push({
      key: "practice-task",
      title: `Practice: ${task.title}`,
      description: `Complete the hands-on practice task "${task.title}" to apply what you've learned.`,
      type: "practice",
      ref_id: task.id,
      skill_slug: skillSlug,
    });
  }

  if (skillMasteryState !== "strong") {
    tasks.push({
      key: "take-quiz",
      title: `Test: ${skillName} Quiz`,
      description: `Take the quiz for ${skillName} to validate your knowledge.`,
      type: "quiz",
      skill_slug: skillSlug,
    });
  }

  if (tasks.length === 0) {
    tasks.push({
      key: "explore-skill",
      title: `Explore: ${skillName}`,
      description: `Start learning ${skillName} by reading the skill overview and first lesson.`,
      type: "lesson",
      skill_slug: skillSlug,
    });
  }

  return tasks;
}

/**
 * Generate a daily mission based on the user's weakest skills.
 * Uses admin client to INSERT (no RLS INSERT policy on daily_missions).
 */
export async function generateDailyMission(userId: string): Promise<MissionData | null> {
  const admin = getAdminClient();
  const today = todayString();

  // Fetch user's skill progress (all skills they've started)
  const { data: progressRows } = await admin
    .from("user_skill_progress")
    .select("skill_id, mastery_score, mastery_state, knowledge_score, practice_score")
    .eq("user_id", userId);

  // Also fetch all published skills for fallback
  const { data: allSkills } = await admin
    .from("skills")
    .select("id, slug, name, description, difficulty, estimated_minutes")
    .eq("is_published", true)
    .order("sort_order");

  if (!allSkills || allSkills.length === 0) return null;

  // 1. Check for any skills due for Spaced Repetition (SM-2) review
  const { getDueSkillReviews } = await import("@/lib/spaced-repetition/service");
  const dueReviews = await getDueSkillReviews(userId, 1);
  let isSpacedRepetition = false;
  let retentionReason = "";

  // Determine target skill
  let targetSkill: { id: string; slug: string; name: string; description: string | null; difficulty: string; estimated_minutes: number };

  const progress = (progressRows ?? []) as Pick<
    UserSkillProgress,
    "skill_id" | "mastery_score" | "mastery_state" | "knowledge_score" | "practice_score"
  >[];

  if (dueReviews.length > 0) {
    const due = dueReviews[0];
    const skill = allSkills.find((s) => s.id === due.skillId);
    if (skill) {
      targetSkill = skill;
      isSpacedRepetition = true;
      retentionReason = `Spaced Repetition Review: Your retention for ${skill.name} has decayed to ${due.currentRetention}%. Completing this mission resets decay and consolidates long-term memory.`;
    } else {
      targetSkill = allSkills[0];
    }
  } else if (progress.length > 0) {
    // Sort by mastery score ascending — weakest first
    const sorted = [...progress].sort((a, b) => (a.mastery_score ?? 0) - (b.mastery_score ?? 0));
    const weakestId = sorted[0].skill_id;
    const skill = allSkills.find((s) => s.id === weakestId);
    if (skill) {
      targetSkill = skill;
    } else {
      // Fallback to first skill
      targetSkill = allSkills[0];
    }
  } else {
    // New user — recommend the first (easiest) skill
    targetSkill = allSkills[0];
  }

  // Fetch lessons for the target skill
  const { data: lessons } = await admin
    .from("lessons")
    .select("id, slug, title, skill_id")
    .eq("skill_id", targetSkill.id)
    .eq("is_published", true)
    .order("sort_order")
    .limit(3);

  // Fetch practice tasks for the target skill
  const { data: practiceTasks } = await admin
    .from("practice_tasks")
    .select("id, title, skill_id")
    .eq("skill_id", targetSkill.id)
    .eq("is_published", true)
    .limit(2);

  // Build mission tasks using the pure function
  const skillProgress = progress.find((p) => p.skill_id === targetSkill.id);
  const tasks = buildMissionTasks(
    targetSkill.name,
    targetSkill.description,
    skillProgress?.mastery_score ?? 0,
    skillProgress?.mastery_state,
    skillProgress?.knowledge_score ?? 0,
    skillProgress?.practice_score ?? 0,
    (lessons ?? []).map((l: { id: string; title: string }) => ({ id: l.id, title: l.title })),
    (practiceTasks ?? []).map((p: { id: string; title: string }) => ({ id: p.id, title: p.title })),
    targetSkill.slug,
  );

  const missionTitle = isSpacedRepetition
    ? `Memory Retention: ${targetSkill.name}`
    : `${targetSkill.name} Focus Session`;
  const objective = isSpacedRepetition
    ? `Strengthen and lock in your memory retention for ${targetSkill.name} using spaced repetition.`
    : `Strengthen your mastery of ${targetSkill.name} through targeted study and practice.`;
  const context = targetSkill.description
    ? `${targetSkill.name}: ${targetSkill.description}`
    : `Focus on ${targetSkill.name}.`;

  const hints = [
    `Break the session into ${tasks.length} short segments.`,
    "Take notes as you go — active recall improves retention.",
    "Don't skip the quiz — it validates your understanding.",
  ];

  const successCriteria = tasks.map((t, i) => `Task ${i + 1}: Complete "${t.title}"`);

  const recommendationReason = isSpacedRepetition
    ? retentionReason
    : progress.length > 0
    ? `${targetSkill.name} is your lowest-scoring skill at ${skillProgress?.mastery_score ?? 0}% mastery. Focus here for maximum growth.`
    : `You're just starting out. ${targetSkill.name} is the recommended first skill for your learning path.`;

  const durationMinutes = Math.min(tasks.length * 10 + 10, 60);

  // Insert using admin client (no RLS INSERT policy on daily_missions)
  const { data: mission, error } = await admin
    .from("daily_missions")
    .insert({
      user_id: userId,
      mission_date: today,
      duration_minutes: durationMinutes,
      title: missionTitle,
      objective,
      context,
      tasks: tasks as unknown as import("@/lib/database.types").Json,
      hints: hints as unknown as import("@/lib/database.types").Json,
      success_criteria: successCriteria as unknown as import("@/lib/database.types").Json,
      recommendation_reason: recommendationReason,
      status: "not_started",
    })
    .select("*")
    .single();

  if (error) {
    console.error("[mission-generate]", error);
    return null;
  }

  return mapMissionData(mission as DailyMission);
}

/**
 * Map a database DailyMission row to the MissionData interface.
 */
function mapMissionData(row: DailyMission): MissionData {
  return {
    id: row.id,
    missionDate: row.mission_date,
    durationMinutes: row.duration_minutes,
    title: row.title,
    objective: row.objective ?? "",
    context: row.context ?? "",
    tasks: Array.isArray(row.tasks) ? (row.tasks as unknown as MissionTask[]) : [],
    hints: Array.isArray(row.hints) ? (row.hints as unknown as string[]) : [],
    successCriteria: Array.isArray(row.success_criteria)
      ? (row.success_criteria as unknown as string[])
      : [],
    recommendationReason: row.recommendation_reason ?? "",
    status: row.status,
  };
}
