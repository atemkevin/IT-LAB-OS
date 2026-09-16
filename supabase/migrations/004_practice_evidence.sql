-- Migration 004: Practice Evidence Foundation
-- Adds structured evidence support to practice tasks and attempts.
-- Does NOT rewrite or modify migrations 001-003.

-- 1. Add evidence_keys to practice_tasks
-- This stores the ordered list of response key names the learner must address.
-- e.g. ["command_used", "output_observed", "explanation", "verification_result"]
-- Each key corresponds to a requirement.
ALTER TABLE public.practice_tasks
  ADD COLUMN IF NOT EXISTS evidence_keys jsonb NOT NULL DEFAULT '[]'::jsonb;

-- 2. Add skill_id to practice_attempts for audit/history
-- Denormalised for efficient "all attempts for a skill" queries.
ALTER TABLE public.practice_attempts
  ADD COLUMN IF NOT EXISTS skill_id uuid REFERENCES public.skills(id) ON DELETE SET NULL;

-- 3. Create index for efficient history lookup
CREATE INDEX IF NOT EXISTS practice_attempts_user_skill_idx
  ON public.practice_attempts (user_id, skill_id);

CREATE INDEX IF NOT EXISTS practice_attempts_user_task_idx
  ON public.practice_attempts (user_id, practice_task_id);

-- 4. Populate skill_id on existing practice_attempts from the related practice_tasks
UPDATE public.practice_attempts pa
SET skill_id = pt.skill_id
FROM public.practice_tasks pt
WHERE pa.practice_task_id = pt.id
  AND pa.skill_id IS NULL;

-- 5. Backfill evidence_keys for existing practice tasks from their requirements
-- Sets evidence_keys to an array of "req_1", "req_2", etc. matching requirement count
-- This gives existing tasks a default structured key set.
UPDATE public.practice_tasks
SET evidence_keys = (
  SELECT jsonb_agg('req_' || idx)
  FROM generate_series(1, jsonb_array_length(requirements)) AS idx
)
WHERE jsonb_array_length(requirements) > 0
  AND jsonb_array_length(evidence_keys) = 0;

COMMENT ON COLUMN public.practice_tasks.evidence_keys IS
  'Ordered list of response keys (e.g. ["req_1","req_2"]) matching requirements. Each key must have a non-empty response in a valid submission.';

COMMENT ON COLUMN public.practice_attempts.skill_id IS
  'Denormalised skill_id from practice_tasks for efficient history queries.';