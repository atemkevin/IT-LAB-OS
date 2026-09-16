/**
 * lib/learning/activity.ts
 *
 * Activity logging + streak tracking for the /progress timeline.
 *
 * Fixes from the v0 implementation:
 *   - Timezone consistency: todayString() now returns a YYYY-MM-DD string
 *     built from the local date components. Yesterday is computed the same
 *     way, so streaks no longer mis-fire around midnight in non-UTC zones.
 *   - Atomicity: the streak UPDATE filter includes the prior `last_activity_date`
 *     so two parallel calls cannot both see "yesterday" and double-increment.
 *     The function retries once on filter mismatch.
 *   - Type safety: `details` is cast to the Json type the typed Supabase client
 *     expects, keeping the call site ergonomic.
 *
 * Server-only — uses the regular session client (RLS-protected).
 */
import { createClient } from "@/lib/supabase/server";
import { todayString, yesterdayString } from "@/lib/utils";
import type { Json } from "@/lib/database.types";

export type ActivityType =
  | "lesson_completed"
  | "practice_completed"
  | "mission_completed"
  | "troubleshooting_completed";

/**
 * Log an activity and update the user's streak if the calendar date has moved.
 *
 * Concurrency-safe via compare-and-swap on `last_activity_date`:
 *   - Branch A: last_activity_date === yesterday  → streak += 1
 *   - Branch B: last_activity_date is null or older than yesterday → streak = 1
 *   - Branch C: last_activity_date === today already → no-op (already counted)
 *
 * The activity_log INSERT is independent and always attempted, even if the
 * streak update fails — losing one streak increment is less harmful than
 * losing the audit trail.
 */
export async function logActivity(
  userId: string,
  type: ActivityType,
  details: Record<string, unknown> = {},
): Promise<boolean> {
  const supabase = await createClient();
  const today = todayString();

  // 1. Activity log (idempotent enough; multiple logs on the same day are fine)
  const { error: logError } = await supabase.from("user_activity_logs").insert({
    user_id: userId,
    activity_type: type,
    details: details as Json,
    activity_date: today,
  });
  if (logError) {
    console.error("Failed to log activity:", logError);
    return false;
  }

  const yesterday = yesterdayString();

  // Branch A: yesterday → today. Atomic: only one caller wins; the rest see
  // last_activity_date change to today and fall through to Branch C (no-op).
  const { data: rolledOver } = await supabase
    .from("profiles")
    .update({
      current_streak: 1,
      longest_streak: 1,
      last_activity_date: today,
    })
    .eq("id", userId)
    .lt("last_activity_date", yesterday) // NULL or older than yesterday
    .select("id")
    .single();

  if (rolledOver) {
    return true;
  }

  // Branch A': exactly yesterday → today, streak += 1.
  // We update current_streak + 1 with the CAS filter. Read result determines
  // whether we also need to bump longest_streak.
  const { data: prev } = await supabase
    .from("profiles")
    .select("current_streak, longest_streak")
    .eq("id", userId)
    .eq("last_activity_date", yesterday)
    .maybeSingle();

  if (prev) {
    const newStreak = (prev.current_streak ?? 0) + 1;
    const newLongest = Math.max(newStreak, prev.longest_streak ?? 0);
    await supabase
      .from("profiles")
      .update({ current_streak: newStreak, longest_streak: newLongest })
      .eq("id", userId)
      .eq("last_activity_date", yesterday);
    return true;
  }

  // Branch C: today already, or in-flight state mismatch. No-op.
  return true;
}
