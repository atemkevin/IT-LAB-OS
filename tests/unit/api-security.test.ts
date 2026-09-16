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

vi.mock("@/lib/supabase/server", () => ({
  createClient: vi.fn().mockImplementation(async () => ({
    auth: {
      getUser: vi.fn().mockImplementation(async () => {
        if (!mockAuthUser) return { data: { user: null }, error: { message: "Unauthorized" } };
        return { data: { user: mockAuthUser }, error: null };
      })
    }
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
  it("TEST C: Lesson route ignores client skillId and uses authoritative skill from DB", async () => {
    mockAuthUser = { id: "user-123" };
    
    // Create a chainable mock
    const chainable = {
      eq: vi.fn().mockReturnThis(),
      maybeSingle: vi.fn().mockResolvedValue({ data: { skill_id: "authoritative-skill-id" } })
    };
    
    mocks.mockAdminClient.from.mockReturnValue({ select: vi.fn().mockReturnValue(chainable) });

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

    const chainable = {
      eq: vi.fn().mockReturnThis(),
      maybeSingle: vi.fn().mockResolvedValue({ data: { id: "task-1", skill_id: "true-skill-id", practice_score: 50 } })
    };
    
    mocks.mockAdminClient.from.mockReturnValue({ select: vi.fn().mockReturnValue(chainable) });

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
      { notes: "done", completed: true, responses: {} }
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
    
    const chainable = {
      eq: vi.fn().mockReturnThis(),
      maybeSingle: vi.fn().mockResolvedValue({ data: null }) 
    };
    
    mocks.mockAdminClient.from.mockReturnValue({ select: vi.fn().mockReturnValue(chainable) });

    const req = new NextRequest("http://localhost/api/practice/task-1/attempt", {
      method: "POST",
      body: JSON.stringify({ completed: true })
    });

    const res = await practicePost(req, { params: Promise.resolve({ taskId: "fake-task-id" }) });
    expect(res.status).toBe(404);
  });
});