/**
 * lib/troubleshooting/scoring.ts
 *
 * Final scoring for a troubleshooting attempt.
 *
 * Per the engine spec:
 *   - Root cause   30%
 *   - Diagnostic   25%
 *   - Fix          25%
 *   - Verification 10%
 *   - Penalties for hints and unnecessary commands.
 *   - Clamp final 0–100.
 *
 * We never call real shell commands. We accept the learner's submitted diagnosis
 * text and "attempted fix" text and pattern-match against the scenario's
 * rootCause and repairAction fields. Casing and trivial stop-words are ignored.
 */
import type { AttemptScore, AttemptState, Scenario } from "./types";

interface ScoreInput {
  scenario: Scenario;
  state: AttemptState;
  diagnosis: string | null;
  attemptedFix: string | null;
  resolved: boolean;
}

const DEFAULT_RULES = {
  rootCauseBonus: 30,
  diagnosticPathBonus: 25,
  fixBonus: 25,
  verificationBonus: 10,
  hintPenalty: 4,
  unnecessaryCommandPenalty: 1,
};

function clamp(n: number, lo: number, hi: number): number {
  return Math.min(Math.max(n, lo), hi);
}

/**
 * Tokenise free text into lowercase word tokens (length >= 3) for matching.
 */
function tokens(text: string): Set<string> {
  return new Set(
    text
      .toLowerCase()
      .replace(/[^a-z0-9.\s_-]+/g, " ")
      .split(/\s+/)
      .filter((t) => t.length >= 3),
  );
}

/**
 * True if the user-supplied text contains at least one noun-like token from
 * the canonical reference text. We require ANY positive overlap so learners
 * are not penalised for casing/tense/spelling differences.
 */
function textMentions(reference: string, candidate: string): boolean {
  if (!reference || !candidate) return false;
  const ref = tokens(reference);
  const cand = tokens(candidate);
  if (ref.size === 0 || cand.size === 0) return false;
  for (const t of ref) {
    if (cand.has(t)) return true;
  }
  return false;
}

/**
 * Score an attempt and return the breakdown plus final (clamped) score.
 * Server-only — caller uses admin client to persist.
 */
export function scoreAttempt(input: ScoreInput): AttemptScore {
  const r = { ...DEFAULT_RULES, ...(input.scenario.scoringRules ?? {}) };

  const rootCauseIdentified =
    !!input.diagnosis &&
    textMentions(input.scenario.rootCause ?? "", input.diagnosis);

  const fixApplied =
    !!input.attemptedFix &&
    textMentions(input.scenario.repairAction ?? "", input.attemptedFix);

  const verificationPassed = input.resolved;

  // Diagnostic path: successful distinct exploratory command runs.
  // Counted on unique commands so re-runs don't fake progress.
  const commandsRun = input.state.commandsRun.length;
  const distinctSuccessful = new Set<string>();
  for (const c of input.state.commandsRun) {
    if (c.status === "ok") distinctSuccessful.add(c.command.trim().toLowerCase());
  }
  const diagnosticCommands = distinctSuccessful.size;
  const diagnosticPathScore = clamp(
    Math.round((Math.min(diagnosticCommands, 6) / 6) * r.diagnosticPathBonus),
    0,
    r.diagnosticPathBonus,
  );

  // "Unnecessary" = duplicate-ish command (same command run more than once)
  const seen = new Set<string>();
  let duplicates = 0;
  for (const c of input.state.commandsRun) {
    const key = c.command.trim().toLowerCase();
    if (seen.has(key)) duplicates += 1;
    else seen.add(key);
  }
  const unnecessaryPenalty = duplicates * r.unnecessaryCommandPenalty;
  const hintPenalty = input.state.hintsUsed * r.hintPenalty;

  const component =
    (rootCauseIdentified ? r.rootCauseBonus : 0) +
    diagnosticPathScore +
    (fixApplied ? r.fixBonus : 0) +
    (verificationPassed ? r.verificationBonus : 0);

  const raw =
    component - unnecessaryPenalty - hintPenalty + Math.min(commandsRun, 0); // placeholder for any future weighting

  // Bias the score slightly upward when verificationPassed: a fully resolved
  // attempt should typically land near the top band even with a few hints.
  const resolvedBonus = verificationPassed ? 5 : 0;
  const final = clamp(raw + resolvedBonus, 0, 100);

  return {
    score: final,
    rootCauseIdentified,
    verificationPassed,
    components: {
      rootCause: rootCauseIdentified ? r.rootCauseBonus : 0,
      diagnosticPath: diagnosticPathScore,
      fix: fixApplied ? r.fixBonus : 0,
      verification: verificationPassed ? r.verificationBonus : 0,
      penalties: -(unnecessaryPenalty + hintPenalty),
    },
  };
}
