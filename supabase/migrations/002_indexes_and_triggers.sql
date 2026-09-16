-- ============================================================
-- Migration 002: Performance indexes and updated_at triggers
-- ============================================================

-- ── Indexes on hot query paths ──

-- Published content lookups (most frequent reads)
create index if not exists idx_skills_domain_published on public.skills(domain_id, is_published);
create index if not exists idx_skills_slug on public.skills(slug);
create index if not exists idx_lessons_skill_published on public.lessons(skill_id, is_published);
create index if not exists idx_lesson_sections_lesson on public.lesson_sections(lesson_id);
create index if not exists idx_practice_tasks_skill on public.practice_tasks(skill_id);
create index if not exists idx_quiz_questions_skill on public.quiz_questions(skill_id);
create index if not exists idx_troubleshooting_scenarios_skill on public.troubleshooting_scenarios(skill_id);

-- User-scoped progress tables (heavily queried per authenticated user)
create index if not exists idx_user_skill_progress_user on public.user_skill_progress(user_id);
create index if not exists idx_user_skill_progress_skill on public.user_skill_progress(skill_id);
create index if not exists idx_user_lesson_progress_user on public.user_lesson_progress(user_id);
create index if not exists idx_user_lesson_progress_lesson on public.user_lesson_progress(lesson_id);
create index if not exists idx_practice_attempts_user on public.practice_attempts(user_id);
create index if not exists idx_quiz_attempts_user on public.quiz_attempts(user_id);
create index if not exists idx_troubleshooting_attempts_user on public.troubleshooting_attempts(user_id);
create index if not exists idx_user_project_progress_user on public.user_project_progress(user_id);
create index if not exists idx_mastery_evidence_user on public.mastery_evidence(user_id);
create index if not exists idx_learning_sessions_user on public.learning_sessions(user_id);
create index if not exists idx_daily_missions_user_date on public.daily_missions(user_id, mission_date);
create index if not exists idx_notes_user on public.notes(user_id);
create index if not exists idx_ai_conversations_user on public.ai_conversations(user_id);
create index if not exists idx_ai_messages_conversation on public.ai_messages(conversation_id);

-- Prerequisite lookups
create index if not exists idx_skill_prerequisites_skill on public.skill_prerequisites(skill_id);

-- Domain ordering
create index if not exists idx_domains_sort on public.domains(sort_order);

-- ── Auto-update updated_at trigger ──

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply trigger to all tables with updated_at column
do $$
declare
  tbl text;
  tables text[] := array[
    'profiles',
    'user_lesson_progress',
    'user_project_progress',
    'user_skill_progress',
    'notes',
    'ai_conversations',
    'ai_messages',
    'daily_missions'
  ];
begin
  foreach tbl in array tables loop
    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = tbl and column_name = 'updated_at'
    ) then
      execute format(
        'create trigger if not exists trg_%I_updated_at before update on public.%I for each row execute function public.set_updated_at();',
        tbl, tbl
      );
    end if;
  end loop;
end;
$$;
