import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";

/**
 * ADMIN CLIENT — Service role, bypasses RLS.
 *
 * SECURITY RULES:
 * 1. Never import this file in any Client Component.
 * 2. Never expose it via API responses.
 * 3. Only use for:
 *    - Quiz answer evaluation (reading quiz_options.is_correct)
 *    - Writing mastery scores (user_skill_progress has no learner INSERT/UPDATE policy)
 *    - Writing mastery_evidence records
 *    - Seeding / migration tasks
 *    - Integration webhook handlers (with separate API key check)
 *
 * The service role key must NOT be prefixed with NEXT_PUBLIC_.
 */
function createAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !key) {
    throw new Error(
      "NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set",
    );
  }

  return createClient<Database>(url, key, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Singleton admin client.
 * Reuse across requests in the same server process.
 */
let adminClient: ReturnType<typeof createAdminClient> | undefined;

export function getAdminClient() {
  if (!adminClient) {
    adminClient = createAdminClient();
  }
  return adminClient;
}
