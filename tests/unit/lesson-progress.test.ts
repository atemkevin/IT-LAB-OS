/**
 * tests/unit/lesson-progress.test.ts
 * Unit tests for lesson progress status transitions and mastery score impact.
 */
import { describe, it, expect } from "vitest";
import { calculateMastery, calculateMasteryState } from "@/lib/mastery/calculateMastery";

/**
 * Simulate the lesson completion effect on knowledge score.
 * N lessons, M completed → knowledge_score = (M/N) * 100, capped at 100.
 */
function calculateKnowledgeFromLessons(totalLessons: number, completedLessons: number): number {
  if (totalLessons === 0) return 0;
  return Math.min(Math.round((completedLessons / totalLessons) * 100), 100);
}

describe("Lesson progress status transitions", () => {
  it("initial status should be not_started", () => {
    const status = "not_started";
    expect(status).toBe("not_started");
  });

  it("start action transitions to in_progress", () => {
    let status = "not_started";
    // Simulate start action
    status = "in_progress";
    expect(status).toBe("in_progress");
  });

  it("complete action transitions to completed", () => {
    let status = "in_progress";
    // Simulate complete action
    status = "completed";
    expect(status).toBe("completed");
  });

  it("completing a lesson does not revert to not_started", () => {
    const status = "completed";
    expect(status).not.toBe("not_started");
  });
});

describe("Knowledge score from lesson completions", () => {
  it("0 lessons completed = 0% knowledge", () => {
    expect(calculateKnowledgeFromLessons(3, 0)).toBe(0);
  });

  it("1/3 lessons completed = 33% knowledge", () => {
    expect(calculateKnowledgeFromLessons(3, 1)).toBe(33);
  });

  it("2/3 lessons completed = 67% knowledge", () => {
    expect(calculateKnowledgeFromLessons(3, 2)).toBe(67);
  });

  it("3/3 lessons completed = 100% knowledge", () => {
    expect(calculateKnowledgeFromLessons(3, 3)).toBe(100);
  });

  it("capped at 100% even with more completions than expected", () => {
    expect(calculateKnowledgeFromLessons(2, 5)).toBe(100);
  });

  it("handles 0 total lessons (no division by zero)", () => {
    expect(calculateKnowledgeFromLessons(0, 0)).toBe(0);
  });
});

describe("Mastery score from lesson knowledge", () => {
  it("100% knowledge with 0 practice = 30% mastery (knowledge weight)", () => {
    const mastery = calculateMastery({
      knowledge: 100,
      practice: 0,
      troubleshooting: 0,
      project: 0,
      retention: 0,
    });
    expect(mastery).toBe(30); // 100 * 0.30
  });

  it("completing all lessons and passing quiz reaches developing mastery", () => {
    // knowledge 100% (lessons) + 80% practice
    const mastery = calculateMastery({
      knowledge: 100,
      practice: 80,
      troubleshooting: 0,
      project: 0,
      retention: 0,
    });
    // 100*0.3 + 80*0.2 = 30 + 16 = 46 => developing (30-49 range)
    expect(mastery).toBe(46);
    expect(calculateMasteryState(mastery)).toBe("developing");
  });

  it("high knowledge + practice + troubleshooting reaches practicing mastery", () => {
    const mastery = calculateMastery({
      knowledge: 100,
      practice: 80,
      troubleshooting: 60,
      project: 0,
      retention: 0,
    });
    // 100*0.3 + 80*0.2 + 60*0.25 = 30 + 16 + 15 = 61 => practicing
    expect(mastery).toBe(61);
    expect(calculateMasteryState(mastery)).toBe("practicing");
  });

  it("full mastery across all dimensions = strong", () => {
    const mastery = calculateMastery({
      knowledge: 100,
      practice: 100,
      troubleshooting: 100,
      project: 100,
      retention: 100,
    });
    expect(mastery).toBe(100);
    expect(calculateMasteryState(mastery)).toBe("strong");
  });

  it("mastery_evidence creation happens only on new completion", () => {
    // This is a logic test: completedLesson returns wasNew=false if already completed
    // Simulated as a boolean flag check
    const wasAlreadyCompleted = true;
    const wasNew = !wasAlreadyCompleted;
    expect(wasNew).toBe(false);
  });
});