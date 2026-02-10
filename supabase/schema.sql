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
  type text,
  participants uuid[] default '{}',
  created_by uuid references auth.users,
  created_at timestamptz default now()
);

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
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  update public.events
    set participants = array(select distinct unnest(coalesce(participants, '{}')::uuid[]) union select uid)
    where id = p_event_id;
end;
$$;
