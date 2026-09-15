import { describe, it, expect } from "vitest";
import {
  calculateMastery,
  calculateMasteryState,
  MASTERY_LABELS,
  type MasteryDimensions,
} from "@/lib/mastery/calculateMastery";

describe("Mastery Engine Formula (Phase 1 Baseline)", () => {
  it("calculates mastery accurately using spec weights (30/20/25/15/10)", () => {
    // Exact weights: knowledge 0.3, practice 0.2, troubleshooting 0.25, project 0.15, retention 0.1
    const dims: MasteryDimensions = {
      knowledge: 100,
      practice: 100,
      troubleshooting: 100,
      project: 100,
      retention: 100,
    };
    expect(calculateMastery(dims)).toBe(100);
  });

  it("calculates partial mastery correctly", () => {
    const dims: MasteryDimensions = {
      knowledge: 80, // 80 * 0.30 = 24
      practice: 70, // 70 * 0.20 = 14
      troubleshooting: 60, // 60 * 0.25 = 15
      project: 50, // 50 * 0.15 = 7.5
      retention: 40, // 40 * 0.10 = 4
    };
    // Sum = 24 + 14 + 15 + 7.5 + 4 = 64.5
    expect(calculateMastery(dims)).toBe(64.5);
  });

  it("clamps out-of-range values to [0, 100]", () => {
    const negativeDims: MasteryDimensions = {
      knowledge: -10,
      practice: -5,
      troubleshooting: 0,
      project: 0,
      retention: 0,
    };
    expect(calculateMastery(negativeDims)).toBe(0);

    const overflowDims: MasteryDimensions = {
      knowledge: 150,
      practice: 120,
      troubleshooting: 200,
      project: 105,
      retention: 100,
    };
    expect(calculateMastery(overflowDims)).toBe(100);
  });

  it("determines mastery states according to PRD thresholds", () => {
    // 0-29: not_started
    expect(calculateMasteryState(0)).toBe("not_started");
    expect(calculateMasteryState(29.9)).toBe("not_started");

    // 30-49: developing
    expect(calculateMasteryState(30)).toBe("developing");
    expect(calculateMasteryState(49.9)).toBe("developing");

    // 50-69: practicing
    expect(calculateMasteryState(50)).toBe("practicing");
    expect(calculateMasteryState(69.9)).toBe("practicing");

    // 70-84: proficient
    expect(calculateMasteryState(70)).toBe("proficient");
    expect(calculateMasteryState(84.9)).toBe("proficient");

    // 85-100: strong
    expect(calculateMasteryState(85)).toBe("strong");
    expect(calculateMasteryState(100)).toBe("strong");
  });

  it("provides correct labels for each state", () => {
    expect(MASTERY_LABELS["not_started"]).toBe("Not Started");
    expect(MASTERY_LABELS["developing"]).toBe("Developing");
    expect(MASTERY_LABELS["practicing"]).toBe("Practicing");
    expect(MASTERY_LABELS["proficient"]).toBe("Proficient");
    expect(MASTERY_LABELS["strong"]).toBe("Strong");
  });
});
