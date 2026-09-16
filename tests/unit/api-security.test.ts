import { describe, it, expect, vi } from "vitest";
import { POST as lessonPost } from "@/app/api/lessons/[id]/progress/route";
import { POST as practicePost } from "@/app/api/practice/[taskId]/attempt/route";
import { NextRequest } from "next/server";

// Mock dependencies using vi.hoisted to ensure they are available to vi.mock
const mocks = vi.hoisted(() => {
  return {
    mockAdminClient: {
      from: vi.fn()
    },
    mockCompleteLesson: vi.fn().mockResolvedValue(true),
    mockSubmitPracticeAttempt: vi.fn().mockResolvedValue({ passed: true, score: 100 })
  };
});

vi.mock("@/lib/supabase/server", () => ({
  createClient: vi.fn().mockResolvedValue({
    auth: {
      getUser: vi.fn().mockResolvedValue({ data: { user: { id: "user-123" } }, error: null })
    }
  })
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
  submitPracticeAttempt: mocks.mockSubmitPracticeAttempt
}));

describe("API Security: Skill Injection Prevention", () => {
  it("TEST C: Lesson route ignores client skillId and uses authoritative skill from DB", async () => {
    // Setup mock admin db response for lesson
    const selectMock = vi.fn().mockReturnValue({
      eq: vi.fn().mockReturnValue({
        maybeSingle: vi.fn().mockResolvedValue({ data: { skill_id: "authoritative-skill-id" } })
      })
    });
    mocks.mockAdminClient.from.mockReturnValue({ select: selectMock });

    // Client tries to inject fake-skill-id
    const fakeUuid = "00000000-0000-0000-0000-000000000000";
    const req = new NextRequest("http://localhost/api/lessons/123/progress", {
      method: "POST",
      body: JSON.stringify({ action: "complete", skillId: fakeUuid })
    });

    const res = await lessonPost(req, { params: Promise.resolve({ id: "lesson-123" }) });
    expect(res.status).toBe(200);

    // Verify completeLesson was called with authoritative-skill-id
    expect(mocks.mockCompleteLesson).toHaveBeenCalledWith(
      "user-123",
      "lesson-123",
      "authoritative-skill-id"
    );
  });

  it("TEST B & F: Practice route ignores client skillId and uses authoritative task.skill_id", async () => {
    const selectMock = vi.fn().mockReturnValue({
      eq: vi.fn().mockReturnValue({
        maybeSingle: vi.fn().mockResolvedValue({ data: { id: "task-1", skill_id: "true-skill-id" } })
      })
    });
    mocks.mockAdminClient.from.mockReturnValue({ select: selectMock });

    const fakeUuid = "00000000-0000-0000-0000-000000000000";
    const req = new NextRequest("http://localhost/api/practice/task-1/attempt", {
      method: "POST",
      body: JSON.stringify({ skillId: fakeUuid, completed: true, notes: "done" })
    });

    const res = await practicePost(req, { params: Promise.resolve({ taskId: "task-1" }) });
    expect(res.status).toBe(200);

    expect(mocks.mockSubmitPracticeAttempt).toHaveBeenCalledWith(
      "user-123",
      "task-1",
      "true-skill-id",
      { notes: "done", completed: true }
    );
  });
});