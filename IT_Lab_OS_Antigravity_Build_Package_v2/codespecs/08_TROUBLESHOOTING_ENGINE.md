# IT Lab OS — Troubleshooting Engine

## Goal
Teach evidence-based diagnosis without exposing an unsafe real shell.

## Deterministic model
Scenario → Initial State → Allowed Commands → Output → State Transition → Repair → Verification.

## Supported commands for MVP
ping, ip addr, ip route, ss, systemctl status nginx, journalctl, curl, nslookup, cat, df, du.

## State machine requirements
- Unknown commands return a safe “command not allowed” response.
- Commands cannot execute OS processes.
- State transitions are explicit and testable.
- Each command is logged on the attempt.
- State is server-authoritative.

## Hint ladder
1 Direction
2 Subsystem
3 Useful command
4 Strong clue
5 Full solution

## Scoring
Root cause 30%
Diagnostic path 25%
Fix 25%
Verification 10%
Penalties for hints, unnecessary commands, repeated failed actions.
Clamp final score 0–100.

## Suggested file layout
lib/troubleshooting/engine.ts
lib/troubleshooting/stateMachine.ts
lib/troubleshooting/commandParser.ts
lib/troubleshooting/scoring.ts
lib/troubleshooting/hints.ts
lib/troubleshooting/types.ts
