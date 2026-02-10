-- Storage setup for avatars bucket
-- Run in SQL Editor (Primary Database, role postgres)

-- Create bucket if it doesn't exist
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Allow public read
create policy if not exists "avatars public read" on storage.objects
for select using (bucket_id = 'avatars');

-- Allow authenticated users to upload/update their files
create policy if not exists "avatars auth insert" on storage.objects
for insert with check (bucket_id = 'avatars' and auth.role() = 'authenticated');

create policy if not exists "avatars auth update" on storage.objects
for update using (bucket_id = 'avatars' and auth.role() = 'authenticated')
with check (bucket_id = 'avatars' and auth.role() = 'authenticated');

