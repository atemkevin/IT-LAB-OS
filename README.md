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

Apply `supabase/migrations/001_core_schema.sql` in the Supabase SQL Editor before starting.

## Build phases

| Phase | Description | Status |
|---|---|---|
| 0 | Inspect | ✅ Complete |
| 1 | Foundation | 🔄 In Progress |
| 2 | Supabase | ⏳ Pending |
| 3 | Onboarding | ⏳ Pending |
| 4 | Curriculum | ⏳ Pending |
| 5 | Learning Engine | ⏳ Pending |
| 6 | Dashboard | ⏳ Pending |
| 7 | Daily Missions | ⏳ Pending |
| 8 | Troubleshooting Simulator | ⏳ Pending |
| 9 | AI Mentor | ⏳ Pending |
| 10 | Projects + Notes | ⏳ Pending |
| 11 | Progress | ⏳ Pending |
| 12 | QA / Security | ⏳ Pending |
| 13 | Production Readiness | ⏳ Pending |
