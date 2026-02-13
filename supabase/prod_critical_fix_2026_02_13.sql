-- Production critical fix - 2026-02-13
-- Run in Supabase SQL Editor (Primary Database, role postgres).
-- Purpose:
-- 1) Hide events.access_code_hash from anon/authenticated clients.
-- 2) Recreate join_private_event with a deterministic SHA-256 call.

create extension if not exists pgcrypto;

-- Keep RLS ownership/read policies in the expected state.
drop policy if exists "events insert auth" on public.events;
drop policy if exists "events update auth" on public.events;
drop policy if exists "events insert owner" on public.events;
drop policy if exists "events update owner" on public.events;
drop policy if exists "events read" on public.events;

create policy "events insert owner" on public.events
  for insert with check (auth.uid() is not null and created_by = auth.uid());

create policy "events update owner" on public.events
  for update using (created_by = auth.uid()) with check (created_by = auth.uid());

create policy "events read" on public.events
  for select using (
    is_private = false
    or created_by = auth.uid()
    or auth.uid() = any(coalesce(participants, '{}'::uuid[]))
  );

-- Critical: remove broad table-level reads and re-grant only safe columns.
revoke select on public.events from public, anon, authenticated;
grant select (
  id,
  bar_id,
  title,
  date,
  description,
  type,
  is_private,
  is_free,
  ticket_price,
  participants,
  created_by,
  created_at
) on public.events to anon, authenticated;
grant select (access_code_hash) on public.events to service_role;

create table if not exists public.private_event_join_attempts (
  event_id uuid not null references public.events on delete cascade,
  user_id uuid not null references auth.users on delete cascade,
  failed_attempts int not null default 0,
  blocked_until timestamptz,
  last_attempt_at timestamptz default now(),
  primary key (event_id, user_id)
);
alter table public.private_event_join_attempts enable row level security;

create or replace function public.join_private_event(p_event_id uuid, p_code text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  uid uuid := auth.uid();
  required_hash text;
  blocked_until_ts timestamptz;
  code_md5 text := md5(coalesce(p_code, ''));
  code_sha256 text;
  pgcrypto_schema text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select n.nspname
  into pgcrypto_schema
  from pg_extension e
  join pg_namespace n on n.oid = e.extnamespace
  where e.extname = 'pgcrypto';

  if pgcrypto_schema is null then
    raise exception 'pgcrypto extension not installed';
  end if;

  execute format(
    'select encode(%I.digest(convert_to($1, ''UTF8''), ''sha256''::text), ''hex'')',
    pgcrypto_schema
  )
  into code_sha256
  using coalesce(p_code, '');

  select blocked_until
  into blocked_until_ts
  from public.private_event_join_attempts
  where event_id = p_event_id
    and user_id = uid;

  if blocked_until_ts is not null and blocked_until_ts > now() then
    raise exception 'too many attempts, retry later';
  end if;

  select access_code_hash
  into required_hash
  from public.events
  where id = p_event_id
    and is_private = true;

  if required_hash is null then
    raise exception 'private event not found';
  end if;

  if required_hash <> code_md5 and required_hash <> code_sha256 then
    insert into public.private_event_join_attempts (
      event_id,
      user_id,
      failed_attempts,
      blocked_until,
      last_attempt_at
    )
    values (
      p_event_id,
      uid,
      1,
      null,
      now()
    )
    on conflict (event_id, user_id) do update
      set failed_attempts = public.private_event_join_attempts.failed_attempts + 1,
          blocked_until = case
            when public.private_event_join_attempts.failed_attempts + 1 >= 5
              then now() + interval '15 minutes'
            else null
          end,
          last_attempt_at = now();
    raise exception 'invalid private code';
  end if;

  delete from public.private_event_join_attempts
  where event_id = p_event_id
    and user_id = uid;

  update public.events
    set participants = array(
      select distinct unnest(coalesce(participants, '{}')::uuid[])
      union
      select uid
    )
  where id = p_event_id;
end;
$$;

grant execute on function public.join_private_event(uuid, text) to authenticated;
