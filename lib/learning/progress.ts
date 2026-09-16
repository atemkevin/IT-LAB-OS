/**
 * lib/learning/progress.ts
 *
 * User skill progress — upsert and mastery recalculation.
 * Server-only. Uses admin client (service role) to bypass RLS write restriction.
 */
import { getAdminClient } from "@/lib/supabase/admin";
import { calculateMastery, calculateMasteryState } from "@/lib/mastery/calculateMastery";
import type { SkillProgressUpdate } from "./types";

/**
 * Fetch current user skill progress record (null if not started).
 * Uses regular client so RLS is applied (own data only).
 */
export async function getUserSkillProgress(
  supabase: Awaited<ReturnType<typeof import("@/lib/supabase/server").createClient>>,
  userId: string,
  skillId: string
) {
  const { data } = await supabase
    .from("user_skill_progress")
    .select("*")
    .eq("user_id", userId)
    .eq("skill_id", skillId)
    .maybeSingle();

  return data;
}

/**
 * Upsert user skill progress and recalculate mastery score + state.
 * Uses admin client to bypass RLS (only server API routes call this).
 */
export async function upsertSkillProgress(
  userId: string,
  skillId: string,
  update: SkillProgressUpdate
): Promise<void> {
  const admin = getAdminClient();

  // Get existing progress or defaults
  const { data: existing } = await admin
    .from("user_skill_progress")
    .select("*")
    .eq("user_id", userId)
    .eq("skill_id", skillId)
    .maybeSingle();

  const knowledge = update.knowledge_score ?? Number(existing?.knowledge_score ?? 0);
  const practice = update.practice_score ?? Number(existing?.practice_score ?? 0);
  const troubleshooting = update.troubleshooting_score ?? Number(existing?.troubleshooting_score ?? 0);
  const project = update.project_score ?? Number(existing?.project_score ?? 0);
  const retention = update.retention_score ?? Number(existing?.retention_score ?? 0);

  const masteryScore = calculateMastery({
    knowledge,
    practice,
    troubleshooting,
    project,
    retention,
  });

  const masteryState = calculateMasteryState(masteryScore);

  const attemptCount = (existing?.attempt_count ?? 0) + 1;

  await admin.from("user_skill_progress").upsert(
    {
      user_id: userId,
      skill_id: skillId,
      knowledge_score: knowledge,
      practice_score: practice,
      troubleshooting_score: troubleshooting,
      project_score: project,
      retention_score: retention,
      mastery_score: masteryScore,
      mastery_state: masteryState,
      attempt_count: attemptCount,
      last_activity_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    },
    { onConflict: "user_id,skill_id" }
  );
}
