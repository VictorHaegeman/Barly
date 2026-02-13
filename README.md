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
- Patch critique prod (si RPC prive ou hash exposes): `supabase/prod_critical_fix_2026_02_13.sql`.
- Audit SQL read-only: `supabase/prod_readiness_check_2026_02_13.sql` (`all_green` doit etre `true`).
- Verification automatique post-migration:
```bash
powershell -ExecutionPolicy Bypass -File scripts/verify_supabase_hardening.ps1 \
  -SupabaseUrl https://<project-ref>.supabase.co \
  -AnonKey <sb_publishable_or_anon_key> \
  -FailOnCheck
```

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
- Web: copier `frontend/web/maps_config.example.js` vers `frontend/web/maps_config.js` puis definir `googleMapsWebApiKey`.
- Android: definir `MAPS_API_KEY` dans `frontend/android/local.properties` (non committe).
- iOS: definir `GMS_API_KEY` dans Xcode Build Settings ou xcconfig local (non committe).

## iOS CI
- Workflow iOS sans signature: `.github/workflows/flutter-ios.yml`
- Il valide la compilation release (`flutter build ios --no-codesign`) sur macOS.

## iOS preprod/prod checklist
- Mettre un vrai `PRODUCT_BUNDLE_IDENTIFIER` (pas `com.example.frontend`).
- Ajouter `GoogleService-Info.plist` (Firebase) dans `frontend/ios/Runner/`.
- Activer Push Notifications + Background Modes (Remote notifications) dans Signing & Capabilities.
- Verifier signature Release (Team, provisioning profile, certificat distribution).
- Incrémenter la version dans `frontend/pubspec.yaml` avant release.

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
