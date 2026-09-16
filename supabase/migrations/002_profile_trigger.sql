-- Allow users to insert their own profile
do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='profiles' and policyname='insert own profile'
  ) then
    create policy "insert own profile" on public.profiles
      for insert
      with check (id = auth.uid());
  end if;
end $$;

-- Trigger to automatically create profile row on user signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, onboarding_done)
  values (new.id, split_part(new.email, '@', 1), false)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
