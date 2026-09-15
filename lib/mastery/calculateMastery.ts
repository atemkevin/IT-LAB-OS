import type { MasteryState } from "@/lib/database.types";

/**
 * Mastery engine — server-only.
 *
 * Weights per spec (01_PRD.md):
 *   Knowledge 30% + Practice 20% + Troubleshooting 25% + Project 15% + Retention 10%
 */
const WEIGHTS = {
  knowledge: 0.3,
  practice: 0.2,
  troubleshooting: 0.25,
  project: 0.15,
  retention: 0.1,
} as const;

export interface MasteryDimensions {
  knowledge: number;
  practice: number;
  troubleshooting: number;
  project: number;
  retention: number;
}

/**
 * Calculate the weighted mastery score from individual dimensions.
 * Each dimension is clamped to 0–100. Result is clamped to 0–100.
 *
 * @param dims - Raw dimension scores (0–100 each)
 * @returns Overall mastery score 0–100
 */
export function calculateMastery(dims: MasteryDimensions): number {
  const clamped: MasteryDimensions = {
    knowledge: clampDim(dims.knowledge),
    practice: clampDim(dims.practice),
    troubleshooting: clampDim(dims.troubleshooting),
    project: clampDim(dims.project),
    retention: clampDim(dims.retention),
  };

  const raw =
    clamped.knowledge * WEIGHTS.knowledge +
    clamped.practice * WEIGHTS.practice +
    clamped.troubleshooting * WEIGHTS.troubleshooting +
    clamped.project * WEIGHTS.project +
    clamped.retention * WEIGHTS.retention;

  return Math.round(Math.min(Math.max(raw, 0), 100) * 100) / 100;
}

function clampDim(value: number): number {
  return Math.min(Math.max(value, 0), 100);
}

/**
 * Map a mastery score to its state label.
 *
 * Boundaries per spec (01_PRD.md):
 *   0–29   Not Started
 *   30–49  Developing
 *   50–69  Practicing
 *   70–84  Proficient
 *   85–100 Strong
 */
export function calculateMasteryState(score: number): MasteryState {
  if (score >= 85) return "strong";
  if (score >= 70) return "proficient";
  if (score >= 50) return "practicing";
  if (score >= 30) return "developing";
  return "not_started";
}

/**
 * Human-readable label for a mastery state.
 */
export const MASTERY_LABELS: Record<MasteryState, string> = {
  not_started: "Not Started",
  developing: "Developing",
  practicing: "Practicing",
  proficient: "Proficient",
  strong: "Strong",
};

/**
 * CSS color variable for a mastery state.
 */
export const MASTERY_COLORS: Record<MasteryState, string> = {
  not_started: "var(--color-mastery-not-started)",
  developing: "var(--color-mastery-developing)",
  practicing: "var(--color-mastery-practicing)",
  proficient: "var(--color-mastery-proficient)",
  strong: "var(--color-mastery-strong)",
};
