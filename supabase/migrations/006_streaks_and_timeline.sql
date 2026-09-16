-- 006_streaks_and_timeline.sql

-- 1. Add streak tracking to profiles
alter table public.profiles
  add column if not exists current_streak integer not null default 0,
  add column if not exists longest_streak integer not null default 0,
  add column if not exists last_activity_date date;

-- 2. Create activity logs table for the timeline/heatmap
create table if not exists public.user_activity_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_type text not null,
  details jsonb default '{}'::jsonb,
  activity_date date not null default current_date,
  created_at timestamptz not null default now()
);

-- Index for fast querying by user and date (for heatmap)
create index if not exists idx_user_activity_logs_user_date on public.user_activity_logs(user_id, activity_date);

-- Enable RLS
alter table public.user_activity_logs enable row level security;

-- Policies
create policy "Users can view their own activity logs"
  on public.user_activity_logs
  for select
  using (auth.uid() = user_id);

create policy "Users can insert their own activity logs"
  on public.user_activity_logs
  for insert
  with check (auth.uid() = user_id);
