-- Tables
create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key references auth.users on delete cascade,
  email text not null,
  first_name text,
  avatar_url text,
  phone text,
  prefs jsonb default '{}',
  notif_push boolean default true,
  notif_email boolean default false,
  price_level text,
  created_at timestamptz default now()
);

-- Compatibilite schema existant (si la table users etait deja creee)
alter table public.users
  add column if not exists email text,
  add column if not exists first_name text,
  add column if not exists avatar_url text,
  add column if not exists phone text,
  add column if not exists prefs jsonb default '{}',
  add column if not exists notif_push boolean default true,
  add column if not exists notif_email boolean default false,
  add column if not exists price_level text,
  add column if not exists created_at timestamptz default now();

create table if not exists public.bars (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  cover_url text,
  ambiance text[] default '{}',
  music text[] default '{}',
  drinks text[] default '{}',
  price_level text,
  pint_price text,
  rating numeric,
  description text,
  geo jsonb,
  created_at timestamptz default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  bar_id uuid references public.bars on delete cascade,
  title text not null,
  date timestamptz,
  description text,
  type text,
  is_private boolean default false,
  is_free boolean default true,
  ticket_price text,
  access_code_hash text,
  participants uuid[] default '{}',
  created_by uuid references auth.users,
  created_at timestamptz default now()
);

-- Compatibilite schema existant
alter table public.events
  add column if not exists date timestamptz,
  add column if not exists type text,
  add column if not exists participants uuid[] default '{}',
  add column if not exists created_by uuid references auth.users,
  add column if not exists description text,
  add column if not exists is_private boolean default false,
  add column if not exists is_free boolean default true,
  add column if not exists ticket_price text,
  add column if not exists access_code_hash text;

alter table public.bars
  add column if not exists drinks text[] default '{}';

create table if not exists public.favorites (
  user_id uuid references auth.users on delete cascade,
  bar_id uuid references public.bars on delete cascade,
  primary key (user_id, bar_id)
);

-- RLS
alter table public.bars enable row level security;
alter table public.events enable row level security;
alter table public.favorites enable row level security;
alter table public.users enable row level security;

-- Policies
drop policy if exists "bars read" on public.bars;
drop policy if exists "bars insert auth" on public.bars;
drop policy if exists "events read" on public.events;
drop policy if exists "events insert auth" on public.events;
drop policy if exists "events update auth" on public.events;
drop policy if exists "events insert owner" on public.events;
drop policy if exists "events update owner" on public.events;
drop policy if exists "favorites by owner" on public.favorites;
drop policy if exists "users select self" on public.users;
drop policy if exists "users insert self" on public.users;
drop policy if exists "users update self" on public.users;
create policy "bars read" on public.bars for select using (true);
create policy "bars insert auth" on public.bars for insert with check (auth.role() = 'authenticated');
create policy "events read" on public.events
  for select using (
    is_private = false
    or created_by = auth.uid()
    or auth.uid() = any(coalesce(participants, '{}'::uuid[]))
  );
create policy "events insert owner" on public.events
  for insert with check (auth.uid() is not null and created_by = auth.uid());
create policy "events update owner" on public.events
  for update using (created_by = auth.uid()) with check (created_by = auth.uid());
create policy "favorites by owner" on public.favorites
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users select self" on public.users
  for select using (auth.uid() = id);
create policy "users insert self" on public.users
  for insert with check (auth.uid() = id);
create policy "users update self" on public.users
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- Prevent direct client reads of private event access hashes.
revoke select on public.events from anon, authenticated;
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

-- Track repeated private-code failures per user/event.
create table if not exists public.private_event_join_attempts (
  event_id uuid not null references public.events on delete cascade,
  user_id uuid not null references auth.users on delete cascade,
  failed_attempts int not null default 0,
  blocked_until timestamptz,
  last_attempt_at timestamptz default now(),
  primary key (event_id, user_id)
);
alter table public.private_event_join_attempts enable row level security;

-- Optional RPC used by ApiService.joinEvent
create or replace function public.join_event(p_event_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  event_is_private boolean;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select is_private
  into event_is_private
  from public.events
  where id = p_event_id;

  if event_is_private then
    raise exception 'private event requires code';
  end if;

  update public.events
    set participants = array(select distinct unnest(coalesce(participants, '{}')::uuid[]) union select uid)
    where id = p_event_id;
end;
$$;

grant execute on function public.join_event(uuid) to authenticated;

-- RPC: Join private event with 6-digit code.
-- Supports legacy md5 hashes and new sha256 hashes.
create or replace function public.join_private_event(p_event_id uuid, p_code text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  uid uuid := auth.uid();
  required_hash text;
  failed_count int := 0;
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
    'select encode(%I.digest(convert_to($1, ''UTF8''), ''sha256''), ''hex'')',
    pgcrypto_schema
  )
  into code_sha256
  using coalesce(p_code, '');

  select failed_attempts, blocked_until
  into failed_count, blocked_until_ts
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
    set participants = array(select distinct unnest(coalesce(participants, '{}')::uuid[]) union select uid)
    where id = p_event_id;
end;
$$;

grant execute on function public.join_private_event(uuid, text) to authenticated;
