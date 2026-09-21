/**
 * lib/learning/activity.ts
 *
 * Activity logging + streak tracking for the /progress timeline.
 * Server-only.
 *
 * Streak updates are delegated to the `record_daily_activity` Postgres
 * function (migration 007) which performs the read-modify-write inside a
 * single transaction with a row lock. Doing it client-side previously led to
 * two defects:
 *
 *   1. PostgREST `.lt()` does not match NULL, so a brand-new learner's first
 *      activity never started their streak.
 *   2. The reset branch also zeroed `longest_streak`, wiping the all-time
 *      record whenever a learner returned after a gap.
 *
 * The calendar date is computed in the app's local timezone and passed in, so
 * the streak day boundary matches the learner's clock rather than the
 * database server's (UTC).
 */
import { createClient } from "@/lib/supabase/server";
import { todayString } from "@/lib/utils";
import type { Json } from "@/lib/database.types";

export type ActivityType =
  | "lesson_completed"
  | "practice_completed"
  | "mission_completed"
  | "troubleshooting_completed"
  | "project_completed";

/**
 * Log an activity and advance the learner's daily streak.
 *
 * Returns true when both the activity row and the streak update succeeded.
 * The activity INSERT and the streak RPC are separate statements: the audit
 * row is written first so a streak failure never loses the activity record.
 */
export async function logActivity(
  userId: string,
  type: ActivityType,
  details: Record<string, unknown> = {},
): Promise<boolean> {
  const supabase = await createClient();
  const today = todayString();

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

  const { error: streakError } = await supabase.rpc("record_daily_activity", {
    p_user_id: userId,
    p_today: today,
  });

  if (streakError) {
    console.error("Failed to update streak:", streakError);
    return false;
  }

  return true;
}
