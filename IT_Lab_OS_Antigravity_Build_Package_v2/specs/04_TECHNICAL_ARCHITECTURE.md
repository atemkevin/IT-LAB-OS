# IT Lab OS — Technical Architecture

## Architecture
Browser → Next.js App Router → Server Actions / Route Handlers → Supabase / AI Service / Integration APIs.

## Business logic
Authoritative business logic is server-side.

## Frontend
Next.js, TypeScript, React, Tailwind, shadcn/ui.

## Backend
Next.js Server Components, Server Actions, Route Handlers.

## Data
Supabase PostgreSQL + Auth + RLS + Storage.

## AI
Server-side provider abstraction. Never expose AI key to client.

## Integrations
IT Lab OS → HTTPS API/webhooks → n8n → Hermes/Telegram/etc.

## Future lab runner
Separate isolated infrastructure using ephemeral containers/VMs with CPU/memory/time/network/filesystem restrictions.

## Security
RLS, Zod validation, route protection, secure uploads, rate limiting for expensive endpoints, server-only secrets, audit logging.

## Performance
Prefer Server Components, paginate histories, cache published curriculum, avoid aggressive caching of user state.

## Error handling
Return structured errors with stable codes; never expose stack traces or secrets.
