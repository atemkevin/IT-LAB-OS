/**
 * lib/troubleshooting/types.ts
 *
 * Shared type contracts for the troubleshooting simulator.
 * Server and client safe — no Supabase imports.
 */

import type { Json } from "@/lib/database.types";

/**
 * A normalised command entry stored in the attempt's `commands_run` array.
 * `output` is included for replay; `fromCache` indicates if the simulation
 * reused a previously-served response during a scroll back through history.
 */
export interface CommandRun {
  command: string;
  output: string;
  status: "ok" | "denied";
  timestamp: string;
}

/**
 * A single deterministic transition for a scenario.
 * Kept loose (loosely typed) because the DB stores JSON.
 */
export interface Transition {
  from: string;
  command: string; // pattern
  to: string;
  output?: string;
}

/**
 * Scenario state definition: a named world state plus canned command output.
 */
export interface StateDefinition {
  description?: string;
  responses?: Record<string, string>;
  resolved?: boolean;
}

/**
 * Authoritative normalised scenario as used by the engine.
 * The DB row is JSON-heavy, so we materialise into this strict shape.
 */
export interface Scenario {
  id: string;
  slug: string;
  title: string;
  description: string;
  difficulty: string;
  skillId: string | null;
  initialStateKey: string;
  allowedCommands: string[];
  states: Record<string, StateDefinition>;
  transitions: Transition[];
  hints: string[];
  rootCause: string;
  repairAction: string;
  verification: string;
  runnerType: "deterministic" | "webcontainer";
  webcontainerFs: any;
  scoringRules: {
    diagnosticPathBonus?: number;
    fixBonus?: number;
    verificationBonus?: number;
    rootCauseBonus?: number;
    hintPenalty?: number;
    unnecessaryCommandPenalty?: number;
  };
}

/**
 * Live engine state for an attempt.
 * Persisted as JSON on the troubleshooting_attempts row.
 */
export interface AttemptState {
  currentStateKey: string;
  commandsRun: CommandRun[];
  hintsUsed: number;
  diagnosis: string | null;
  attemptedFix: string | null;
}

/**
 * Result of evaluating a single command within a scenario.
 */
export interface CommandResult {
  status: "ok" | "denied";
  output: string;
  nextStateKey: string;
  resolved: boolean;
}

/**
 * Final scoring result of finishing an attempt.
 */
export interface AttemptScore {
  score: number;
  rootCauseIdentified: boolean;
  verificationPassed: boolean;
  components: {
    rootCause: number;
    diagnosticPath: number;
    fix: number;
    verification: number;
    penalties: number;
  };
}

/**
 * The repair-action detection patterns used by the scoring engine.
 * The engine doesn't execute real commands — the diagnosis / repair text is
 * matched against the scenario's intent to grant credit.
 */
export interface FinishResult {
  attemptId: string;
  score: AttemptScore;
}
