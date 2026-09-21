/**
 * lib/troubleshooting/engine.ts
 *
 * Server-only orchestration for the troubleshooting simulator.
 * Loads scenarios from the DB, runs commands against the state machine,
 * manages attempts, records mastery evidence, and updates skill progress.
 *
 * NO REAL COMMANDS ARE EXECUTED — this is a deterministic simulator.
 */
import { getAdminClient } from "@/lib/supabase/admin";
import { createClient } from "@/lib/supabase/server";
import {
  matchesCommand,
  resolveCommandResponse,
} from "./stateMachine";
import { maxAvailableLevel, pickHint, type HintBundle } from "./hints";
import { scoreAttempt } from "./scoring";
import { upsertSkillProgress } from "@/lib/learning/progress";
import type {
  AttemptState,
  CommandRun,
  CommandResult,
  Scenario,
  Transition,
  StateDefinition,
} from "./types";

/* -------------------------------------------------------------------------- */
/*  Loading                                                                   */
/* -------------------------------------------------------------------------- */

/**
 * Normalise a DB scenario row into the engine's strict `Scenario` shape.
 * Defensive: handles missing JSON columns by substituting safe defaults.
 */
export function normaliseScenario(row: ScenRow): Scenario {
  const statesJson: Record<string, StateDefinition> =
    isJsonObject(row.states) ? (row.states as Record<string, StateDefinition>) : {};
  const transitionsJson: Transition[] = Array.isArray(row.transitions)
    ? (row.transitions as Transition[])
    : [];
  const hintsJson: string[] = Array.isArray(row.hints)
    ? (row.hints as unknown as string[])
    : [];
  const allowedJson: string[] = Array.isArray(row.allowed_commands)
    ? (row.allowed_commands as unknown as string[])
    : [];
  const scoringRulesJson = isJsonObject(row.scoring_rules)
    ? (row.scoring_rules as Scenario["scoringRules"])
    : {};

  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    description: row.description ?? "",
    difficulty: row.difficulty ?? "beginner",
    skillId: row.skill_id ?? null,
    initialStateKey: row.initial_state ?? "default",
    allowedCommands: allowedJson,
    states: statesJson,
    transitions: transitionsJson,
    hints: hintsJson,
    rootCause: row.root_cause ?? "",
    repairAction: row.repair_action ?? "",
    verification: typeof row.verification === "string" ? row.verification : "",
    runnerType: (row.runner_type as "deterministic" | "webcontainer") ?? "deterministic",
    webcontainerFs: row.webcontainer_fs ?? null,
    scoringRules: scoringRulesJson,
  };
}

function isJsonObject(v: unknown): v is Record<string, unknown> {
  return !!v && typeof v === "object" && !Array.isArray(v);
}

/** Subset of DB columns we need. */
interface ScenRow {
  id: string;
  slug: string;
  title: string;
  description: string | null;
  difficulty: string | null;
  skill_id: string | null;
  initial_state: string | null;
  allowed_commands: unknown;
  states: unknown;
  transitions: unknown;
  hints: unknown;
  root_cause: string | null;
  repair_action: string | null;
  verification: unknown;
  scoring_rules: unknown;
  runner_type: string | null;
  webcontainer_fs: unknown;
}

/**
 * Load a single scenario by slug. Server-side only.
 * Uses the regular client because the RLS policy makes published scenarios
 * publicly readable to authenticated users.
 */
export async function loadScenarioBySlug(slug: string): Promise<Scenario | null> {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("troubleshooting_scenarios")
    .select(
      "id, slug, title, description, difficulty, skill_id, initial_state, allowed_commands, states, transitions, hints, root_cause, repair_action, verification, scoring_rules, runner_type, webcontainer_fs",
    )
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  if (error || !data) return null;
  return normaliseScenario(data as ScenRow);
}

/**
 * List all published scenarios. Lightweight — only public-facing columns.
 */
export async function listScenarios(): Promise<
  Array<{
    slug: string;
    title: string;
    description: string;
    difficulty: string;
    skillId: string | null;
  }>
> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("troubleshooting_scenarios")
    .select("slug, title, description, difficulty, skill_id")
    .eq("is_published", true)
    .order("title");
  return (data ?? []).map((r) => ({
    slug: r.slug,
    title: r.title,
    description: r.description ?? "",
    difficulty: r.difficulty ?? "beginner",
    skillId: r.skill_id ?? null,
  }));
}

/* -------------------------------------------------------------------------- */
/*  Attempt lifecycle                                                         */
/* -------------------------------------------------------------------------- */

/**
 * Start a new attempt for the given user + scenario. Returns the attempt id
 * and initial empty live state.
 *
 * Writes with the service-role client: `troubleshooting_attempts` is
 * server-authoritative (migration 009 revokes learner INSERT/UPDATE), so a
 * learner cannot forge a resolved attempt or a score. `userId` always comes
 * from the verified session held by the calling route handler, never from the
 * request body.
 */
export async function startAttempt(
  userId: string,
  scenarioSlug: string,
): Promise<{ attemptId: string; state: AttemptState; scenario: Scenario } | null> {
  const admin = getAdminClient();
  const scenario = await loadScenarioBySlug(scenarioSlug);
  if (!scenario) return null;

  const initial: AttemptState = {
    currentStateKey: scenario.initialStateKey,
    commandsRun: [],
    hintsUsed: 0,
    diagnosis: null,
    attemptedFix: null,
  };

  const { data, error } = await admin
    .from("troubleshooting_attempts")
    .insert({
      user_id: userId,
      scenario_id: scenario.id,
      current_state: initial as unknown as import("@/lib/database.types").Json,
      commands_run: [] as unknown as import("@/lib/database.types").Json,
      hints_used: 0,
      root_cause_identified: false,
      resolved: false,
    })
    .select("id")
    .single();

  if (error || !data) return null;
  return { attemptId: data.id, state: initial, scenario };
}

/**
 * Hydrate an existing attempt from the DB into the live AttemptState shape.
 */
function hydrate(row: AttemptRow): AttemptState {
  const current =
    isJsonObject(row.current_state) && row.current_state
      ? (row.current_state as unknown as AttemptState)
      : { currentStateKey: "default", commandsRun: [], hintsUsed: 0, diagnosis: null, attemptedFix: null };

  return {
    currentStateKey: current.currentStateKey ?? "default",
    commandsRun: Array.isArray(current.commandsRun) ? current.commandsRun : [],
    hintsUsed: typeof current.hintsUsed === "number" ? current.hintsUsed : row.hints_used,
    diagnosis: current.diagnosis ?? null,
    attemptedFix: current.attemptedFix ?? null,
  };
}

interface AttemptRow {
  id: string;
  user_id: string;
  scenario_id: string;
  current_state: unknown;
  commands_run: unknown;
  hints_used: number;
  diagnosis: string | null;
  attempted_fix: string | null;
  verification_result: unknown;
  root_cause_identified: boolean;
  resolved: boolean;
  score: number | null;
}

/**
 * Run a command against the live state machine.
 *
 * SECURITY:
 *  - Only allows commands present in `scenario.allowedCommands`.
 *  - Uses the authoritative `transitions` table first, then falls back to
 *    canned state output.
 *  - Never spawns a subprocess.
 */
export async function runCommand(args: {
  userId: string;
  attemptId: string;
  command: string;
}): Promise<{ result: CommandResult; attemptId: string } | null> {
  const supabase = await createClient();
  const admin = getAdminClient();

  // Load the attempt (RLS ensures users only see their own)
  const { data: attemptRow, error: aErr } = await supabase
    .from("troubleshooting_attempts")
    .select("*")
    .eq("id", args.attemptId)
    .maybeSingle();

  if (aErr || !attemptRow) return null;
  if (attemptRow.user_id !== args.userId) return null;

  // Resolve the scenario from scenario_id
  const { data: scenRow, error: sErr } = await supabase
    .from("troubleshooting_scenarios")
    .select("id, slug")
    .eq("id", attemptRow.scenario_id)
    .maybeSingle();

  if (sErr || !scenRow) return null;
  const scenario = await loadScenarioBySlug(scenRow.slug);
  if (!scenario) return null;

  const state = hydrate(attemptRow as AttemptRow);

  // Run the deterministic command response.
  const result = matchesCommand(args.command, "")
    ? { status: "denied" as const, output: "Empty command", nextStateKey: state.currentStateKey, resolved: state.currentStateKey === "resolved" }
    : resolveCommandResponse(scenario, state.currentStateKey, args.command);

  const newRun: CommandRun = {
    command: args.command,
    output: result.output,
    status: result.status,
    timestamp: new Date().toISOString(),
  };

  const newState: AttemptState = {
    ...state,
    currentStateKey: result.nextStateKey,
    commandsRun: [...state.commandsRun, newRun],
  };

  // Persist via admin to bypass the missing UPDATE policy for resolved field.
  await admin
    .from("troubleshooting_attempts")
    .update({
      current_state: newState as unknown as import("@/lib/database.types").Json,
      commands_run: newState.commandsRun as unknown as import("@/lib/database.types").Json,
      resolved: newState.currentStateKey === "resolved",
    })
    .eq("id", args.attemptId);

  return { result, attemptId: args.attemptId };
}

/**
 * Request the next hint. Increments `hintsUsed` and returns the hint bundle.
 */
export async function requestHint(args: {
  userId: string;
  attemptId: string;
}): Promise<HintBundle | null> {
  const supabase = await createClient();
  const admin = getAdminClient();

  const { data: row } = await supabase
    .from("troubleshooting_attempts")
    .select("*, troubleshooting_scenarios(slug)")
    .eq("id", args.attemptId)
    .maybeSingle();

  if (!row) return null;
  if (row.user_id !== args.userId) return null;

  const slug = (row as unknown as { troubleshooting_scenarios?: { slug: string } }).troubleshooting_scenarios?.slug;
  if (!slug) return null;

  const scenario = await loadScenarioBySlug(slug);
  if (!scenario) return null;

  const state = hydrate(row as AttemptRow);
  const nextLevel = Math.min(state.hintsUsed + 1, maxAvailableLevel(scenario.hints));
  if (nextLevel <= state.hintsUsed) {
    // Already exhausted
    return pickHint(scenario.hints, state.hintsUsed as 1 | 2 | 3 | 4 | 5);
  }

  const bundle = pickHint(scenario.hints, nextLevel as 1 | 2 | 3 | 4 | 5);
  if (!bundle) return null;

  const newState: AttemptState = { ...state, hintsUsed: nextLevel };

  await admin
    .from("troubleshooting_attempts")
    .update({
      current_state: newState as unknown as import("@/lib/database.types").Json,
      hints_used: newState.hintsUsed,
    })
    .eq("id", args.attemptId);

  return bundle;
}

/**
 * Finish the attempt. Records the learner's diagnosis / attempted fix and
 * computes the deterministic score. Writes `mastery_evidence` and updates
 * `user_skill_progress.troubleshooting_score`.
 *
 * Returns `null` if the attempt doesn't belong to the user.
 */
export async function finishAttempt(args: {
  userId: string;
  attemptId: string;
  diagnosis?: string;
  attemptedFix?: string;
  clientVerificationResult?: { passed: boolean; rootCauseIdentified: boolean };
}): Promise<{ score: number; rootCauseIdentified: boolean; resolved: boolean } | null> {
  const supabase = await createClient();
  const admin = getAdminClient();

  const { data: row } = await supabase
    .from("troubleshooting_attempts")
    .select("*, troubleshooting_scenarios(slug)")
    .eq("id", args.attemptId)
    .maybeSingle();

  if (!row) return null;
  if (row.user_id !== args.userId) return null;

  const scenarioRow = (row as unknown as { troubleshooting_scenarios?: { slug: string } }).troubleshooting_scenarios;
  if (!scenarioRow) return null;

  const scenario = await loadScenarioBySlug(scenarioRow.slug);
  if (!scenario) return null;

  const state = hydrate(row as AttemptRow);
  const finalState: AttemptState = {
    ...state,
    diagnosis: args.diagnosis?.trim() || state.diagnosis,
    attemptedFix: args.attemptedFix?.trim() || state.attemptedFix,
  };

  // WebContainer scenarios execute their verification in the browser, so the
  // server cannot replay it and has to accept the client's verdict. That
  // concession is scoped strictly to those scenarios: for deterministic
  // scenarios the client verdict is ignored entirely and `resolved` remains a
  // function of the server-held state machine.
  const clientVerified =
    scenario.runnerType === "webcontainer" ? args.clientVerificationResult : undefined;

  const resolved = clientVerified
    ? clientVerified.passed
    : finalState.currentStateKey === "resolved";

  // The client verdict is passed INTO the standard scorer rather than applied
  // to its output, so it cannot mint score beyond the weighted maximum and the
  // final value stays clamped to 0–100.
  const score = scoreAttempt({
    scenario,
    state: finalState,
    diagnosis: finalState.diagnosis,
    attemptedFix: finalState.attemptedFix,
    resolved,
    clientRootCauseIdentified: clientVerified?.rootCauseIdentified,
  });

  const now = new Date().toISOString();

  // Persist via admin (RLS UPDATE policy exists, but only sets own row; admin keeps it simple).
  await admin
    .from("troubleshooting_attempts")
    .update({
      diagnosis: finalState.diagnosis,
      attempted_fix: finalState.attemptedFix,
      verification_result: { passed: resolved } as unknown as import("@/lib/database.types").Json,
      root_cause_identified: score.rootCauseIdentified,
      resolved,
      score: score.score,
      current_state: finalState as unknown as import("@/lib/database.types").Json,
      completed_at: now,
    })
    .eq("id", args.attemptId);

  // Record mastery evidence + update user_skill_progress
  if (scenario.skillId) {
    await admin.from("mastery_evidence").insert({
      user_id: args.userId,
      skill_id: scenario.skillId,
      evidence_type: "troubleshooting",
      source_id: args.attemptId,
      score: score.score,
      metadata: {
        scenario_slug: scenario.slug,
        root_cause_identified: score.rootCauseIdentified,
        resolved,
      },
    });

    await upsertSkillProgress(args.userId, scenario.skillId, {
      troubleshooting_score: score.score,
    });
  }

  return {
    score: score.score,
    rootCauseIdentified: score.rootCauseIdentified,
    resolved,
  };
}
