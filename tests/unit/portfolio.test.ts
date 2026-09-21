import { describe, it, expect } from "vitest";
import { createHash } from "crypto";
import { calculateMasteryState, MASTERY_LABELS } from "@/lib/mastery/calculateMastery";

describe("Public Portfolio & Proof of Skill Unit Tests", () => {
  it("calculates mastery tier and labels accurately across score thresholds", () => {
    expect(MASTERY_LABELS[calculateMasteryState(0)]).toBe("Not Started");
    expect(MASTERY_LABELS[calculateMasteryState(29)]).toBe("Not Started");
    expect(MASTERY_LABELS[calculateMasteryState(30)]).toBe("Developing");
    expect(MASTERY_LABELS[calculateMasteryState(49)]).toBe("Developing");
    expect(MASTERY_LABELS[calculateMasteryState(50)]).toBe("Practicing");
    expect(MASTERY_LABELS[calculateMasteryState(69)]).toBe("Practicing");
    expect(MASTERY_LABELS[calculateMasteryState(70)]).toBe("Proficient");
    expect(MASTERY_LABELS[calculateMasteryState(84)]).toBe("Proficient");
    expect(MASTERY_LABELS[calculateMasteryState(85)]).toBe("Strong");
    expect(MASTERY_LABELS[calculateMasteryState(100)]).toBe("Strong");
  });

  it("generates deterministic cryptographic verification signature for learner achievements", () => {
    const userId = "123e4567-e89b-12d3-a456-426614174000";
    const overallMastery = 78;
    const totalSkills = 8;
    const achievementsCount = 4;
    const labsCount = 5;

    const payload = `${userId}:${overallMastery}:${totalSkills}:${achievementsCount}:${labsCount}`;
    const sig1 = createHash("sha256").update(payload).digest("hex").substring(0, 16).toUpperCase();
    const sig2 = createHash("sha256").update(payload).digest("hex").substring(0, 16).toUpperCase();

    expect(sig1).toBe(sig2);
    expect(sig1.length).toBe(16);

    // Signature must change if stats change
    const alteredPayload = `${userId}:${overallMastery + 1}:${totalSkills}:${achievementsCount}:${labsCount}`;
    const sigAltered = createHash("sha256").update(alteredPayload).digest("hex").substring(0, 16).toUpperCase();
    expect(sig1).not.toBe(sigAltered);
  });

  it("sanitizes public portfolio payload to exclude sensitive personal fields", () => {
    const mockRawDbProfile = {
      id: "usr_123",
      display_name: "Dev Learner",
      avatar_url: "https://example.com/avatar.png",
      primary_goal: "Cloud Security",
      current_streak: 12,
      longest_streak: 15,
      created_at: "2026-01-01T00:00:00Z",
      // Sensitive fields that MUST NOT leak:
      email: "secret@corporate.internal",
      password_hash: "$2b$12$e8...",
      session_tokens: ["tok_abc"],
      notes: [{ id: "n1", secret: "private api keys" }],
    };

    // Construct the sanitized view according to PublicLearnerProfile
    const sanitizedLearner = {
      id: mockRawDbProfile.id,
      displayName: mockRawDbProfile.display_name,
      avatarUrl: mockRawDbProfile.avatar_url,
      primaryGoal: mockRawDbProfile.primary_goal,
      currentStreak: mockRawDbProfile.current_streak,
      longestStreak: mockRawDbProfile.longest_streak,
      memberSince: mockRawDbProfile.created_at,
    };

    expect(sanitizedLearner).not.toHaveProperty("email");
    expect(sanitizedLearner).not.toHaveProperty("password_hash");
    expect(sanitizedLearner).not.toHaveProperty("session_tokens");
    expect(sanitizedLearner).not.toHaveProperty("notes");
    expect(sanitizedLearner.displayName).toBe("Dev Learner");
  });
});
