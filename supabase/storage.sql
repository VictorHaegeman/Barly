-- Storage setup for avatars bucket
-- Run in SQL Editor (Primary Database, role postgres)

-- Create bucket if it doesn't exist
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Recreate policies idempotently.
-- Some projects reject direct DDL on storage.objects with:
-- "must be owner of table objects" (SQLSTATE 42501).
-- We catch and downgrade that to a notice so the script doesn't hard-fail.
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

