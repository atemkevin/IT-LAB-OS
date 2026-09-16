/**
 * lib/troubleshooting/hints.ts
 *
 * 5-step hint ladder (per the engine spec).
 * Each step requires the prior to be used; a learner cannot skip ahead.
 */
export type HintLevel = 1 | 2 | 3 | 4 | 5;

export interface HintBundle {
  level: HintLevel;
  title: string;
  text: string;
}

/**
 * Return the appropriate hint bundle for the requested ladder level.
 * Caller is responsible for capping `level` against the number of authored hints.
 */
export function pickHint(
  scenarioHints: string[],
  level: HintLevel,
): HintBundle | null {
  if (level < 1 || level > 5) return null;
  const idx = Math.min(level - 1, scenarioHints.length - 1);
  const text = scenarioHints[idx];
  if (!text) return null;

  const title = hintTitleForLevel(level);
  return { level, title, text };
}

export function hintTitleForLevel(level: HintLevel): string {
  switch (level) {
    case 1:
      return "Direction";
    case 2:
      return "Subsystem";
    case 3:
      return "Useful command";
    case 4:
      return "Strong clue";
    case 5:
      return "Full solution";
  }
}

/**
 * The largest hint level the learner can request. Authored hints may be fewer
 * than 5; we return the clamped upper bound. Returns 0 if no hints exist.
 */
export function maxAvailableLevel(hints: string[]): number {
  if (hints.length === 0) return 0;
  return Math.min(5, hints.length);
}
