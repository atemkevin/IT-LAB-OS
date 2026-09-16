-- 007_streak_rpc.sql
--
-- Makes streak updates atomic and authoritative.
--
-- Rationale: the previous client-side compare-and-swap in
-- lib/learning/activity.ts had two defects:
--   1. PostgREST `.lt()` does not match NULL, so a brand-new learner's
--      first activity never started their streak (it stayed 0 forever).
--   2. The "reset" branch also reset longest_streak to 1, wiping the
--      learner's all-time record when they returned after a gap.
--
-- A single SECURITY DEFINER function runs the read-modify-write inside one
-- transaction with a row lock, so it is race-free and NULL-correct.
-- The date is supplied by the caller (the app computes it in local time),
-- keeping the streak calendar aligned with the learner's timezone.

create or replace function public.record_daily_activity(
  p_user_id uuid,
  p_today date
)
returns table (
  current_streak integer,
  longest_streak integer,
  last_activity_date date
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_prev    date;
  v_current integer;
  v_longest integer;
begin
  -- Lock the row so concurrent activity on the same day serialises.
  select p.last_activity_date, p.current_streak, p.longest_streak
    into v_prev, v_current, v_longest
  from public.profiles p
  where p.id = p_user_id
  for update;

  if not found then
    return;
  end if;

  -- Already counted today: no-op.
  if v_prev is not distinct from p_today then
    return query
      select coalesce(v_current, 0), coalesce(v_longest, 0), v_prev;
    return;
  end if;

  if v_prev = p_today - 1 then
    -- Consecutive calendar day.
    v_current := coalesce(v_current, 0) + 1;
  else
    -- First ever activity, or a gap of one or more days.
    v_current := 1;
  end if;

  -- Never lower the all-time record.
  v_longest := greatest(coalesce(v_longest, 0), v_current);

  update public.profiles
     set current_streak     = v_current,
         longest_streak     = v_longest,
         last_activity_date = p_today
   where id = p_user_id;

  return query select v_current, v_longest, p_today;
end;
$$;

revoke all on function public.record_daily_activity(uuid, date) from public;
grant execute on function public.record_daily_activity(uuid, date) to authenticated;

-- Streaks are now server-authoritative: learners may not set these columns
-- directly through PostgREST. The RPC above runs as the function owner and
-- is unaffected by this column-level revoke.
revoke update (current_streak, longest_streak, last_activity_date)
  on public.profiles from authenticated, anon;
