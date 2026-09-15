# IT Lab OS — Security Notes

## Quiz answer protection
`quiz_options` contains `is_correct`, so ordinary authenticated clients must not have a SELECT policy on that table.

Server-side quiz code may use the Supabase service role to retrieve answer keys, evaluate submissions, and return only sanitized option/question data to the browser.

Never return `is_correct` in a learner-facing API response before submission.

## Mastery protection
No learner INSERT/UPDATE policy is provided for `user_skill_progress`. Mastery updates must be performed by trusted server-side logic/service-role operations after evidence is validated.

## Troubleshooting safety
The simulator must never invoke `child_process`, shell execution, remote SSH, Docker socket access, or arbitrary subprocesses for learner-entered commands. Treat commands as data and resolve them through the deterministic scenario engine.

## Secrets
Never prefix secrets with `NEXT_PUBLIC_`. In particular:
- SUPABASE_SERVICE_ROLE_KEY
- AI_API_KEY
- INTEGRATION_API_KEY

## Integration security
n8n/Hermes endpoints require a dedicated integration credential. Rotate it if exposed. Prefer signed requests/HMAC in a later hardening phase.
