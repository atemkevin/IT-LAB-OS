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

Migrations live in `supabase/migrations/`. They are ordered by version, so
apply them in filename order — either with the CLI:

```bash
supabase link --project-ref <your-project-ref>
supabase db push
```

or by pasting each file into the Supabase SQL Editor.

| Migration | Purpose |
|---|---|
| `001_core_schema.sql` | Core tables and RLS policies |
| `002_indexes_and_triggers.sql` | Performance indexes and `updated_at` triggers |
| `003_curriculum_content.sql` | Domains, skills, lessons, practice, quizzes seed |
| `004_practice_evidence.sql` | Structured practice evidence keys |
| `005_troubleshooting_scenarios.sql` | Troubleshooting scenario seed |
| `006_streaks_and_timeline.sql` | `user_activity_logs`, profile streak columns |
| `007_streak_rpc.sql` | `record_daily_activity()` — atomic streak update |
| `008_profiles_column_privileges.sql` | Column-level grants; locks server-authoritative profile fields |
| `20240916000001_profile_trigger.sql` | Profile auto-creation on signup |
| `20240916000002_feature_indexes.sql` | Indexes for notes/projects/troubleshooting |

### Regenerating database types

`lib/database.types.ts` is generated, then merged with the hand-maintained
enums and Row aliases in `scripts/db-type-aliases.txt`:

```bash
bash scripts/regen-types.sh
```

Never hand-edit the generated region — the merge step will overwrite it.

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
| 11 | Progress | ✅ Complete |
| 12 | QA / Security | ✅ Complete |
| 13 | Production Readiness | ✅ Complete |

## Deployment

The project is configured for Vercel deployment and acts as a Progressive Web App (PWA).
1. Push the code to a GitHub repository.
2. Import the repository in [Vercel](https://vercel.com/).
3. Add the environment variables from `.env.local` to the Vercel project settings.
4. Deploy!

The CI/CD pipeline (`.github/workflows/ci.yml`) will automatically run tests on every push.

## Verification

```bash
npm run typecheck   # tsc --noEmit
npm run lint        # eslint
npm test            # vitest run (unit + integration)
npm run build       # next build
```

Current state: 126 tests passing (90 unit, 36 integration), 39 routes compiled.
