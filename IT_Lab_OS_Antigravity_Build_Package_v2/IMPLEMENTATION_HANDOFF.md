# Implementation Handoff

## Exact instruction to give Antigravity

Read the entire IT Lab OS Antigravity Build Package v2 before coding.

Then:
1. Inspect the existing repository and identify what is already implemented.
2. Create a phase/status matrix against the package's Definition of Done.
3. Start at the first incomplete phase only.
4. Preserve working code and data.
5. Implement the phase completely before moving to the next.
6. Run lint, typecheck, tests, and production build after each major phase.
7. If a test or build fails, diagnose the root cause, fix it, and rerun the relevant verification.
8. Do not substitute mock data for missing backend functionality.
9. Do not weaken RLS or authentication to make a feature work.
10. Do not expose quiz answer keys or server secrets.
11. Never execute learner commands on the application host.
12. At the end, produce an evidence-based implementation report with commands run and results.

## Stop conditions requiring human input
Ask the user only for:
- credentials/secret values that cannot be inferred
- destructive or irreversible production actions
- billing decisions
- a genuine product decision that cannot be resolved from the specifications

Do not ask for confirmation for normal implementation choices covered by the package.
