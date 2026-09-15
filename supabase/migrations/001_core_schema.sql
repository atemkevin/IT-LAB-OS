create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  experience_level text,
  daily_minutes integer default 60 check (daily_minutes in (30,60,90,120)),
  primary_goal text,
  environment jsonb default '{}'::jsonb,
  onboarding_done boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.domains (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  description text,
  sort_order integer not null default 0,
  icon text,
  is_published boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.skills (
  id uuid primary key default gen_random_uuid(),
  domain_id uuid not null references public.domains(id) on delete cascade,
  slug text unique not null,
  name text not null,
  description text,
  why_it_matters text,
  difficulty text not null default 'beginner',
  estimated_minutes integer not null default 60,
  learning_objectives jsonb not null default '[]'::jsonb,
  tags jsonb not null default '[]'::jsonb,
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.skill_prerequisites (
  skill_id uuid not null references public.skills(id) on delete cascade,
  prerequisite_skill_id uuid not null references public.skills(id) on delete cascade,
  required_mastery numeric(5,2) not null default 70 check (required_mastery between 0 and 100),
  primary key (skill_id, prerequisite_skill_id)
);

create table if not exists public.lessons (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references public.skills(id) on delete cascade,
  slug text not null,
  title text not null,
  summary text,
  content_markdown text,
  difficulty text,
  estimated_minutes integer default 30,
  sort_order integer not null default 0,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  unique(skill_id, slug)
);

create table if not exists public.lesson_sections (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  section_type text not null,
  title text,
  content_markdown text,
  sort_order integer not null default 0
);

create table if not exists public.user_lesson_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  status text not null default 'not_started',
  progress numeric(5,2) not null default 0 check (progress between 0 and 100),
  started_at timestamptz,
  completed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key(user_id, lesson_id)
);

create table if not exists public.practice_tasks (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references public.skills(id) on delete cascade,
  title text not null,
  objective text,
  context text,
  requirements jsonb not null default '[]'::jsonb,
  success_criteria jsonb not null default '[]'::jsonb,
  hints jsonb not null default '[]'::jsonb,
  is_published boolean not null default true
);

create table if not exists public.practice_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  practice_task_id uuid not null references public.practice_tasks(id) on delete cascade,
  submission jsonb,
  feedback text,
  score numeric(5,2) check (score between 0 and 100),
  passed boolean,
  created_at timestamptz not null default now()
);

create table if not exists public.quiz_questions (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid not null references public.skills(id) on delete cascade,
  prompt text not null,
  question_type text not null default 'single',
  explanation text,
  sort_order integer not null default 0,
  is_published boolean not null default true
);

create table if not exists public.quiz_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.quiz_questions(id) on delete cascade,
  option_text text not null,
  is_correct boolean not null default false,
  sort_order integer not null default 0
);

create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_id uuid not null references public.skills(id) on delete cascade,
  answers jsonb not null,
  score numeric(5,2) not null check (score between 0 and 100),
  correct_count integer,
  question_count integer,
  created_at timestamptz not null default now()
);

create table if not exists public.troubleshooting_scenarios (
  id uuid primary key default gen_random_uuid(),
  skill_id uuid references public.skills(id) on delete set null,
  slug text unique not null,
  title text not null,
  description text,
  difficulty text,
  initial_state jsonb not null default '{}'::jsonb,
  allowed_commands jsonb not null default '[]'::jsonb,
  states jsonb not null default '{}'::jsonb,
  transitions jsonb not null default '[]'::jsonb,
  hints jsonb not null default '[]'::jsonb,
  root_cause text,
  repair_action text,
  verification jsonb not null default '{}'::jsonb,
  scoring_rules jsonb not null default '{}'::jsonb,
  is_published boolean not null default true
);

create table if not exists public.troubleshooting_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  scenario_id uuid not null references public.troubleshooting_scenarios(id) on delete cascade,
  current_state jsonb not null default '{}'::jsonb,
  commands_run jsonb not null default '[]'::jsonb,
  hints_used integer not null default 0,
  diagnosis text,
  attempted_fix text,
  verification_result jsonb,
  root_cause_identified boolean not null default false,
  resolved boolean not null default false,
  score numeric(5,2) check (score between 0 and 100),
  started_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  description text,
  difficulty text,
  estimated_minutes integer,
  prerequisites jsonb not null default '[]'::jsonb,
  deliverables jsonb not null default '[]'::jsonb,
  acceptance_criteria jsonb not null default '[]'::jsonb,
  is_published boolean not null default true
);

create table if not exists public.project_skills (
  project_id uuid not null references public.projects(id) on delete cascade,
  skill_id uuid not null references public.skills(id) on delete cascade,
  primary key(project_id, skill_id)
);

create table if not exists public.project_requirements (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  requirement text not null,
  sort_order integer not null default 0
);

create table if not exists public.user_project_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  status text not null default 'not_started',
  progress numeric(5,2) not null default 0 check (progress between 0 and 100),
  submission jsonb,
  updated_at timestamptz not null default now(),
  primary key(user_id, project_id)
);

create table if not exists public.user_skill_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_id uuid not null references public.skills(id) on delete cascade,
  knowledge_score numeric(5,2) not null default 0,
  practice_score numeric(5,2) not null default 0,
  troubleshooting_score numeric(5,2) not null default 0,
  project_score numeric(5,2) not null default 0,
  retention_score numeric(5,2) not null default 0,
  mastery_score numeric(5,2) not null default 0,
  mastery_state text not null default 'not_started',
  confidence numeric(5,2) not null default 0,
  attempt_count integer not null default 0,
  last_activity_at timestamptz,
  last_reviewed_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key(user_id, skill_id)
);

create table if not exists public.mastery_evidence (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_id uuid not null references public.skills(id) on delete cascade,
  evidence_type text not null,
  source_id uuid,
  score numeric(5,2) not null check (score between 0 and 100),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.learning_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  duration_seconds integer,
  source_type text,
  source_id uuid
);

create table if not exists public.daily_missions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mission_date date not null,
  duration_minutes integer not null,
  title text not null,
  objective text,
  context text,
  tasks jsonb not null default '[]'::jsonb,
  hints jsonb not null default '[]'::jsonb,
  success_criteria jsonb not null default '[]'::jsonb,
  reflection text,
  recommendation_reason text,
  status text not null default 'not_started',
  created_at timestamptz not null default now(),
  unique(user_id, mission_date)
);

create table if not exists public.mission_task_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  mission_id uuid not null references public.daily_missions(id) on delete cascade,
  task_key text not null,
  completed boolean not null default false,
  notes text,
  completed_at timestamptz,
  primary key(user_id, mission_id, task_key)
);

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  content_markdown text not null default '',
  tags jsonb not null default '[]'::jsonb,
  skill_id uuid references public.skills(id) on delete set null,
  lesson_id uuid references public.lessons(id) on delete set null,
  scenario_id uuid references public.troubleshooting_scenarios(id) on delete set null,
  project_id uuid references public.projects(id) on delete set null,
  pinned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ai_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  mode text not null,
  title text,
  context jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ai_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.ai_conversations(id) on delete cascade,
  role text not null,
  content text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.domains enable row level security;
alter table public.skills enable row level security;
alter table public.skill_prerequisites enable row level security;
alter table public.lessons enable row level security;
alter table public.lesson_sections enable row level security;
alter table public.user_lesson_progress enable row level security;
alter table public.practice_tasks enable row level security;
alter table public.practice_attempts enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_options enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.troubleshooting_scenarios enable row level security;
alter table public.troubleshooting_attempts enable row level security;
alter table public.projects enable row level security;
alter table public.project_skills enable row level security;
alter table public.project_requirements enable row level security;
alter table public.user_project_progress enable row level security;
alter table public.user_skill_progress enable row level security;
alter table public.mastery_evidence enable row level security;
alter table public.learning_sessions enable row level security;
alter table public.daily_missions enable row level security;
alter table public.mission_task_progress enable row level security;
alter table public.notes enable row level security;
alter table public.ai_conversations enable row level security;
alter table public.ai_messages enable row level security;

create policy "published domains readable" on public.domains for select using (is_published = true);
create policy "published skills readable" on public.skills for select using (is_published = true);
create policy "published lessons readable" on public.lessons for select using (is_published = true);
create policy "published lesson sections readable" on public.lesson_sections for select using (exists(select 1 from public.lessons l where l.id=lesson_id and l.is_published=true));
create policy "published practices readable" on public.practice_tasks for select using (is_published = true);
create policy "published quiz questions readable" on public.quiz_questions for select using (is_published = true);
-- INTENTIONAL: no SELECT policy on quiz_options. Because this table stores is_correct, learner clients must not query it directly.
-- Server-side quiz retrieval should use the Supabase service role, strip is_correct, and return only safe option fields to the client.
create policy "published scenarios readable" on public.troubleshooting_scenarios for select using (is_published = true);
create policy "published projects readable" on public.projects for select using (is_published = true);
create policy "project skills readable" on public.project_skills for select using (exists(select 1 from public.projects p where p.id=project_id and p.is_published=true));
create policy "project requirements readable" on public.project_requirements for select using (exists(select 1 from public.projects p where p.id=project_id and p.is_published=true));
create policy "prerequisites readable" on public.skill_prerequisites for select using (exists(select 1 from public.skills s where s.id=skill_id and s.is_published=true));

create policy "own profile" on public.profiles for select using (id=auth.uid());
create policy "update own profile" on public.profiles for update using (id=auth.uid()) with check (id=auth.uid());

create policy "own lesson progress" on public.user_lesson_progress for select using (user_id=auth.uid());
create policy "own lesson progress insert" on public.user_lesson_progress for insert with check (user_id=auth.uid());
create policy "own lesson progress update" on public.user_lesson_progress for update using (user_id=auth.uid()) with check (user_id=auth.uid());

create policy "own practice attempts" on public.practice_attempts for select using (user_id=auth.uid());
create policy "own practice attempts insert" on public.practice_attempts for insert with check (user_id=auth.uid());
create policy "own quiz attempts" on public.quiz_attempts for select using (user_id=auth.uid());
create policy "own quiz attempts insert" on public.quiz_attempts for insert with check (user_id=auth.uid());
create policy "own troubleshooting attempts" on public.troubleshooting_attempts for select using (user_id=auth.uid());
create policy "own troubleshooting attempts insert" on public.troubleshooting_attempts for insert with check (user_id=auth.uid());
create policy "own troubleshooting attempts update" on public.troubleshooting_attempts for update using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "own project progress" on public.user_project_progress for select using (user_id=auth.uid());
create policy "own project progress insert" on public.user_project_progress for insert with check (user_id=auth.uid());
create policy "own project progress update" on public.user_project_progress for update using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "own skill progress read" on public.user_skill_progress for select using (user_id=auth.uid());
create policy "own evidence read" on public.mastery_evidence for select using (user_id=auth.uid());
create policy "own learning sessions" on public.learning_sessions for select using (user_id=auth.uid());
create policy "own learning sessions insert" on public.learning_sessions for insert with check (user_id=auth.uid());
create policy "own missions" on public.daily_missions for select using (user_id=auth.uid());
create policy "own mission task progress" on public.mission_task_progress for select using (user_id=auth.uid());
create policy "own mission task progress insert" on public.mission_task_progress for insert with check (user_id=auth.uid());
create policy "own mission task progress update" on public.mission_task_progress for update using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "own notes" on public.notes for select using (user_id=auth.uid());
create policy "own notes insert" on public.notes for insert with check (user_id=auth.uid());
create policy "own notes update" on public.notes for update using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "own notes delete" on public.notes for delete using (user_id=auth.uid());
create policy "own AI conversations" on public.ai_conversations for select using (user_id=auth.uid());
create policy "own AI conversations insert" on public.ai_conversations for insert with check (user_id=auth.uid());
create policy "own AI conversations update" on public.ai_conversations for update using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "own AI messages" on public.ai_messages for select using (exists(select 1 from public.ai_conversations c where c.id=conversation_id and c.user_id=auth.uid()));
create policy "own AI messages insert" on public.ai_messages for insert with check (exists(select 1 from public.ai_conversations c where c.id=conversation_id and c.user_id=auth.uid()));
