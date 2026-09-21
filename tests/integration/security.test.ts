import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

describe("Security & RLS Rigorous Verification (Phase 2 Task 8)", () => {
  let admin: SupabaseClient<Database>;
  let userAClient: SupabaseClient<Database>;
  let userBClient: SupabaseClient<Database>;
  let userAId: string;
  let userBId: string;
  let noteBId: string;

  beforeAll(async () => {
    admin = createClient<Database>(url, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const timestamp = Date.now();
    const emailA = `test_user_a_${timestamp}@itlabos.test`;
    const emailB = `test_user_b_${timestamp}@itlabos.test`;
    const password = "Password123!Secure";

    // 1. Create User A and User B
    const { data: userARes } = await admin.auth.admin.createUser({
      email: emailA,
      password,
      email_confirm: true,
    });
    userAId = userARes!.user!.id;

    const { data: userBRes } = await admin.auth.admin.createUser({
      email: emailB,
      password,
      email_confirm: true,
    });
    userBId = userBRes!.user!.id;

    // 2. Authenticate User A and User B clients with distinct storage keys (prevent jsdom localStorage collision)
    userAClient = createClient<Database>(url, anonKey, {
      auth: {
        storageKey: `user-a-storage-${timestamp}`,
        persistSession: true,
        autoRefreshToken: false,
      },
    });
    await userAClient.auth.signInWithPassword({ email: emailA, password });

    userBClient = createClient<Database>(url, anonKey, {
      auth: {
        storageKey: `user-b-storage-${timestamp}`,
        persistSession: true,
        autoRefreshToken: false,
      },
    });
    await userBClient.auth.signInWithPassword({ email: emailB, password });

    // 3. User B creates a profile, a progress record, and a private note
    await userBClient.from("profiles").upsert({
      id: userBId,
      display_name: "User B Private",
    });

    // Seed lesson progress for user B.
    // Written with the service-role client: migration 009 revokes learner
    // INSERT/UPDATE on user_lesson_progress (it feeds the knowledge score).
    const { data: lessons } = await admin.from("lessons").select("id").limit(1);
    if (lessons && lessons.length > 0) {
      await admin.from("user_lesson_progress").upsert({
        user_id: userBId,
        lesson_id: lessons[0].id,
        progress: 80,
      });
    }

    // Seed note for user B
    const { data: noteRes } = await userBClient
      .from("notes")
      .insert({
        user_id: userBId,
        title: "Confidential Note B",
        content_markdown: "Top secret content belonging to User B",
      })
      .select("id")
      .single();

    if (noteRes) {
      noteBId = noteRes.id;
    }
  });

  afterAll(async () => {
    // Cleanup test users and cascade delete their data
    if (userAId) await admin.auth.admin.deleteUser(userAId);
    if (userBId) await admin.auth.admin.deleteUser(userBId);
  });

  it("1. User A cannot read User B profile", async () => {
    // User A attempts to read User B's profile
    const { data, error } = await userAClient
      .from("profiles")
      .select("*")
      .eq("id", userBId);

    expect(error).toBeNull();
    expect(data).toEqual([]); // RLS hides User B's profile from User A
  });

  it("2. User A cannot read User B learning progress", async () => {
    // User A attempts to query User B's progress
    const { data, error } = await userAClient
      .from("user_lesson_progress")
      .select("*")
      .eq("user_id", userBId);

    expect(error).toBeNull();
    expect(data).toEqual([]); // RLS hides User B's progress from User A
  });

  it("3. User A cannot update User B notes", async () => {
    if (!noteBId) return;

    // User A attempts to modify User B's note
    const { error } = await userAClient
      .from("notes")
      .update({ title: "Hacked by User A" })
      .eq("id", noteBId);

    expect(error).toBeNull();

    // Verify User B's note is unchanged
    const { data: noteB } = await userBClient
      .from("notes")
      .select("title")
      .eq("id", noteBId)
      .single();

    expect(noteB?.title).toBe("Confidential Note B");
  });

  it("4. Learners cannot directly forge mastery values (no INSERT/UPDATE policy for learners)", async () => {
    const { data: skills } = await admin.from("skills").select("id").limit(1);
    const skillId = skills![0].id;

    // User A attempts to write mastery score directly
    const { error } = await userAClient
      .from("user_skill_progress")
      .insert({
        user_id: userAId,
        skill_id: skillId,
        mastery_score: 100,
        knowledge_score: 100,
      });

    // RLS denies insert for learners on user_skill_progress
    expect(error).not.toBeNull();
    expect(error?.code).toBe("42501"); // insufficient_privilege
  });

  it("4b. Learners cannot forge lesson completion (migration 009 revokes INSERT/UPDATE)", async () => {
    const { data: lessons } = await admin.from("lessons").select("id").limit(1);
    const lessonId = lessons![0].id;

    // INSERT / upsert is rejected outright.
    const ins = await userAClient
      .from("user_lesson_progress")
      .upsert({
        user_id: userAId,
        lesson_id: lessonId,
        status: "completed",
        progress: 100,
      })
      .select();
    expect(ins.error?.code).toBe("42501");

    // Seed a legitimate row with the service role, then confirm the learner
    // cannot UPDATE it either, and that the stored value is untouched.
    await admin.from("user_lesson_progress").upsert({
      user_id: userAId,
      lesson_id: lessonId,
      status: "in_progress",
      progress: 10,
    });

    const upd = await userAClient
      .from("user_lesson_progress")
      .update({ status: "completed", progress: 100 })
      .eq("user_id", userAId)
      .eq("lesson_id", lessonId);
    expect(upd.error?.code).toBe("42501");

    const { data: after } = await admin
      .from("user_lesson_progress")
      .select("status, progress")
      .eq("user_id", userAId)
      .eq("lesson_id", lessonId)
      .single();
    expect(after?.status).toBe("in_progress");
    expect(Number(after?.progress)).toBe(10);
  });

  it("4c. Learners cannot forge a resolved troubleshooting attempt (migration 009)", async () => {
    const { data: scenarios } = await admin
      .from("troubleshooting_scenarios")
      .select("id")
      .limit(1);
    const scenarioId = scenarios![0].id;

    const ins = await userAClient
      .from("troubleshooting_attempts")
      .insert({
        user_id: userAId,
        scenario_id: scenarioId,
        resolved: true,
        root_cause_identified: true,
        score: 100,
      })
      .select();

    expect(ins.error?.code).toBe("42501");

    // Confirm nothing was written.
    const { count } = await admin
      .from("troubleshooting_attempts")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userAId)
      .eq("resolved", true);
    expect(count ?? 0).toBe(0);
  });

  it("5. Unauthenticated users cannot access private user data", async () => {
    // Distinct anonymous client with no session persistence
    const anon = createClient<Database>(url, anonKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: profiles } = await anon.from("profiles").select("*");
    const { data: notes } = await anon.from("notes").select("*");
    const { data: progress } = await anon.from("user_skill_progress").select("*");

    expect(profiles).toEqual([]);
    expect(notes).toEqual([]);
    expect(progress).toEqual([]);
  });

  it("6. Published curriculum is readable according to policy", async () => {
    const anon = createClient<Database>(url, anonKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data: domains, error: dErr } = await anon.from("domains").select("id, slug, is_published");
    const { data: skills, error: sErr } = await anon.from("skills").select("id, slug, is_published");

    expect(dErr).toBeNull();
    expect(sErr).toBeNull();
    expect(domains?.length).toBeGreaterThanOrEqual(12);
    expect(skills?.length).toBeGreaterThanOrEqual(26);
    expect(domains?.every((d) => d.is_published)).toBe(true);
    expect(skills?.every((s) => s.is_published)).toBe(true);
  });

  it("7. Quiz correct answers are not exposed through learner-facing queries", async () => {
    const anon = createClient<Database>(url, anonKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    const { data, error } = await anon.from("quiz_options").select("*");

    // RLS completely denies SELECT for anon/authenticated
    expect(error).toBeNull();
    expect(data).toEqual([]);
  });

  it("8. Service-role credentials are not exposed to the client", () => {
    expect(process.env.NEXT_PUBLIC_SUPABASE_SERVICE_ROLE_KEY).toBeUndefined();
    expect(serviceRoleKey).not.toBe(anonKey);
    expect(serviceRoleKey).toContain("eyJ");
  });
});
