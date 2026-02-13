# Barly (backend Node + app Flutter)

Application type « Sway » : API Express + frontend Flutter multi-plateforme.

## Supabase (mode actuel de l'app)
Le frontend Flutter utilise Supabase pour auth/data/storage.

### Lancer le frontend avec des cles injectees (obligatoire)
```bash
cd frontend
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<sb_publishable_or_anon_key>
```

- Ne jamais committer `service_role` dans le repo.
- `SUPABASE_ANON_KEY`/`sb_publishable` peut etre exposee cote client.
- Les migrations SQL de securite sont dans `supabase/schema.sql` et `supabase/preprod_hardening_2026_02_13.sql`.

## Démarrer en 2 commandes (dev mock ou Mongo)
1) Backend (port 3001)
```bash
cd backend
npm install
copy .env.example .env   # ou cp sur mac/linux
npm run dev
```
2) Frontend Flutter (branche automatiquement sur l’API)
```bash
cd frontend
flutter pub get
flutter run --dart-define=BARLY_API=http://localhost:3001
```
> Sur émulateur Android, utilisez `--dart-define=BARLY_API=http://10.0.2.2:3001`.  
> Pour le web/desktop, gardez `http://localhost:3001`.

## Variables d’environnement clés
- `JWT_SECRET` (obligatoire en prod)
- `PORT` (par défaut 3001)
- `MONGO_URI`, `MONGO_DB` (optionnel si Mongo)
- `ALLOWED_ORIGINS` (liste séparée par virgule pour le CORS)

## Google Maps
- Remplacez `YOUR_GOOGLE_MAPS_API_KEY` dans `frontend/lib/config/google_maps_config.dart`.
- Android : meta-data dans `android/app/src/main/AndroidManifest.xml`
- iOS : `GMSServices.provideAPIKey` dans `ios/Runner/AppDelegate.swift`

## Endpoints principaux
- `POST /api/auth/register` { firstName, email, password, preferences }
- `POST /api/auth/login` { email, password } → { token }
- `GET /api/users/me` (Bearer)
- `PATCH /api/users/me` (Bearer)
- `GET /api/bars`
- `GET /api/bars/:id`
- `GET /api/events` (Bearer)
- `POST /api/events` (Bearer)
- `POST /api/events/:id/join` (Bearer)

## Arborescence rapide
- `backend/` : Express, routes auth/users/bars/events, fallback mémoire partagé, modèles Mongoose, sécurité (helmet + rate limit + CORS whitelist).
- `frontend/` : Flutter, pages Home/Map/Events/Profile/Auth/Boosts, services API & Google Maps, recommandations « Fait pour vous ».
