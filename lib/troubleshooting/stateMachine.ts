/**
 * lib/troubleshooting/stateMachine.ts
 *
 * Deterministic state-machine primitives for the troubleshooting simulator.
 * Pure functions — no DB, no I/O. Server-only use is fine, but the file itself
 * stays I/O-free so it can be tested in isolation.
 */
import type {
  CommandResult,
  Scenario,
  StateDefinition,
} from "./types";

/**
 * Resolve the response the engine should emit for a command in a given state.
 * Resolution order:
 *   1. Explicit `transitions` table — finds first matching `from + command`.
 *   2. State `responses[command]` fallback for canned output.
 *   3. Otherwise: denied ("command not allowed").
 *
 * The transition table is authoritative — if a transition exists for a
 * state+command pair, it overrides whatever canned output the state may have.
 * This lets scenarios vary behaviour over time without duplicating states.
 */
export function resolveCommandResponse(
  scenario: Scenario,
  stateKey: string,
  commandInput: string,
): CommandResult {
  const cmd = commandInput.trim();

  // 1. Try transition table
  for (const t of scenario.transitions ?? []) {
    if (t.from !== stateKey) continue;
    if (!matchesCommand(t.command, cmd)) continue;

    const nextState = t.to ?? stateKey;
    const stateDef: StateDefinition | undefined = scenario.states[nextState];
    return {
      status: "ok",
      output: t.output ?? stateDef?.description ?? "OK",
      nextStateKey: nextState,
      resolved: stateDef?.resolved === true,
    };
  }

  // 2. Canned response from current state
  const state = scenario.states[stateKey];
  if (state?.responses && Object.prototype.hasOwnProperty.call(state.responses, cmd)) {
    return {
      status: "ok",
      output: state.responses[cmd],
      nextStateKey: stateKey,
      resolved: state.resolved === true,
    };
  }

  // 3. Not allowed — generic safe denial
  return {
    status: "denied",
    output: `Command not allowed in this scenario: ${cmd}`,
    nextStateKey: stateKey,
    resolved: state?.resolved === true,
  };
}

/**
 * True if the scenario's `allowedCommands` whitelist contains the command.
 * Uses a generous prefix match: an entry like "ping 8.8.8.8" permits
 * "ping 8.8.8.8" exactly and also the bare "ping" form against the same target.
 */
export function isCommandAllowed(scenario: Scenario, commandInput: string): boolean {
  const cmd = commandInput.trim();
  return scenario.allowedCommands.some((allowed) => matchesCommand(allowed, cmd));
}

/**
 * True if the user-supplied command matches the scenario command spec.
 *
 * Matching rules:
 *   - If `spec` has no spaces, match exact equality.
 *   - If `spec` has an address-like target (e.g. "ping 8.8.8.8"), the user
 *     can supply a bare command ("ping") and it still qualifies as long as
 *     the command name and an address token is shared.
 *   - Whitespace is normalised.
 *
 * The match is intentionally narrow: we don't want free-form natural language,
 * but we also don't want to force users to type "ping 8.8.8.8" exactly when
 * they want just "ping".
 */
export function matchesCommand(spec: string, input: string): boolean {
  if (!spec) return false;
  const a = normaliseCommand(spec);
  const b = normaliseCommand(input);
  if (a === b) return true;

  // Head match: user typed the command name + one word, e.g. "ping 8.8.8.8"
  const aParts = a.split(/\s+/);
  const bParts = b.split(/\s+/);
  if (aParts[0] === bParts[0] && aParts.length >= 2 && bParts.length >= 2) {
    return true;
  }
  return false;
}

/**
 * Collapse runs of whitespace so "ping    8.8.8.8" === "ping 8.8.8.8".
 */
function normaliseCommand(input: string): string {
  return input.trim().replace(/\s+/g, " ").toLowerCase();
}
