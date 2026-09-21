-- 010_lock_quiz_practice_attempts.sql
--
-- Closes direct learner write paths on quiz_attempts, practice_attempts,
-- and user_project_progress to guarantee server-authoritative scoring.
--
-- Backend route handlers (gradeQuiz, evaluatePracticeEvidence, and /api/projects/[slug]/progress)
-- write via the service-role client (getAdminClient()), so learner grants are unnecessary
-- and permit bypassing server-side grading.

revoke insert, update, delete on public.quiz_attempts from authenticated, anon;
revoke insert, update, delete on public.practice_attempts from authenticated, anon;
revoke insert, update, delete on public.user_project_progress from authenticated, anon;
