import { describe, it, expect, vi } from "vitest";
import { POST as lessonPost } from "@/app/api/lessons/[id]/progress/route";
import { POST as practicePost } from "@/app/api/practice/[taskId]/attempt/route";
import { NextRequest } from "next/server";

const mocks = vi.hoisted(() => {
  return {
    mockAdminClient: {
      from: vi.fn()
    },
    mockCompleteLesson: vi.fn().mockResolvedValue(true),
    mockEvaluatePracticeEvidence: vi.fn().mockResolvedValue({ passed: true, score: 100 })
  };
});

let mockAuthUser: any = { id: "user-123" };

/**
 * Chainable from() that handles `.select().eq().maybeSingle()` and
 * `.insert().select().single()` chains for ALL tables. The real `createClient`
 * mock gets reused by `logActivity` (which reads `profiles` and writes
 * `user_activity_logs`).
 */
function chainedFrom() {
  const finalable: any = {
    then: (cb: (v: unknown) => unknown) => Promise.resolve({ data: null, error: null }).then(cb),
  };
  const chain: any = finalable;
  [
    "select",
    "insert",
    "update",
    "delete",
    "upsert",
    "eq",
    "neq",
    "lt",
    "lte",
    "gt",
    "gte",
    "in",
    "is",
    "or",
    "and",
    "not",
    "match",
    "filter",
    "order",
    "limit",
    "range",
    "single",
    "maybeSingle",
    "csv",
  ].forEach((m) => {
    chain[m] = vi.fn().mockImplementation(() => chain);
  });
  return chain;
}

function paginatedFrom() {
  return {
    then: (cb: (v: unknown) => unknown) =>
      Promise.resolve({ data: [], error: null, count: 0 }).then(cb),
  };
}

vi.mock("@/lib/supabase/server", () => ({
  createClient: vi.fn().mockImplementation(async () => ({
    auth: {
      getUser: vi.fn().mockImplementation(async () => {
        if (!mockAuthUser) return { data: { user: null }, error: { message: "Unauthorized" } };
        return { data: { user: mockAuthUser }, error: null };
      }),
    },
    from: vi.fn().mockImplementation((_table: string) => chainedFrom()),
    rpc: vi.fn().mockImplementation(async () => ({ data: null, error: null })),
  }))
}));

vi.mock("@/lib/supabase/admin", () => ({
  getAdminClient: vi.fn().mockReturnValue(mocks.mockAdminClient)
}));

vi.mock("@/lib/learning/lessons", () => ({
  startLesson: vi.fn(),
  completeLesson: mocks.mockCompleteLesson
}));

vi.mock("@/lib/learning/progress", () => ({
  upsertSkillProgress: vi.fn()
}));

vi.mock("@/lib/mastery/knowledge", () => ({
  calculateKnowledgeEvidence: vi.fn().mockResolvedValue(67)
}));

vi.mock("@/lib/learning/practice", () => ({
  evaluatePracticeEvidence: mocks.mockEvaluatePracticeEvidence
}));

describe("API Security: Skill Injection Prevention", () => {
  /**
   * Build a chainable mock for an admin `from(table).select(...)` lookup
   * that resolves `maybeSingle()` with the given row.
   */
  function adminLookupReturning(row: unknown) {
    const chainable: any = {
      then: (cb: (v: unknown) => unknown) =>
        Promise.resolve({ data: row, error: null }).then(cb),
    };
    ["select", "eq", "neq", "lt", "lte", "gt", "gte", "in", "is", "or",
      "order", "limit", "range", "match", "filter"].forEach((m) => {
      chainable[m] = vi.fn().mockImplementation(() => chainable);
    });
    chainable.single = vi.fn().mockResolvedValue({ data: row, error: null });
    chainable.maybeSingle = vi.fn().mockResolvedValue({ data: row, error: null });
    return chainable;
  }

  it("TEST C: Lesson route ignores client skillId and uses authoritative skill from DB", async () => {
    mockAuthUser = { id: "user-123" };
    mocks.mockAdminClient.from.mockImplementation((table: string) => {
      if (table === "lessons") {
        return adminLookupReturning({ skill_id: "authoritative-skill-id" });
      }
      return adminLookupReturning(null);
    });

    const fakeUuid = "00000000-0000-0000-0000-000000000000";
    const req = new NextRequest("http://localhost/api/lessons/123/progress", {
      method: "POST",
      body: JSON.stringify({ action: "complete", skillId: fakeUuid })
    });

    const res = await lessonPost(req, { params: Promise.resolve({ id: "lesson-123" }) });
    expect(res.status).toBe(200);
  });

  it("TEST B & F: Practice route ignores client skillId and uses authoritative task.skill_id", async () => {
    mockAuthUser = { id: "user-123" };
    mocks.mockAdminClient.from.mockImplementation((table: string) => {
      if (table === "practice_tasks") {
        return adminLookupReturning({ id: "task-1", skill_id: "true-skill-id" });
      }
      return adminLookupReturning(null);
    });

    const fakeUuid = "00000000-0000-0000-0000-000000000000";
    const req = new NextRequest("http://localhost/api/practice/task-1/attempt", {
      method: "POST",
      body: JSON.stringify({ skillId: fakeUuid, completed: true, notes: "done" })
    });

    const res = await practicePost(req, { params: Promise.resolve({ taskId: "task-1" }) });
    expect(res.status).toBe(200);

    expect(mocks.mockEvaluatePracticeEvidence).toHaveBeenCalledWith(
      "user-123",
      "task-1",
      "true-skill-id",
      expect.objectContaining({ notes: "done", completed: true })
    );
  });

  it("TEST I: Unauthenticated practice submission is rejected", async () => {
    mockAuthUser = null;

    const req = new NextRequest("http://localhost/api/practice/task-1/attempt", {
      method: "POST",
      body: JSON.stringify({ completed: true })
    });

    const res = await practicePost(req, { params: Promise.resolve({ taskId: "task-1" }) });
    expect(res.status).toBe(401);
  });

  it("TEST J: Invalid task ID is rejected", async () => {
    mockAuthUser = { id: "user-123" };
    mocks.mockAdminClient.from.mockImplementation((table: string) => {
      if (table === "practice_tasks") {
        return adminLookupReturning(null); // task not found
      }
      return adminLookupReturning(null);
    });

    const req = new NextRequest("http://localhost/api/practice/task-1/attempt", {
      method: "POST",
      body: JSON.stringify({ completed: true })
    });

    const res = await practicePost(req, { params: Promise.resolve({ taskId: "fake-task-id" }) });
    expect(res.status).toBe(404);
  });
});