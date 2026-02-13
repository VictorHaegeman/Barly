# Configuration Google Maps pour Barly

## 1) Creer les cles API
Dans Google Cloud Console:
- Activer `Maps SDK for Android`
- Activer `Maps SDK for iOS`
- Activer `Maps JavaScript API` (web)

Creer 3 cles separees (recommande):
- `ANDROID_MAPS_KEY` (restriction package + SHA-1)
- `IOS_MAPS_KEY` (restriction bundle id)
- `WEB_MAPS_KEY` (restriction referrer)

## 2) Configurer Android
Fichier: `frontend/android/local.properties` (non versionne)
```properties
MAPS_API_KEY=AIza...android_key...
```
La cle est injectee dans le manifest via `MAPS_API_KEY`.

## 3) Configurer iOS
Option A (Xcode Build Settings):
- `Runner` target -> Build Settings -> User-Defined -> `GMS_API_KEY`

Option B (xcconfig local non versionne):
- definir `GMS_API_KEY=AIza...ios_key...`

La cle est lue depuis `Runner/Info.plist` (`GMSApiKey`).

## 4) Configurer Web
Creer `frontend/web/maps_config.js` (non versionne) a partir de l'exemple:
```js
window.__BARLY_CONFIG__ = {
  googleMapsWebApiKey: 'AIza...web_key...',
};
```

## 5) Verification
- Android/iOS: ouvrir la page map, verifier rendu + markers.
- Web: verifier qu'aucune erreur Maps JS n'apparait dans la console.

## Depannage
- Carte vide sur mobile: cle plateforme manquante/incorrecte.
- `ApiNotActivatedMapError`: API non activee dans Google Cloud.
- `RefererNotAllowedMapError`: restriction referrer web incorrecte.
