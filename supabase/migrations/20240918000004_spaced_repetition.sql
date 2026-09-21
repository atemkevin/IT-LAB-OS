-- Migration: 20240918000004_spaced_repetition.sql
-- Creates the spaced repetition items table and configures RLS for SM-2 scheduling.

CREATE TABLE IF NOT EXISTS public.spaced_repetition_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES public.skills(id) ON DELETE CASCADE,
    repetition_count INTEGER NOT NULL DEFAULT 0,
    interval_days INTEGER NOT NULL DEFAULT 1,
    easiness_factor NUMERIC(4,2) NOT NULL DEFAULT 2.50,
    retention_score NUMERIC(5,2) NOT NULL DEFAULT 100.00,
    last_reviewed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    next_review_due TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '1 day'),
    history JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_user_skill_review UNIQUE (user_id, skill_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_spaced_repetition_user_due 
    ON public.spaced_repetition_items(user_id, next_review_due ASC);

CREATE INDEX IF NOT EXISTS idx_spaced_repetition_user_skill 
    ON public.spaced_repetition_items(user_id, skill_id);

-- Enable RLS
ALTER TABLE public.spaced_repetition_items ENABLE ROW LEVEL SECURITY;

-- Security Policies
CREATE POLICY "Users can view their own spaced repetition items"
    ON public.spaced_repetition_items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own spaced repetition items"
    ON public.spaced_repetition_items FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role has full access to spaced repetition items"
    ON public.spaced_repetition_items FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);
