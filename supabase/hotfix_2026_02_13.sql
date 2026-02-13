-- Hotfix migration - 2026-02-13
-- Run in Supabase SQL Editor (Primary Database, role postgres)

-- 1) Missing columns discovered on production project
alter table public.events
  add column if not exists created_by uuid references auth.users;

alter table public.bars
  add column if not exists drinks text[] default '{}'::text[];

-- 2) Ensure storage RLS + avatars policies (without CREATE POLICY IF NOT EXISTS)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

do $$
begin
  begin
    execute 'drop policy if exists "avatars public read" on storage.objects';
    execute 'drop policy if exists "avatars auth insert" on storage.objects';
    execute 'drop policy if exists "avatars auth update" on storage.objects';

    execute 'create policy "avatars public read" on storage.objects
      for select using (bucket_id = ''avatars'')';

    execute 'create policy "avatars auth insert" on storage.objects
      for insert with check (bucket_id = ''avatars'' and auth.role() = ''authenticated'')';

    execute 'create policy "avatars auth update" on storage.objects
      for update using (bucket_id = ''avatars'' and auth.role() = ''authenticated'')
      with check (bucket_id = ''avatars'' and auth.role() = ''authenticated'')';
  exception
    when insufficient_privilege then
      raise notice 'Storage policies not updated from SQL (insufficient privilege): %', sqlerrm;
    when others then
      raise notice 'Storage policies not updated from SQL: %', sqlerrm;
  end;
end $$;

-- 3) Ensure private join RPC exists (safe replace)
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
    set participants = array(
      select distinct unnest(coalesce(participants, '{}')::uuid[])
      union
      select uid
    )
  where id = p_event_id;
end;
$$;
