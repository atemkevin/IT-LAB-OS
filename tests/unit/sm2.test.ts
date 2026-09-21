import { describe, it, expect } from "vitest";
import {
  calculateSM2,
  calculateDecayedRetention,
  scoreToSM2Grade,
  isReviewDue,
  type SM2State,
} from "@/lib/spaced-repetition/sm2";

describe("SM-2 Spaced Repetition Algorithm", () => {
  const initialState: SM2State = {
    repetitionCount: 0,
    intervalDays: 1,
    easinessFactor: 2.5,
  };

  describe("scoreToSM2Grade", () => {
    it("maps percentages to grades accurately", () => {
      expect(scoreToSM2Grade(100)).toBe(5);
      expect(scoreToSM2Grade(90)).toBe(5);
      expect(scoreToSM2Grade(85)).toBe(4);
      expect(scoreToSM2Grade(75)).toBe(4);
      expect(scoreToSM2Grade(70)).toBe(3);
      expect(scoreToSM2Grade(60)).toBe(3);
      expect(scoreToSM2Grade(50)).toBe(2);
      expect(scoreToSM2Grade(30)).toBe(1);
      expect(scoreToSM2Grade(0)).toBe(0);
    });
  });

  describe("calculateSM2 - Interval progression", () => {
    it("sets interval to 1 on first successful recall (repetition 0 -> 1)", () => {
      const now = new Date("2026-01-01T00:00:00Z");
      const result = calculateSM2(initialState, 5, now);

      expect(result.repetitionCount).toBe(1);
      expect(result.intervalDays).toBe(1);
      expect(result.easinessFactor).toBe(2.6); // 2.5 + (0.1 - 0) = 2.6
      expect(result.retentionScore).toBe(100);
      expect(result.nextReviewDue.toISOString()).toBe("2026-01-02T00:00:00.000Z");
    });

    it("sets interval to 6 on second successful recall (repetition 1 -> 2)", () => {
      const state: SM2State = {
        repetitionCount: 1,
        intervalDays: 1,
        easinessFactor: 2.6,
      };
      const now = new Date("2026-01-02T00:00:00Z");
      const result = calculateSM2(state, 4, now);

      expect(result.repetitionCount).toBe(2);
      expect(result.intervalDays).toBe(6);
      expect(result.easinessFactor).toBe(2.6); // grade 4 delta is 0
      expect(result.nextReviewDue.toISOString()).toBe("2026-01-08T00:00:00.000Z");
    });

    it("multiplies interval by EF on third and subsequent recalls", () => {
      const state: SM2State = {
        repetitionCount: 2,
        intervalDays: 6,
        easinessFactor: 2.5,
      };
      const now = new Date("2026-01-08T00:00:00Z");
      const result = calculateSM2(state, 5, now);

      expect(result.repetitionCount).toBe(3);
      // 6 * 2.6 = 15.6 -> 16
      expect(result.intervalDays).toBe(16);
      expect(result.easinessFactor).toBe(2.6);
    });

    it("resets repetition to 0 and interval to 1 on failed recall (grade < 3)", () => {
      const state: SM2State = {
        repetitionCount: 5,
        intervalDays: 30,
        easinessFactor: 2.4,
      };
      const now = new Date("2026-02-01T00:00:00Z");
      const result = calculateSM2(state, 2, now);

      expect(result.repetitionCount).toBe(0);
      expect(result.intervalDays).toBe(1);
      // EF decreases on failure
      expect(result.easinessFactor).toBeLessThan(2.4);
      expect(result.retentionScore).toBe(40);
      expect(result.nextReviewDue.toISOString()).toBe("2026-02-02T00:00:00.000Z");
    });

    it("never allows easiness factor to drop below 1.3", () => {
      let state: SM2State = {
        repetitionCount: 0,
        intervalDays: 1,
        easinessFactor: 1.35,
      };

      // Fail multiple times with grade 0
      for (let i = 0; i < 5; i++) {
        const res = calculateSM2(state, 0);
        state = {
          repetitionCount: res.repetitionCount,
          intervalDays: res.intervalDays,
          easinessFactor: res.easinessFactor,
        };
      }

      expect(state.easinessFactor).toBe(1.3);
    });
  });

  describe("calculateDecayedRetention - Forgetting curve", () => {
    const lastReviewed = new Date("2026-01-01T00:00:00Z");
    const intervalDays = 10;
    const initialRetention = 100;

    it("returns initial retention immediately after review", () => {
      const retention = calculateDecayedRetention(initialRetention, intervalDays, lastReviewed, lastReviewed);
      expect(retention).toBe(100);
    });

    it("decays retention as time progresses toward scheduled interval", () => {
      // 5 days elapsed (half interval)
      const t5 = new Date("2026-01-06T00:00:00Z");
      const r5 = calculateDecayedRetention(initialRetention, intervalDays, lastReviewed, t5);
      expect(r5).toBeLessThan(100);
      expect(r5).toBeGreaterThan(75);

      // 10 days elapsed (exact interval)
      const t10 = new Date("2026-01-11T00:00:00Z");
      const r10 = calculateDecayedRetention(initialRetention, intervalDays, lastReviewed, t10);
      expect(r10).toBeLessThan(r5);
      expect(r10).toBeGreaterThan(60);

      // 30 days elapsed (3x interval, severely overdue)
      const t30 = new Date("2026-01-31T00:00:00Z");
      const r30 = calculateDecayedRetention(initialRetention, intervalDays, lastReviewed, t30);
      expect(r30).toBeLessThan(r10);
      expect(r30).toBeGreaterThanOrEqual(10); // Floor is 10
    });
  });

  describe("isReviewDue", () => {
    it("correctly flags when current date reaches or passes due date", () => {
      const due = new Date("2026-01-05T12:00:00Z");
      const before = new Date("2026-01-05T11:59:59Z");
      const exact = new Date("2026-01-05T12:00:00Z");
      const after = new Date("2026-01-06T00:00:00Z");

      expect(isReviewDue(due, before)).toBe(false);
      expect(isReviewDue(due, exact)).toBe(true);
      expect(isReviewDue(due, after)).toBe(true);
    });
  });
});
