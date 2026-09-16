/**
 * tests/integration/streaks.test.ts
 *
 * Regression tests for the daily-streak engine (migration 007).
 *
 * These cases cover the two defects that shipped in the first version:
 *   1. A brand-new learner (last_activity_date IS NULL) must start at 1.
 *      The old client-side `.lt()` compare-and-swap never matched NULL.
 *   2. Returning after a gap must reset the current streak to 1 WITHOUT
 *      lowering longest_streak. The old code zeroed the record.
 *
 * The engine is a Postgres function so it is exercised against the live DB.
 */
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getAdminClient } from "@/lib/supabase/admin";

/** Format a date offset from today as YYYY-MM-DD (local time). */
function dayOffset(offset: number): string {
  const t = new Date();
  t.setDate(t.getDate() + offset);
  return `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, "0")}-${String(t.getDate()).padStart(2, "0")}`;
}

describe("Daily streak engine (record_daily_activity)", () => {
  const admin = getAdminClient();
  let userId: string;

  beforeAll(async () => {
    const email = `streak-${Date.now()}@itlabos.test`;
    const { data } = await admin.auth.admin.createUser({
      email,
      password: "Password123!Secure",
      email_confirm: true,
    });
    userId = data!.user!.id;
    // Fresh profile: last_activity_date is NULL.
    await admin.from("profiles").insert({ id: userId, display_name: "streak-test" });
  });

  afterAll(async () => {
    if (userId) await admin.auth.admin.deleteUser(userId);
  });

  async function setStreakState(prev: string | null, current: number, longest: number) {
    await admin
      .from("profiles")
      .update({ last_activity_date: prev, current_streak: current, longest_streak: longest })
      .eq("id", userId);
  }

  async function record(today = dayOffset(0)) {
    const { data, error } = await admin.rpc("record_daily_activity", {
      p_user_id: userId,
      p_today: today,
    });
    if (error) throw new Error(error.message);
    return data![0];
  }

  it("starts a streak at 1 for a brand-new learner (NULL last_activity_date)", async () => {
    await setStreakState(null, 0, 0);
    const result = await record();
    expect(result.current_streak).toBe(1);
    expect(result.longest_streak).toBe(1);
    expect(result.last_activity_date).toBe(dayOffset(0));
  });

  it("increments the streak when the previous activity was yesterday", async () => {
    await setStreakState(dayOffset(-1), 4, 30);
    const result = await record();
    expect(result.current_streak).toBe(5);
    expect(result.longest_streak).toBe(30);
  });

  it("resets to 1 after a gap but preserves the all-time record", async () => {
    await setStreakState(dayOffset(-5), 4, 30);
    const result = await record();
    expect(result.current_streak).toBe(1);
    expect(result.longest_streak).toBe(30); // must NOT be wiped
  });

  it("raises longest_streak when the current streak overtakes it", async () => {
    await setStreakState(dayOffset(-1), 9, 9);
    const result = await record();
    expect(result.current_streak).toBe(10);
    expect(result.longest_streak).toBe(10);
  });

  it("is a no-op when the learner has already been active today", async () => {
    await setStreakState(dayOffset(0), 7, 12);
    const result = await record();
    expect(result.current_streak).toBe(7);
    expect(result.longest_streak).toBe(12);
  });

  it("is idempotent across repeated calls on the same day", async () => {
    await setStreakState(null, 0, 0);
    const first = await record();
    const second = await record();
    const third = await record();
    expect(first.current_streak).toBe(1);
    expect(second.current_streak).toBe(1);
    expect(third.current_streak).toBe(1);
  });

  it("uses the caller-supplied date for the day boundary", async () => {
    // Simulate a backdated activity a week ago, then "today" advances by 1.
    await setStreakState(dayOffset(-8), 3, 3);
    const result = await record(dayOffset(-7));
    expect(result.current_streak).toBe(4);
    expect(result.last_activity_date).toBe(dayOffset(-7));
  });
});
