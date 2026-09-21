-- Migration: 20240918000003_achievements.sql

-- 1. Create achievements table
CREATE TABLE IF NOT EXISTS public.achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Create user_achievements table
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, achievement_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON public.user_achievements(user_id);

-- 3. Seed some default achievements
INSERT INTO public.achievements (id, name, description, icon) VALUES
    ('first_lab', 'First Steps', 'Completed your first troubleshooting lab.', 'flask-conical'),
    ('streak_3', 'On a Roll', 'Maintained a 3-day learning streak.', 'flame'),
    ('streak_7', 'Unstoppable', 'Maintained a 7-day learning streak.', 'zap'),
    ('mastery_10', 'Apprentice', 'Earned 10 mastery points across skills.', 'award'),
    ('perfect_quiz', 'Flawless Victory', 'Aced a quiz with a 100% score.', 'check-circle')
ON CONFLICT (id) DO NOTHING;

-- 4. Enable RLS
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- 5. Policies
CREATE POLICY "Anyone can view achievements"
    ON public.achievements FOR SELECT
    USING (true);

CREATE POLICY "Users can view their own earned achievements"
    ON public.user_achievements FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Service role has full access to achievements"
    ON public.achievements FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Service role has full access to user_achievements"
    ON public.user_achievements FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);
