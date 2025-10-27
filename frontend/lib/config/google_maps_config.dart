// Configuration pour Google Maps
// Remplacez 'YOUR_GOOGLE_MAPS_API_KEY' par votre vraie clé API Google Maps

class GoogleMapsConfig {
  // Clé API Google Maps (à obtenir depuis Google Cloud Console)
  static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Configuration par défaut
  static const double defaultZoom = 13.0;
  static const double barZoom = 16.0;

  // Coordonnées par défaut (Paris)
  static const double defaultLatitude = 48.8566;
  static const double defaultLongitude = 2.3522;

  // Instructions pour obtenir une clé API :
  // 1. Aller sur https://console.cloud.google.com/
  // 2. Créer un nouveau projet ou sélectionner un projet existant
  // 3. Activer l'API "Maps SDK for Android" et "Maps SDK for iOS"
  // 4. Aller dans "Identifiants" > "Créer des identifiants" > "Clé API"
  // 5. Restreindre la clé API aux services Maps et à votre domaine
  // 6. Remplacer 'YOUR_GOOGLE_MAPS_API_KEY' par votre clé

  // Pour le web, vous devrez aussi :
  // 7. Activer "Maps JavaScript API"
  // 8. Ajouter votre domaine dans les restrictions HTTP
}
