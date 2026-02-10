-- Exemples de données pour le dev
-- À exécuter dans le SQL Editor Supabase (Primary Database, rôle service_role/postgres)

-- S'assurer que les colonnes attendues existent
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
  add column if not exists type text,
  add column if not exists participants uuid[] default '{}'::uuid[];

-- Bars
insert into public.bars (id, name, address, cover_url, ambiance, music, price_level, pint_price, rating, description)
values
  ('00000000-0000-0000-0000-0000000000b1', 'Lavender Club', '12 rue des Fleurs, Paris', 'https://images.unsplash.com/photo-1514361892635-6e122620e4d1?w=800&auto=format&fit=crop',
   '{Cosy,Danse}', '{House,Pop}', '€€', '7€', 4.6, 'Cocktails et house toute la nuit'),
  ('00000000-0000-0000-0000-0000000000b2', 'Sway Bar', '5 avenue Montaigne, Paris', 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?w=800&auto=format&fit=crop',
   '{Chill}', '{Jazz}', '€', '5€', 4.4, 'Ambiance jazz douce'),
  ('00000000-0000-0000-0000-0000000000b3', 'Purple Lounge', '8 quai de Seine, Paris', 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800&auto=format&fit=crop',
   '{Lounge}', '{RnB}', '€€€', '9€', 4.8, 'Lounge chic en bord de Seine')
on conflict (id) do nothing;

-- Events
insert into public.events (id, bar_id, title, date, type, participants)
values
  ('00000000-0000-0000-0000-0000000000e1', '00000000-0000-0000-0000-0000000000b1', 'Soirée House', now() + interval '1 day', 'Soirée', '{}'::uuid[]),
  ('00000000-0000-0000-0000-0000000000e2', '00000000-0000-0000-0000-0000000000b2', 'Live Jazz',   now() + interval '2 day', 'Concert', '{}'::uuid[])
on conflict (id) do nothing;
