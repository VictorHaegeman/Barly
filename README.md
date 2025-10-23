# Barly

Application mobile (Flutter) + API backend (Node/Express + Mongo optionnel) inspirée du style "Sway".

## Lancer le backend

```bash
cd backend
npm install
# copier .env.example vers .env et renseigner MONGO_URI (optionnel), JWT_SECRET, PORT
npm run dev # ou npm start
```

### Scripts disponibles

- `npm run dev` : Lance le backend en mode développement avec nodemon
- `npm run frontend` : Lance le frontend Flutter dans Chrome
- `npm run start:all` : Lance backend + frontend simultanément (nécessite `concurrently`)

Endpoints principaux:
- POST `/api/auth/register` { firstName, email, password, preferences }
- POST `/api/auth/login` { email, password } -> { token }
- GET `/api/users/me` (Bearer)
- PATCH `/api/users/me` (Bearer)
- GET `/api/bars`
- GET `/api/bars/:id`
- GET `/api/events` (Bearer)
- POST `/api/events` (Bearer)
- POST `/api/events/:id/join` (Bearer)

Si `MONGO_URI` est absent ou invalide, l'API fonctionne avec des données mock en mémoire.

## Lancer le frontend

Prérequis: Flutter 3.22+.

```bash
cd frontend
flutter pub get
flutter run
```

Le `ApiService` pointe par défaut sur `http://10.0.2.2:3001`. Adaptez pour iOS/simulateur/physique si besoin.

## Arborescence

- `backend/` Express + routes `auth`, `users`, `bars`, `events`, modèles Mongoose et middleware JWT.
- `frontend/` Flutter avec `lib/pages` (Home, Map, Events, Profile, Auth, Boosts), `widgets/` (BarlyButton, BarlyCard, PricePill) et `theme/app_theme.dart`.

## Images placeholders

Remplacez les fichiers dans `frontend/assets/images/`:
- `logo_barly.png`
- `hero_party.jpg`
- `bar_cover.jpg`

Gardez les mêmes noms de fichiers.

## Design

- **Couleurs** : primaire #A78BFA -> #B794F4 (dégradé), fond #F6F6FA, textes #1E1E1E / #5B5B66
- **Police** : Poppins via `google_fonts`
- **Coins arrondis** : 16px (cartes), 12px (boutons), 24px (modales)
- **Ombres** : douces avec elevation légère
- **Micro-interactions** : feedback de tap (scale 0.98), animations 200ms

## Navigation

- **BottomNavigationBar** : Home, Map, Events, Profil
- **Redirection automatique** : Si JWT présent au démarrage → Home, sinon → Login
- **Bouton "Boosts"** : Depuis Home, accès à l'écran d'achat style "Sway"

## Fonctionnalités

- ✅ **Authentification** : Login/Register avec JWT, redirection automatique
- ✅ **Design Sway** : Cartes élégantes, animations, couleurs lavande
- ✅ **Fallback mock** : Fonctionne sans base de données
- ✅ **Navigation complète** : 4 onglets + écrans d'auth + boosts
- ✅ **API complète** : Auth, Users, Bars, Events avec mocks
