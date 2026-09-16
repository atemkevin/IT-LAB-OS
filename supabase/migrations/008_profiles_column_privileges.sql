-- 008_profiles_column_privileges.sql
--
-- Makes server-authoritative profile fields genuinely server-authoritative.
--
-- Background: migration 007 attempted
--   revoke update (current_streak, ...) on public.profiles from authenticated;
-- which is a no-op in practice. Supabase grants table-level UPDATE to
-- `authenticated`, and a column-level REVOKE cannot remove a privilege that
-- was granted at table level. Verified empirically: a signed-in learner could
-- still PATCH current_streak to any value through PostgREST.
--
-- Correct approach: drop the table-level UPDATE grant entirely, then grant
-- UPDATE only on the columns a learner may legitimately edit.
--
-- Server-only columns locked down here:
--   current_streak, longest_streak, last_activity_date
--       -> written by public.record_daily_activity() (SECURITY DEFINER)
--   environment
--       -> holds onboarding assessment output (startingLevel, weakDomains,
--          recommendedFirstSkill, assessmentScore). Must not be learner-writable.
--   onboarding_done
--       -> set by the trusted /api/onboarding route.
--   id, created_at
--       -> immutable.

revoke update on public.profiles from authenticated, anon;

grant update (
  display_name,
  avatar_url,
  experience_level,
  daily_minutes,
  primary_goal,
  updated_at
) on public.profiles to authenticated;
