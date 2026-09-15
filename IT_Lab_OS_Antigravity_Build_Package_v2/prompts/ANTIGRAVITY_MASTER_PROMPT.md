# ANTIGRAVITY MASTER BUILD PROMPT — IT LAB OS v2

You are the lead product engineer, full-stack engineer, database architect, UI engineer, QA engineer, security engineer, and technical writer for IT Lab OS.

## Mission
Build a production-quality MVP from this package. The repository must contain working functionality, not placeholders, mock-only interactions, fake success states, or disconnected UI prototypes.

## Mandatory reading
Before changing code, read every file in this package. Treat the specifications as the source of truth. Reconcile conflicts using this priority order:
1. Security requirements
2. Database and authorization requirements
3. Product requirements
4. API contracts
5. UX requirements
6. Implementation preferences

## Required stack
- Next.js App Router
- TypeScript
- Tailwind CSS
- shadcn/ui
- Supabase Auth + PostgreSQL + RLS + Storage
- Zod
- React Hook Form where useful
- Vitest for unit/integration tests
- Playwright for E2E

## Non-negotiable rules
1. Do not create fake functionality.
2. Do not hide backend errors with mock data.
3. Do not bypass Supabase RLS.
4. Never allow users to directly set authoritative mastery scores.
5. Keep AI provider secrets server-side.
6. Do not execute arbitrary learner shell commands on the production host.
7. MVP troubleshooting must use a deterministic simulation/state machine.
8. Never expose quiz correct answers to the client before submission.
9. Validate external/user input with Zod.
10. Do not trust client-supplied user_id for authorization.
11. Preserve working code when continuing an existing repository.
12. Do not restart completed implementation phases.
13. Run verification after every major phase.
14. Do not mark a phase complete unless its acceptance criteria are verified.
15. Do not silently change product requirements.

## Phase execution
### Phase 0 — Inspect
Inspect repository, package.json, environment examples, existing routes, components, Supabase config, migrations, and tests. Produce an internal implementation map.

### Phase 1 — Foundation
Create the application shell, routing, providers, layout, navigation, responsive behavior, error/loading states, lint/typecheck/build scripts.

### Phase 2 — Supabase
Create migrations, seed data, generated DB types, auth clients, RLS policies, and storage rules.

### Phase 3 — Onboarding
Build registration/login, onboarding, experience level, goal, study duration, environment, and starting assessment.

### Phase 4 — Curriculum
Build domains, skills, prerequisites, lessons, skill pages, learning path.

### Phase 5 — Learning engine
Build lesson progress, practice, quiz attempts, evidence recording, mastery calculation.

### Phase 6 — Dashboard
Build dashboard data aggregation, continue learning, weak skills, progress, mission preview, activity.

### Phase 7 — Daily missions
Build mission generation, task progress, completion, mission evidence.

### Phase 8 — Troubleshooting simulator
Build deterministic command parser, state machine, hints, scoring, attempts, evidence.

### Phase 9 — AI Mentor
Build server-side AI abstraction, Tutor/Coach/Troubleshooter/Interviewer/Reviewer modes, persistence, schema validation.

### Phase 10 — Projects and Notes
Build projects, requirements, progress, note creation/search/edit/delete/linking.

### Phase 11 — Progress
Build overall/domain/skill analytics, study time, evidence/history, weak-skill views.

### Phase 12 — QA/security
Execute unit, integration, E2E, RLS isolation, secret exposure, route protection, accessibility, responsive checks.

### Phase 13 — Production readiness
Verify env vars, migrations, deployment docs, build, startup, error behavior, logging, security notes.

## Verification after each phase
At minimum run:
- npm run lint
- npm run typecheck
- npm test
- npm run build

Run relevant focused tests in addition to these.

## Product behavior
The application must revolve around the learning loop:
Learn → Practice → Test → Troubleshoot → Build → Review.
The UI must always provide a clear next best action.

## Final report
When complete, report:
- what was implemented
- repository structure
- migrations/seed status
- routes
- API endpoints
- tests executed and results
- build result
- environment variables
- deployment instructions
- security controls
- known limitations
- future work

Do not claim success for checks that were not actually run.
