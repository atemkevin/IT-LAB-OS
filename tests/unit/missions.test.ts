/**
 * tests/unit/missions.test.ts
 * Unit tests for the daily mission generation engine pure logic.
 */
import { describe, it, expect } from "vitest";
import { buildMissionTasks } from "@/lib/learning/missions";

describe("buildMissionTasks", () => {
  const lessons = [
    { id: "lesson-1", title: "Introduction" },
    { id: "lesson-2", title: "Intermediate Concepts" },
    { id: "lesson-3", title: "Advanced Topics" },
  ];

  const practiceTasks = [
    { id: "task-1", title: "Hands-on Drill" },
    { id: "task-2", title: "Practical Exercise" },
  ];

  it("generates lesson + practice + quiz tasks for a new learner (low scores)", () => {
    const tasks = buildMissionTasks(
      "Linux CLI",
      "Learn the command line",
      0,
      "not_started",
      0,
      0,
      lessons,
      practiceTasks,
    );

    expect(tasks).toHaveLength(3);
    expect(tasks[0].key).toBe("review-lesson");
    expect(tasks[0].title).toBe("Review: Introduction");
    expect(tasks[0].type).toBe("lesson");
    expect(tasks[1].key).toBe("practice-task");
    expect(tasks[1].title).toBe("Practice: Hands-on Drill");
    expect(tasks[1].type).toBe("practice");
    expect(tasks[2].key).toBe("take-quiz");
    expect(tasks[2].type).toBe("quiz");
  });

  it("selects the first lesson when knowledge score is below 50", () => {
    const tasks = buildMissionTasks(
      "Networking",
      "Network fundamentals",
      10,
      "developing",
      30,
      0,
      lessons,
      practiceTasks,
    );

    const lessonTask = tasks.find((t) => t.key === "review-lesson")!;
    expect(lessonTask.ref_id).toBe("lesson-1");
  });

  it("selects a later lesson when knowledge score is higher", () => {
    const tasks = buildMissionTasks(
      "Networking",
      "Network fundamentals",
      40,
      "developing",
      50,
      0,
      lessons,
      [],
    );

    const lessonTask = tasks.find((t) => t.key === "review-lesson")!;
    // knowledge=50 → Math.floor(50/50)=1 → lesson index 1 → lesson-2
    expect(lessonTask.ref_id).toBe("lesson-2");
  });

  it("selects the second lesson when knowledge score >= 50", () => {
    const tasks = buildMissionTasks(
      "Networking",
      "Network fundamentals",
      55,
      "practicing",
      55,
      0,
      lessons,
      [],
    );

    const lessonTask = tasks.find((t) => t.key === "review-lesson")!;
    expect(lessonTask.ref_id).toBe("lesson-2");
  });

  it("includes practice task when practice score is below 70", () => {
    const tasks = buildMissionTasks(
      "Linux CLI",
      "Learn the command line",
      30,
      "developing",
      50,
      40,
      lessons,
      practiceTasks,
    );

    expect(tasks.some((t) => t.key === "practice-task")).toBe(true);
  });

  it("excludes practice task when practice score >= 70", () => {
    const tasks = buildMissionTasks(
      "Linux CLI",
      "Learn the command line",
      60,
      "practicing",
      60,
      75,
      lessons,
      practiceTasks,
    );

    expect(tasks.some((t) => t.key === "practice-task")).toBe(false);
  });

  it("includes quiz task when mastery state is not strong", () => {
    const tasks = buildMissionTasks(
      "Linux CLI",
      "Learn the command line",
      80,
      "proficient",
      80,
      80,
      lessons,
      [],
    );

    expect(tasks.some((t) => t.key === "take-quiz")).toBe(true);
  });

  it("excludes quiz task when mastery state is strong", () => {
    const tasks = buildMissionTasks(
      "Linux CLI",
      "Learn the command line",
      90,
      "strong",
      90,
      90,
      lessons,
      [],
    );

    expect(tasks.some((t) => t.key === "take-quiz")).toBe(false);
  });

  it("generates only quiz task when no lessons or practice tasks exist and mastery is not strong", () => {
    const tasks = buildMissionTasks(
      "New Skill",
      "A brand new skill",
      0,
      "not_started",
      0,
      0,
      [],
      [],
    );

    // With no lessons, no practice tasks, and not strong → only quiz task
    expect(tasks).toHaveLength(1);
    expect(tasks[0].key).toBe("take-quiz");
  });

  it("generates explore fallback when skill is strong with no lessons or practice", () => {
    const tasks = buildMissionTasks(
      "New Skill",
      "A brand new skill",
      90,
      "strong",
      90,
      90,
      [],
      [],
    );

    // Strong skill, no lessons, no practice → quiz excluded, fallback explore added
    expect(tasks).toHaveLength(1);
    expect(tasks[0].key).toBe("explore-skill");
    expect(tasks[0].title).toBe("Explore: New Skill");
  });

  it("always generates at least one task", () => {
    const tasks = buildMissionTasks(
      "Test Skill",
      null,
      100,
      "strong",
      100,
      100,
      [],
      [],
    );

    expect(tasks.length).toBeGreaterThanOrEqual(1);
  });

  it("includes ref_id for lesson and practice tasks", () => {
    const tasks = buildMissionTasks(
      "Python Basics",
      "Learn Python",
      0,
      "not_started",
      0,
      0,
      lessons,
      practiceTasks,
    );

    const lessonTask = tasks.find((t) => t.key === "review-lesson");
    expect(lessonTask?.ref_id).toBeDefined();

    const practiceTask = tasks.find((t) => t.key === "practice-task");
    expect(practiceTask?.ref_id).toBeDefined();
  });

  it("does not include ref_id for quiz task", () => {
    const tasks = buildMissionTasks(
      "Python Basics",
      "Learn Python",
      0,
      "not_started",
      0,
      0,
      lessons,
      practiceTasks,
    );

    const quizTask = tasks.find((t) => t.key === "take-quiz");
    expect(quizTask?.ref_id).toBeUndefined();
  });

  it("includes skill name in lesson and quiz task descriptions", () => {
    const tasks = buildMissionTasks(
      "Docker Fundamentals",
      "Container basics",
      0,
      "not_started",
      0,
      0,
      lessons,
      practiceTasks,
    );

    const lessonTask = tasks.find((t) => t.key === "review-lesson");
    expect(lessonTask?.description).toContain("Docker Fundamentals");

    const quizTask = tasks.find((t) => t.key === "take-quiz");
    expect(quizTask?.description).toContain("Docker Fundamentals");
  });
});
