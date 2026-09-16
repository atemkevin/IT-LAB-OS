import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { getAdminClient } from "@/lib/supabase/admin";

describe("Phase 4.1 Integrity & Scoring", () => {
  const admin = getAdminClient();
  let userA: string;
  let userB: string;
  let domainId: string;
  let skillA: string;
  let skillB: string;
  let lessonA1: string;
  let lessonA2: string;
  let lessonA3: string;
  let practiceTaskA: string;

  beforeAll(async () => {
    // 1. Create real test users via Admin API
    const emailA = `testA-${Date.now()}@example.com`;
    const { data: authA } = await admin.auth.admin.createUser({ email: emailA, password: "password123", email_confirm: true });
    userA = authA.user!.id;

    const emailB = `testB-${Date.now()}@example.com`;
    const { data: authB } = await admin.auth.admin.createUser({ email: emailB, password: "password123", email_confirm: true });
    userB = authB.user!.id;

    // 2. Insert dummy domain & skills
    const { data: d } = await admin.from("domains").insert({ name: "Integrity Domain", slug: `int-dom-${Date.now()}` }).select("id").single();
    domainId = d!.id;

    const { data: sA } = await admin.from("skills").insert({ domain_id: domainId, name: "Skill A", slug: `skill-a-${Date.now()}`, difficulty: "beginner", estimated_minutes: 10 }).select("id").single();
    skillA = sA!.id;

    const { data: sB } = await admin.from("skills").insert({ domain_id: domainId, name: "Skill B", slug: `skill-b-${Date.now()}`, difficulty: "beginner", estimated_minutes: 10 }).select("id").single();
    skillB = sB!.id;

    // 3. Insert lessons
    const { data: lA1 } = await admin.from("lessons").insert({ skill_id: skillA, slug: `la1-${Date.now()}`, title: "A1" }).select("id").single();
    const { data: lA2 } = await admin.from("lessons").insert({ skill_id: skillA, slug: `la2-${Date.now()}`, title: "A2" }).select("id").single();
    const { data: lA3 } = await admin.from("lessons").insert({ skill_id: skillA, slug: `la3-${Date.now()}`, title: "A3" }).select("id").single();
    lessonA1 = lA1!.id; lessonA2 = lA2!.id; lessonA3 = lA3!.id;

    for (let i = 0; i < 10; i++) {
      const { data: lB } = await admin.from("lessons").insert({ skill_id: skillB, slug: `lb${i}-${Date.now()}`, title: `B${i}` }).select("id").single();
      await admin.from("user_lesson_progress").insert({ user_id: userA, lesson_id: lB!.id, status: "completed" });
    }

    // 4. Insert practice task for A
    const { data: pA } = await admin.from("practice_tasks").insert({ skill_id: skillA, title: "Task A", is_published: true }).select("id").single();
    practiceTaskA = pA!.id;
  });

  afterAll(async () => {
    // Cleanup
    await admin.from("domains").delete().eq("id", domainId);
    await admin.auth.admin.deleteUser(userA);
    await admin.auth.admin.deleteUser(userB);
  });

  it("TEST A: Lesson scoping calculates knowledge strictly by skill", async () => {
    await admin.from("user_lesson_progress").insert([
      { user_id: userA, lesson_id: lessonA1, status: "completed" },
      { user_id: userA, lesson_id: lessonA2, status: "completed" }
    ]);

    const { calculateKnowledgeEvidence } = await import("@/lib/mastery/knowledge");
    
    const knowledgeA = await calculateKnowledgeEvidence(userA, skillA);
    expect(knowledgeA).toBe(67);

    const knowledgeB = await calculateKnowledgeEvidence(userA, skillB);
    expect(knowledgeB).toBe(100);
  });

  it("TEST D & E: Quiz evidence rules", async () => {
    const { calculateKnowledgeEvidence } = await import("@/lib/mastery/knowledge");
    
    await admin.from("quiz_attempts").insert({
      user_id: userA,
      skill_id: skillA,
      score: 100,
      answers: {},
      question_count: 1,
      correct_count: 1
    });

    const knowledgeAfterPass = await calculateKnowledgeEvidence(userA, skillA);
    expect(knowledgeAfterPass).toBe(84); // 67 + 100 / 2

    await admin.from("quiz_attempts").insert({
      user_id: userA,
      skill_id: skillA,
      score: 20,
      answers: {},
      question_count: 1,
      correct_count: 0
    });

    const knowledgeAfterFail = await calculateKnowledgeEvidence(userA, skillA);
    expect(knowledgeAfterFail).toBe(84);
  });
});