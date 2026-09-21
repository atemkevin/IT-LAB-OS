/**
 * lib/spaced-repetition/service.ts
 *
 * Backend service managing spaced repetition schedules, database sync,
 * and skill mastery integration.
 */
import { getAdminClient } from "@/lib/supabase/admin";
import {
  calculateSM2,
  calculateDecayedRetention,
  scoreToSM2Grade,
  type SM2ReviewResult,
} from "./sm2";
import { upsertSkillProgress } from "@/lib/learning/progress";

export interface DueReviewItem {
  id: string;
  skillId: string;
  skillSlug: string;
  skillName: string;
  skillDescription: string | null;
  difficulty: string;
  repetitionCount: number;
  intervalDays: number;
  easinessFactor: number;
  currentRetention: number;
  nextReviewDue: string;
  isOverdue: boolean;
}

/**
 * Records a review event for a given user and skill.
 * Automatically computes SM-2 progression, updates the database, and
 * recalculates overall skill mastery retention dimension.
 *
 * @param userId - Target learner ID
 * @param skillId - Target skill ID
 * @param gradeOrScore - Either an explicit grade (0-5) or a percentage score (0-100)
 * @param isPercentage - True if gradeOrScore is a percentage score 0-100
 */
export async function recordSkillReview(
  userId: string,
  skillId: string,
  gradeOrScore: number,
  isPercentage: boolean = false
): Promise<SM2ReviewResult> {
  const admin = getAdminClient();
  const grade = isPercentage ? scoreToSM2Grade(gradeOrScore) : gradeOrScore;

  // 1. Fetch existing spaced repetition record or use defaults
  const { data: existing } = await admin
    .from("spaced_repetition_items")
    .select("*")
    .eq("user_id", userId)
    .eq("skill_id", skillId)
    .maybeSingle();

  const currentState = {
    repetitionCount: existing?.repetition_count ?? 0,
    intervalDays: existing?.interval_days ?? 1,
    easinessFactor: existing?.easiness_factor ? Number(existing.easiness_factor) : 2.5,
  };

  // 2. Calculate next state using SM-2
  const now = new Date();
  const sm2Result = calculateSM2(currentState, grade, now);

  // 3. Prepare review history log
  const existingHistory = Array.isArray(existing?.history) ? existing.history : [];
  const updatedHistory = [
    ...existingHistory,
    {
      reviewed_at: now.toISOString(),
      grade: sm2Result.grade,
      interval_days: sm2Result.intervalDays,
      easiness_factor: sm2Result.easinessFactor,
      retention_score: sm2Result.retentionScore,
    },
  ];

  // 4. Upsert into spaced_repetition_items
  await admin.from("spaced_repetition_items").upsert(
    {
      user_id: userId,
      skill_id: skillId,
      repetition_count: sm2Result.repetitionCount,
      interval_days: sm2Result.intervalDays,
      easiness_factor: sm2Result.easinessFactor,
      retention_score: sm2Result.retentionScore,
      last_reviewed_at: now.toISOString(),
      next_review_due: sm2Result.nextReviewDue.toISOString(),
      history: updatedHistory,
      updated_at: now.toISOString(),
    },
    { onConflict: "user_id,skill_id" }
  );

  // 5. Update retention_score on user_skill_progress to recalculate mastery
  await upsertSkillProgress(userId, skillId, {
    retention_score: sm2Result.retentionScore,
  });

  return sm2Result;
}

/**
 * Fetches all skills currently due or overdue for a spaced repetition review.
 */
export async function getDueSkillReviews(
  userId: string,
  limit: number = 10
): Promise<DueReviewItem[]> {
  const admin = getAdminClient();
  const now = new Date();

  // Query items with next_review_due <= now
  const { data: items } = await admin
    .from("spaced_repetition_items")
    .select(`
      id,
      skill_id,
      repetition_count,
      interval_days,
      easiness_factor,
      retention_score,
      last_reviewed_at,
      next_review_due,
      skills!inner (
        id,
        slug,
        name,
        description,
        difficulty
      )
    `)
    .eq("user_id", userId)
    .lte("next_review_due", now.toISOString())
    .order("next_review_due", { ascending: true })
    .limit(limit);

  if (!items) return [];

  return items.map((item) => {
    const skill = Array.isArray(item.skills) ? item.skills[0] : item.skills;
    const initialRetention = Number(item.retention_score ?? 100);
    const lastReviewed = new Date(item.last_reviewed_at ?? now.toISOString());
    const intervalDays = item.interval_days ?? 1;

    const currentRetention = calculateDecayedRetention(
      initialRetention,
      intervalDays,
      lastReviewed,
      now
    );

    return {
      id: item.id,
      skillId: item.skill_id,
      skillSlug: skill?.slug ?? "",
      skillName: skill?.name ?? "Unknown Skill",
      skillDescription: skill?.description ?? null,
      difficulty: skill?.difficulty ?? "beginner",
      repetitionCount: item.repetition_count,
      intervalDays: item.interval_days,
      easinessFactor: Number(item.easiness_factor),
      currentRetention,
      nextReviewDue: item.next_review_due,
      isOverdue: new Date(item.next_review_due).getTime() < now.getTime(),
    };
  });
}

/**
 * Summarizes the user's overall spaced repetition statistics.
 */
export async function getSpacedRepetitionSummary(userId: string) {
  const admin = getAdminClient();
  const now = new Date();

  const { data: allItems } = await admin
    .from("spaced_repetition_items")
    .select("retention_score, interval_days, last_reviewed_at, next_review_due")
    .eq("user_id", userId);

  if (!allItems || allItems.length === 0) {
    return {
      totalTracked: 0,
      dueCount: 0,
      averageRetention: 100,
    };
  }

  let totalDecayedRetention = 0;
  let dueCount = 0;

  for (const item of allItems) {
    const initialRetention = Number(item.retention_score ?? 100);
    const lastReviewed = new Date(item.last_reviewed_at ?? now.toISOString());
    const interval = item.interval_days ?? 1;
    const decayed = calculateDecayedRetention(initialRetention, interval, lastReviewed, now);

    totalDecayedRetention += decayed;
    if (new Date(item.next_review_due).getTime() <= now.getTime()) {
      dueCount++;
    }
  }

  return {
    totalTracked: allItems.length,
    dueCount,
    averageRetention: Math.round(totalDecayedRetention / allItems.length),
  };
}
