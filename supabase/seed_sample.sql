-- Dev seed data
-- Run in Supabase SQL Editor (Primary Database, role postgres)

-- Ensure expected columns exist
alter table public.bars
  add column if not exists address text,
  add column if not exists cover_url text,
  add column if not exists ambiance text[] default '{}'::text[],
  add column if not exists music text[] default '{}'::text[],
  add column if not exists price_level text,
  add column if not exists pint_price text,
  add column if not exists rating numeric,
  add column if not exists description text;

alter table public.events
  add column if not exists date timestamptz,
  add column if not exists description text,
  add column if not exists type text,
  add column if not exists is_private boolean default false,
  add column if not exists is_free boolean default true,
  add column if not exists ticket_price text,
  add column if not exists access_code_hash text,
  add column if not exists participants uuid[] default '{}'::uuid[];

-- Bars
insert into public.bars (id, name, address, cover_url, ambiance, music, price_level, pint_price, rating, description)
values
  ('00000000-0000-0000-0000-0000000000b1', 'Lavender Club', '12 rue des Fleurs, Paris', 'https://images.unsplash.com/photo-1514361892635-6e122620e4d1?w=800&auto=format&fit=crop',
   '{Cosy,Dance}', '{House,Pop}', '$$', '$7', 4.6, 'Cocktails et house toute la nuit'),
  ('00000000-0000-0000-0000-0000000000b2', 'Sway Bar', '5 avenue Montaigne, Paris', 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=800&auto=format&fit=crop',
   '{Chill}', '{Jazz}', '$', '$5', 4.4, 'Ambiance jazz douce'),
  ('00000000-0000-0000-0000-0000000000b3', 'Purple Lounge', '8 quai de Seine, Paris', 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800&auto=format&fit=crop',
   '{Lounge}', '{RnB}', '$$$', '$9', 4.8, 'Lounge chic en bord de Seine')
on conflict (id) do nothing;

-- Events
insert into public.events (id, bar_id, title, description, date, type, is_private, is_free, ticket_price, access_code_hash, participants)
values
  ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-0000000000b1', 'Soiree House', 'Open format, entree libre et DJ guest.', now() + interval '1 day', 'Soiree', false, true, null, null, '{}'::uuid[]),
  ('00000000-0000-0000-0000-0000000000e2', '00000000-0000-0000-0000-0000000000b2', 'Live Jazz', 'Concert live avec line-up resident.', now() + interval '2 day', 'Concert', false, false, '12,99€', null, '{}'::uuid[]),
  ('00000000-0000-0000-0000-0000000000e3', '00000000-0000-0000-0000-0000000000b3', 'Soiree privee VIP', 'Evenement prive sur invitation avec code.', now() + interval '3 day', 'Soiree', true, true, null, md5('123456'), '{}'::uuid[])
on conflict (id) do nothing;
