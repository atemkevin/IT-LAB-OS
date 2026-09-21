import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { randomUUID } from "crypto";
import { recordSkillReview, getDueSkillReviews } from "@/lib/spaced-repetition/service";
import { generateDailyMission } from "@/lib/learning/missions";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "http://127.0.0.1:54321";
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3QiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzA0MDY3MjAwLCJleHAiOjE4NjE4NDMyMDB9.SERVICE_KEY";

const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

describe("Spaced Repetition Engine (SM-2) Integration", () => {
  let userA: { id: string; email: string };
  let userB: { id: string; email: string };
  let clientA: SupabaseClient;
  let skillId: string;

  beforeAll(async () => {
    userA = { id: randomUUID(), email: `sm2-user-a-${Date.now()}@example.com` };
    userB = { id: randomUUID(), email: `sm2-user-b-${Date.now()}@example.com` };

    // 1. Create users
    await serviceClient.auth.admin.createUser({
      id: userA.id,
      email: userA.email,
      password: "Password123!",
      email_confirm: true,
    });

    await serviceClient.auth.admin.createUser({
      id: userB.id,
      email: userB.email,
      password: "Password123!",
      email_confirm: true,
    });

    // 2. Client A session
    clientA = createClient(supabaseUrl, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "anon", {
      auth: { autoRefreshToken: false, persistSession: false },
    });
    await clientA.auth.signInWithPassword({ email: userA.email, password: "Password123!" });

    // 3. Get a real published skill
    const { data: skill } = await serviceClient
      .from("skills")
      .select("id")
      .eq("is_published", true)
      .limit(1)
      .single();

    if (!skill) throw new Error("No published skills available to test");
    skillId = skill.id;
  });

  afterAll(async () => {
    // Cleanup
    await serviceClient.auth.admin.deleteUser(userA.id);
    await serviceClient.auth.admin.deleteUser(userB.id);
  });

  it("records first review and initializes SM-2 state & mastery retention", async () => {
    const result = await recordSkillReview(userA.id, skillId, 5);

    expect(result.repetitionCount).toBe(1);
    expect(result.intervalDays).toBe(1);
    expect(result.easinessFactor).toBe(2.6);
    expect(result.retentionScore).toBe(100);

    // Verify persisted record in spaced_repetition_items
    const { data: item, error: itemError } = await serviceClient
      .from("spaced_repetition_items")
      .select("*")
      .eq("user_id", userA.id)
      .eq("skill_id", skillId)
      .single();

    expect(itemError).toBeNull();
    expect(item?.repetition_count).toBe(1);
    expect(item?.interval_days).toBe(1);
    expect(Number(item?.retention_score)).toBe(100);

    // Verify user_skill_progress.retention_score synchronization
    const { data: progress } = await serviceClient
      .from("user_skill_progress")
      .select("retention_score, mastery_score")
      .eq("user_id", userA.id)
      .eq("skill_id", skillId)
      .single();

    expect(progress?.retention_score).toBe(100);
    // Retention is 10% of total mastery, so 100 * 0.1 = 10
    expect(progress?.mastery_score).toBeGreaterThanOrEqual(10);
  });

  it("advances interval to 6 days on second successful review", async () => {
    const result = await recordSkillReview(userA.id, skillId, 4);

    expect(result.repetitionCount).toBe(2);
    expect(result.intervalDays).toBe(6);

    const { data: item } = await serviceClient
      .from("spaced_repetition_items")
      .select("repetition_count, interval_days, history")
      .eq("user_id", userA.id)
      .eq("skill_id", skillId)
      .single();

    expect(item?.repetition_count).toBe(2);
    expect(item?.interval_days).toBe(6);
    expect(Array.isArray(item?.history)).toBe(true);
    expect(item?.history.length).toBe(2);
  });

  it("enforces RLS: User A can read own items, but not other users' items", async () => {
    // Seed item for User B
    await serviceClient.from("spaced_repetition_items").insert({
      user_id: userB.id,
      skill_id: skillId,
      repetition_count: 3,
      interval_days: 15,
    });

    // Client A queries all spaced_repetition_items
    const { data, error } = await clientA.from("spaced_repetition_items").select("*");
    expect(error).toBeNull();
    expect(data?.every((d) => d.user_id === userA.id)).toBe(true);
  });

  it("prioritizes overdue skills in Daily Mission generation", async () => {
    // Make User A's skill overdue by setting next_review_due into the past
    const pastDate = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString();
    await serviceClient
      .from("spaced_repetition_items")
      .update({ next_review_due: pastDate })
      .eq("user_id", userA.id)
      .eq("skill_id", skillId);

    // Verify getDueSkillReviews returns it
    const due = await getDueSkillReviews(userA.id);
    expect(due.some((d) => d.skillId === skillId)).toBe(true);

    // Generate mission for User A
    const mission = await generateDailyMission(userA.id);
    expect(mission).not.toBeNull();
    expect(mission?.title).toContain("Memory Retention:");
    expect(mission?.recommendationReason).toContain("Spaced Repetition Review:");
  });
});
