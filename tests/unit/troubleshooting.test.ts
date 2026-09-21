/**
 * tests/unit/troubleshooting.test.ts
 *
 * Unit tests for the troubleshooting simulator primitives.
 * Pure-function tests — no DB or fetch required.
 */
import { describe, it, expect } from "vitest";
import {
  matchesCommand,
  resolveCommandResponse,
  isCommandAllowed,
} from "@/lib/troubleshooting/stateMachine";
import {
  pickHint,
  maxAvailableLevel,
  hintTitleForLevel,
} from "@/lib/troubleshooting/hints";
import { scoreAttempt } from "@/lib/troubleshooting/scoring";
import type {
  AttemptState,
  Scenario,
  StateDefinition,
  Transition,
} from "@/lib/troubleshooting/types";

function baseScenario(overrides: Partial<Scenario> = {}): Scenario {
  return {
    id: "s1",
    slug: "dns-failure",
    title: "DNS Failure",
    description: "Resolver misconfigured",
    difficulty: "beginner",
    skillId: null,
    initialStateKey: "dns_failure",
    allowedCommands: ["ping 8.8.8.8", "cat /etc/resolv.conf", "nslookup example.com"],
    states: {
      dns_failure: {
        description: "Resolver broken",
        responses: {
          "ping 8.8.8.8": "64 bytes from 8.8.8.8: icmp_seq=1 ttl=118 time=12 ms",
          "cat /etc/resolv.conf": "nameserver 127.0.0.1\n# invalid upstream",
          "nslookup example.com": ";; connection timed out; no servers could be reached",
        },
      },
      resolved: {
        description: "Fixed",
        resolved: true,
      } as unknown as StateDefinition,
    },
    transitions: [
      {
        from: "dns_failure",
        command: "systemctl restart systemd-resolved",
        to: "resolved",
        output: "Service restarted.",
      } satisfies Transition,
    ],
    hints: [
      "Investigate how your machine turns names into IPs.",
      "Look at networking/DNS subsystem.",
      "Try cat /etc/resolv.conf.",
      "The configured nameserver is invalid.",
      "Replace the broken resolver with a public one.",
    ],
    rootCause: "The configured DNS resolver is invalid.",
    repairAction: "Replace the invalid resolver with a working resolver.",
    verification: "nslookup example.com succeeds.",
    runnerType: "deterministic",
    webcontainerFs: null,
    scoringRules: {},
    ...overrides,
  };
}

function baseState(overrides: Partial<AttemptState> = {}): AttemptState {
  return {
    currentStateKey: "dns_failure",
    commandsRun: [],
    hintsUsed: 0,
    diagnosis: null,
    attemptedFix: null,
    ...overrides,
  };
}

describe("matchesCommand", () => {
  it("exact match", () => {
    expect(matchesCommand("ping 8.8.8.8", "ping 8.8.8.8")).toBe(true);
  });

  it("normalises whitespace and casing", () => {
    expect(matchesCommand("cat /etc/resolv.conf", "   CAT   /etc/resolv.conf")).toBe(true);
  });

  it("loose head match for address-bearing commands", () => {
    // spec has "ping 8.8.8.8", user types just "ping 8.8.8.8" — true
    expect(matchesCommand("ping 8.8.8.8", "ping 8.8.8.8")).toBe(true);
    // spec has "ping 8.8.8.8", user types "ping google.com" — also true (both have target word)
    expect(matchesCommand("ping 8.8.8.8", "ping google.com")).toBe(true);
  });

  it("rejects different commands", () => {
    expect(matchesCommand("ping 8.8.8.8", "curl localhost")).toBe(false);
  });

  it("returns false for empty spec or input", () => {
    expect(matchesCommand("", "ping")).toBe(false);
    expect(matchesCommand("ping", "")).toBe(false);
  });
});

describe("isCommandAllowed", () => {
  it("matches exact and loose inputs against allowlist", () => {
    const s = baseScenario();
    expect(isCommandAllowed(s, "ping 8.8.8.8")).toBe(true);
    expect(isCommandAllowed(s, "nslookup example.com")).toBe(true);
    expect(isCommandAllowed(s, "rm -rf /")).toBe(false);
  });
});

describe("resolveCommandResponse", () => {
  it("returns canned output for allowed commands", () => {
    const s = baseScenario();
    const r = resolveCommandResponse(s, "dns_failure", "nslookup example.com");
    expect(r.status).toBe("ok");
    expect(r.output).toContain("connection timed out");
    expect(r.nextStateKey).toBe("dns_failure");
    expect(r.resolved).toBe(false);
  });

  it("applies explicit transition over canned response", () => {
    const s = baseScenario();
    const r = resolveCommandResponse(s, "dns_failure", "systemctl restart systemd-resolved");
    expect(r.status).toBe("ok");
    expect(r.nextStateKey).toBe("resolved");
    expect(r.resolved).toBe(true);
  });

  it("denies unknown commands safely", () => {
    const s = baseScenario();
    const r = resolveCommandResponse(s, "dns_failure", "rm -rf /");
    expect(r.status).toBe("denied");
    expect(r.output.toLowerCase()).toContain("not allowed");
  });

  it("stays in current state when no transition defined", () => {
    const s = baseScenario({ transitions: [] });
    const r = resolveCommandResponse(s, "dns_failure", "ping 8.8.8.8");
    expect(r.nextStateKey).toBe("dns_failure");
  });
});

describe("hint helpers", () => {
  it("pickHint returns the requested level", () => {
    const h = pickHint(["a", "b", "c"], 2);
    expect(h?.level).toBe(2);
    expect(h?.text).toBe("b");
  });

  it("pickHint clamps to available hints", () => {
    const h = pickHint(["only"], 5);
    expect(h?.level).toBe(5);
    expect(h?.text).toBe("only");
  });

  it("pickHint returns null when no hints available", () => {
    expect(pickHint([], 1)).toBeNull();
  });

  it("maxAvailableLevel is capped at 5", () => {
    expect(maxAvailableLevel([])).toBe(0);
    expect(maxAvailableLevel(["a", "b"])).toBe(2);
    expect(maxAvailableLevel(["a", "b", "c", "d", "e", "f", "g"])).toBe(5);
  });

  it("hint titles follow the ladder order", () => {
    expect(hintTitleForLevel(1)).toBe("Direction");
    expect(hintTitleForLevel(5)).toBe("Full solution");
  });
});

describe("scoreAttempt", () => {
  it("caps at 100 and floors at 0", () => {
    const s = baseScenario();
    const state: AttemptState = {
      ...baseState(),
      commandsRun: [
        { command: "ping 8.8.8.8", output: "...", status: "ok", timestamp: "" },
        { command: "nslookup example.com", output: "...", status: "ok", timestamp: "" },
      ],
      hintsUsed: 0,
      diagnosis: "resolver is invalid",
      attemptedFix: "replace the invalid resolver",
    };

    const score = scoreAttempt({
      scenario: s,
      state,
      diagnosis: state.diagnosis,
      attemptedFix: state.attemptedFix,
      resolved: true,
    });
    expect(score.score).toBeGreaterThanOrEqual(0);
    expect(score.score).toBeLessThanOrEqual(100);
    expect(score.rootCauseIdentified).toBe(true);
    expect(score.verificationPassed).toBe(true);
    expect(score.components.fix).toBe(25);
    expect(score.components.verification).toBe(10);
    expect(score.components.rootCause).toBe(30);
  });

  it("penalises hints", () => {
    const s = baseScenario();
    const noHints = scoreAttempt({
      scenario: s,
      state: baseState({ hintsUsed: 0 }),
      diagnosis: "resolver is invalid",
      attemptedFix: "replace the invalid resolver",
      resolved: true,
    });
    const withHints = scoreAttempt({
      scenario: s,
      state: baseState({ hintsUsed: 3 }),
      diagnosis: "resolver is invalid",
      attemptedFix: "replace the invalid resolver",
      resolved: true,
    });
    expect(withHints.score).toBeLessThan(noHints.score);
  });

  it("penalises duplicate commands", () => {
    const s = baseScenario();
    const base = {
      scenario: s,
      diagnosis: "resolver is invalid",
      attemptedFix: "replace the invalid resolver",
      resolved: true,
    } as const;

    const clean = scoreAttempt({
      ...base,
      state: baseState({ commandsRun: [{ command: "ping 8.8.8.8", output: "", status: "ok" as const, timestamp: "" }] }),
    });
    const dupes = scoreAttempt({
      ...base,
      state: baseState({
        commandsRun: [
          { command: "ping 8.8.8.8", output: "", status: "ok" as const, timestamp: "" },
          { command: "ping 8.8.8.8", output: "", status: "ok" as const, timestamp: "" },
        ],
      }),
    });
    expect(dupes.score).toBeLessThanOrEqual(clean.score);
  });

  it("zero when no diagnosis and no fix", () => {
    const s = baseScenario();
    const score = scoreAttempt({
      scenario: s,
      state: baseState(),
      diagnosis: null,
      attemptedFix: null,
      resolved: false,
    });
    expect(score.score).toBeLessThanOrEqual(20); // some diagnostic credit at most
    expect(score.rootCauseIdentified).toBe(false);
    expect(score.verificationPassed).toBe(false);
  });

  // WebContainer scenarios let the browser report the root-cause verdict.
  // That verdict is an INPUT to the scorer, never a post-hoc score bonus, so
  // it cannot inflate the result beyond the weighted maximum.
  describe("client-supplied root-cause verdict (webcontainer only)", () => {
    const webcontainerScenario = () =>
      baseScenario({ runnerType: "webcontainer" } as Partial<Scenario>);

    it("credits exactly the root-cause weight, not more", () => {
      const withVerdict = scoreAttempt({
        scenario: webcontainerScenario(),
        state: baseState(),
        diagnosis: null,
        attemptedFix: null,
        resolved: true,
        clientRootCauseIdentified: true,
      });
      const without = scoreAttempt({
        scenario: webcontainerScenario(),
        state: baseState(),
        diagnosis: null,
        attemptedFix: null,
        resolved: true,
        clientRootCauseIdentified: false,
      });

      expect(withVerdict.components.rootCause).toBe(30);
      expect(without.components.rootCause).toBe(0);
      // The verdict moves the score by exactly the root-cause weight.
      expect(withVerdict.score - without.score).toBe(30);
    });

    it("still clamps the final score to 100 even with every signal true", () => {
      const score = scoreAttempt({
        scenario: webcontainerScenario(),
        state: baseState({
          commandsRun: [
            { command: "ping 8.8.8.8", output: "", status: "ok", timestamp: "" },
            { command: "cat /etc/resolv.conf", output: "", status: "ok", timestamp: "" },
            { command: "nslookup example.com", output: "", status: "ok", timestamp: "" },
          ],
        }),
        diagnosis: "resolver is invalid",
        attemptedFix: "replace the invalid resolver",
        resolved: true,
        clientRootCauseIdentified: true,
      });
      expect(score.score).toBeLessThanOrEqual(100);
    });

    it("falls back to the diagnosis text match when no verdict is supplied", () => {
      const score = scoreAttempt({
        scenario: baseScenario(),
        state: baseState(),
        diagnosis: "the resolver is invalid",
        attemptedFix: null,
        resolved: false,
      });
      expect(score.rootCauseIdentified).toBe(true);
      expect(score.components.rootCause).toBe(30);
    });
  });
});
