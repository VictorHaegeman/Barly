-- Tables
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
  add column if not exists description text,
  add column if not exists is_private boolean default false,
  add column if not exists is_free boolean default true,
  add column if not exists ticket_price text,
  add column if not exists access_code_hash text;

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
drop policy if exists "favorites by owner" on public.favorites;
drop policy if exists "users select self" on public.users;
drop policy if exists "users insert self" on public.users;
drop policy if exists "users update self" on public.users;
create policy "bars read" on public.bars for select using (true);
create policy "bars insert auth" on public.bars for insert with check (auth.role() = 'authenticated');
create policy "events read" on public.events for select using (true);
create policy "events insert auth" on public.events for insert with check (auth.role() = 'authenticated');
create policy "events update auth" on public.events for update using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "favorites by owner" on public.favorites
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users select self" on public.users
  for select using (auth.uid() = id);
create policy "users insert self" on public.users
  for insert with check (auth.uid() = id);
create policy "users update self" on public.users
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- Optional RPC used by ApiService.joinEvent
create or replace function public.join_event(p_event_id uuid)
returns void
language plpgsql
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

-- RPC: Join private event with 6-digit code
create or replace function public.join_private_event(p_event_id uuid, p_code text)
returns void
language plpgsql
as $$
declare
  uid uuid := auth.uid();
  required_hash text;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select access_code_hash
  into required_hash
  from public.events
  where id = p_event_id
    and is_private = true;

  if required_hash is null then
    raise exception 'private event not found';
  end if;

  if md5(coalesce(p_code, '')) <> required_hash then
    raise exception 'invalid private code';
  end if;

  update public.events
    set participants = array(select distinct unnest(coalesce(participants, '{}')::uuid[]) union select uid)
    where id = p_event_id;
end;
$$;
