/**
 * tests/unit/prerequisites.test.ts
 * Unit tests for prerequisite resolution and skill access state logic.
 */
import { describe, it, expect } from "vitest";
import { arePrerequisitesMet, getSkillAccessState } from "@/lib/learning/prerequisites";
import type { UserSkillProgress } from "@/lib/database.types";

function makeProgress(overrides: Partial<UserSkillProgress> = {}): UserSkillProgress {
  return {
    user_id: "user-1",
    skill_id: "skill-1",
    knowledge_score: 0,
    practice_score: 0,
    troubleshooting_score: 0,
    project_score: 0,
    retention_score: 0,
    mastery_score: 0,
    mastery_state: "not_started",
    confidence: 0,
    attempt_count: 0,
    last_activity_at: null,
    last_reviewed_at: null,
    updated_at: new Date().toISOString(),
    ...overrides,
  };
}

describe("arePrerequisitesMet", () => {
  it("returns true when there are no prerequisites", () => {
    const progressMap = new Map<string, UserSkillProgress>();
    expect(arePrerequisitesMet([], progressMap)).toBe(true);
  });

  it("returns false when prerequisite has no user progress", () => {
    const prereqs = [{ prerequisite_skill_id: "skill-A", required_mastery: 50 }];
    const progressMap = new Map<string, UserSkillProgress>();
    expect(arePrerequisitesMet(prereqs, progressMap)).toBe(false);
  });

  it("returns false when prerequisite mastery is below required", () => {
    const prereqs = [{ prerequisite_skill_id: "skill-A", required_mastery: 70 }];
    const progressMap = new Map<string, UserSkillProgress>();
    progressMap.set("skill-A", makeProgress({ skill_id: "skill-A", mastery_score: 60 }));
    expect(arePrerequisitesMet(prereqs, progressMap)).toBe(false);
  });

  it("returns true when prerequisite mastery meets required", () => {
    const prereqs = [{ prerequisite_skill_id: "skill-A", required_mastery: 50 }];
    const progressMap = new Map<string, UserSkillProgress>();
    progressMap.set("skill-A", makeProgress({ skill_id: "skill-A", mastery_score: 75 }));
    expect(arePrerequisitesMet(prereqs, progressMap)).toBe(true);
  });

  it("returns true when mastery exactly equals required", () => {
    const prereqs = [{ prerequisite_skill_id: "skill-A", required_mastery: 50 }];
    const progressMap = new Map<string, UserSkillProgress>();
    progressMap.set("skill-A", makeProgress({ skill_id: "skill-A", mastery_score: 50 }));
    expect(arePrerequisitesMet(prereqs, progressMap)).toBe(true);
  });

  it("returns false when one of multiple prerequisites is not met", () => {
    const prereqs = [
      { prerequisite_skill_id: "skill-A", required_mastery: 50 },
      { prerequisite_skill_id: "skill-B", required_mastery: 50 },
    ];
    const progressMap = new Map<string, UserSkillProgress>();
    progressMap.set("skill-A", makeProgress({ skill_id: "skill-A", mastery_score: 80 }));
    progressMap.set("skill-B", makeProgress({ skill_id: "skill-B", mastery_score: 20 }));
    expect(arePrerequisitesMet(prereqs, progressMap)).toBe(false);
  });

  it("returns true when all prerequisites are met", () => {
    const prereqs = [
      { prerequisite_skill_id: "skill-A", required_mastery: 50 },
      { prerequisite_skill_id: "skill-B", required_mastery: 50 },
    ];
    const progressMap = new Map<string, UserSkillProgress>();
    progressMap.set("skill-A", makeProgress({ skill_id: "skill-A", mastery_score: 80 }));
    progressMap.set("skill-B", makeProgress({ skill_id: "skill-B", mastery_score: 60 }));
    expect(arePrerequisitesMet(prereqs, progressMap)).toBe(true);
  });
});

describe("getSkillAccessState", () => {
  it("returns locked when prerequisites are not met", () => {
    expect(getSkillAccessState("skill-1", null, false)).toBe("locked");
  });

  it("returns available when prerequisites are met and no progress", () => {
    expect(getSkillAccessState("skill-1", null, true)).toBe("available");
  });

  it("returns available when mastery_score is 0", () => {
    const progress = makeProgress({ mastery_score: 0, mastery_state: "not_started" });
    expect(getSkillAccessState("skill-1", progress, true)).toBe("available");
  });

  it("returns in_progress for developing state", () => {
    const progress = makeProgress({ mastery_score: 35, mastery_state: "developing" });
    expect(getSkillAccessState("skill-1", progress, true)).toBe("in_progress");
  });

  it("returns practicing for practicing state", () => {
    const progress = makeProgress({ mastery_score: 55, mastery_state: "practicing" });
    expect(getSkillAccessState("skill-1", progress, true)).toBe("practicing");
  });

  it("returns proficient for proficient state", () => {
    const progress = makeProgress({ mastery_score: 75, mastery_state: "proficient" });
    expect(getSkillAccessState("skill-1", progress, true)).toBe("proficient");
  });

  it("returns strong for strong state", () => {
    const progress = makeProgress({ mastery_score: 90, mastery_state: "strong" });
    expect(getSkillAccessState("skill-1", progress, true)).toBe("strong");
  });

  it("ignores prerequisites when they are met", () => {
    const progress = makeProgress({ mastery_score: 90, mastery_state: "strong" });
    expect(getSkillAccessState("skill-1", progress, true)).toBe("strong");
  });
});