# Configuration Google Maps pour Barly

## Étapes pour activer Google Maps

### 1. Obtenir une clé API Google Maps

1. **Aller sur Google Cloud Console** : https://console.cloud.google.com/
2. **Créer un projet** ou sélectionner un projet existant
3. **Activer les APIs nécessaires** :
   - Maps SDK for Android
   - Maps SDK for iOS  
   - Maps JavaScript API (pour le web)
4. **Créer une clé API** :
   - Aller dans "Identifiants" > "Créer des identifiants" > "Clé API"
   - Copier la clé générée

### 2. Configurer la clé API

1. **Ouvrir le fichier** : `frontend/lib/config/google_maps_config.dart`
2. **Remplacer** `'YOUR_GOOGLE_MAPS_API_KEY'` par votre vraie clé API
3. **Restreindre la clé** (recommandé) :
   - Dans Google Cloud Console, aller sur votre clé API
   - Ajouter des restrictions par application (Android/iOS)
   - Ajouter des restrictions HTTP (pour le web)

### 3. Configuration pour Android

1. **Ouvrir** : `frontend/android/app/src/main/AndroidManifest.xml`
2. **Ajouter** dans la section `<application>` :
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="VOTRE_CLE_API_ICI"/>
```

### 4. Configuration pour iOS

1. **Ouvrir** : `frontend/ios/Runner/AppDelegate.swift`
2. **Ajouter** dans `application:didFinishLaunchingWithOptions:` :
```swift
GMSServices.provideAPIKey("VOTRE_CLE_API_ICI")
```

### 5. Configuration pour le Web

1. **Ouvrir** : `frontend/web/index.html`
2. **Ajouter** dans `<head>` :
```html
<script src="https://maps.googleapis.com/maps/api/js?key=VOTRE_CLE_API_ICI"></script>
```

## Fonctionnalités implémentées

- ✅ **Carte interactive** avec Google Maps
- ✅ **Marqueurs des bars** avec informations
- ✅ **Zoom et navigation** sur la carte
- ✅ **Localisation utilisateur** (si autorisée)
- ✅ **Animation fluide** entre carte et liste
- ✅ **Effet de survol** sur le toggle

## Structure des fichiers

```
frontend/lib/
├── config/
│   └── google_maps_config.dart    # Configuration de la clé API
├── services/
│   └── google_maps_service.dart   # Service pour gérer la carte
├── widgets/
│   └── bar_map_widget.dart        # Widget de la carte
└── pages/
    └── map_page.dart              # Page principale avec toggle
```

## Utilisation

La carte s'affiche automatiquement quand vous sélectionnez "Carte" dans le toggle. Les marqueurs des bars sont positionnés automatiquement et affichent les informations de chaque bar au clic.

## Dépannage

- **Carte ne s'affiche pas** : Vérifiez que la clé API est correctement configurée
- **Erreur de restriction** : Vérifiez les restrictions de votre clé API
- **Marqueurs manquants** : Vérifiez que les coordonnées des bars sont définies
