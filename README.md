# IT Lab OS

A personal technical learning operating system. Learn → Practice → Test → Troubleshoot → Build → Review.

## Stack
- Next.js 20+ App Router · TypeScript (strict) · Tailwind CSS v4 · shadcn/ui
- Supabase Auth + PostgreSQL + RLS + Storage
- Zod · React Hook Form · Vitest · Playwright

## Quick start

```bash
cp .env.example .env.local
# Fill in .env.local with your Supabase and AI credentials
npm install
npm run dev
```

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ | Supabase anon/public key |
| `SUPABASE_SERVICE_ROLE_KEY` | ✅ | Server-only service role key |
| `AI_API_KEY` | ✅ | AI provider API key |
| `AI_MODEL` | ✅ | Model identifier (e.g. `gpt-4o`) |
| `AI_BASE_URL` | ✅ | AI provider base URL |
| `INTEGRATION_API_KEY` | ✅ | Webhook auth key for n8n/Hermes |

## Database

Apply the migrations in `supabase/migrations/` in order in the Supabase SQL Editor:

| Migration | Purpose |
|---|---|
| `001_core_schema.sql` | 26 tables, RLS policies |
| `002_indexes_and_triggers.sql` | Indexes and profile trigger |
| `002_profile_trigger.sql` | Profile auto-creation on signup |
| `003_curriculum_content.sql` | Domains, skills, lessons, practice, quizzes seed |
| `003_feature_indexes.sql` | Indexes for notes/projects/troubleshooting |
| `004_practice_evidence.sql` | Structured practice evidence keys |
| `005_troubleshooting_scenarios.sql` | Troubleshooting scenario seed |

## Build phases

| Phase | Description | Status |
|---|---|---|
| 0 | Inspect | ✅ Complete |
| 1 | Foundation | ✅ Complete |
| 2 | Supabase | ✅ Complete |
| 3 | Onboarding | ✅ Complete |
| 4 | Curriculum | ✅ Complete |
| 5 | Learning Engine | ✅ Complete |
| 6 | Dashboard | ✅ Complete |
| 7 | Daily Missions | ✅ Complete |
| 8 | Troubleshooting Simulator | ✅ Complete |
| 9 | AI Mentor | ✅ Complete |
| 10 | Projects + Notes | ✅ Complete |
| 11 | Progress | 🔄 Partial (analytics exist; timeline/streaks pending) |
| 12 | QA / Security | 🔄 Partial (unit + integration done; E2E/a11y pending) |
| 13 | Production Readiness | ⏳ Pending |

## Verification

```bash
npm run typecheck   # tsc --noEmit
npm run lint        # eslint
npm test            # vitest run (unit + integration)
npm run build       # next build
```

Current state: 126 tests passing (90 unit, 36 integration), 39 routes compiled.
