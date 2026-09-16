-- ============================================================
-- Migration 003: Additional indexes for new feature query paths
-- ============================================================

-- Notes search (ilike on title + content_markdown)
create index if not exists idx_notes_user_pinned_updated on public.notes(user_id, pinned, updated_at desc);
create index if not exists idx_notes_title_lower on public.notes(lower(title));
create index if not exists idx_notes_content_lower on public.notes(lower(content_markdown));

-- Troubleshooting attempts: lookup by scenario + user (active attempt)
create index if not exists idx_troubleshooting_attempts_scenario_user on public.troubleshooting_attempts(scenario_id, user_id);

-- Troubleshooting attempts: find active (uncompleted) attempts
create index if not exists idx_troubleshooting_attempts_active on public.troubleshooting_attempts(user_id, scenario_id) where completed_at is null;

-- Mission task progress: lookup by mission
create index if not exists idx_mission_task_progress_mission on public.mission_task_progress(mission_id);

-- User project progress: lookup by project
create index if not exists idx_user_project_progress_project on public.user_project_progress(project_id);

-- Project requirements: ordered by sort_order per project
create index if not exists idx_project_requirements_project_order on public.project_requirements(project_id, sort_order);

-- Project skills: lookup by project
create index if not exists idx_project_skills_project on public.project_skills(project_id);
