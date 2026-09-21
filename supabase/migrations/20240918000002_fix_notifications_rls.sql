-- Migration: 20240918000002_fix_notifications_rls.sql

-- Drop the overly permissive policy
DROP POLICY IF EXISTS "Service role has full access" ON public.notifications;

-- Recreate it for service_role only
CREATE POLICY "Service role has full access"
    ON public.notifications FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);
