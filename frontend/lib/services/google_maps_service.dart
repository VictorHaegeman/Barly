import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/google_maps_config.dart';

class GoogleMapsService {
  static const String _apiKey = GoogleMapsConfig.apiKey;

  static GoogleMapController? _controller;

  // Coordonnées par défaut (Paris)
  static const LatLng _defaultLocation = LatLng(48.8566, 2.3522);

  // Configuration de la carte
  static const CameraPosition _defaultCameraPosition = CameraPosition(
    target: _defaultLocation,
    zoom: 13.0,
  );

  static CameraPosition get defaultCameraPosition => _defaultCameraPosition;

  // Créer les marqueurs pour les bars
  static Set<Marker> createBarMarkers(List<Map<String, dynamic>> bars) {
    return bars.map((bar) {
      // Coordonnées simulées pour chaque bar (en réalité, vous auriez ces données dans votre API)
      final coordinates = _getBarCoordinates(bar['id'] as String);

      return Marker(
        markerId: MarkerId(bar['id'] as String),
        position: coordinates,
        infoWindow: InfoWindow(
          title: bar['name'] as String,
          snippet: '${bar['price']} • ${bar['desc']}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      );
    }).toSet();
  }

  // Coordonnées simulées pour les bars (en réalité, vous auriez ces données dans votre API)
  static LatLng _getBarCoordinates(String barId) {
    switch (barId) {
      case '1':
        return const LatLng(48.8566, 2.3522); // Le Comptoir du 7ème
      case '2':
        return const LatLng(48.8606, 2.3376); // L'Oasis Urbaine
      case '3':
        return const LatLng(48.8506, 2.3522); // Le Bar d'Or
      case '4':
        return const LatLng(48.8566, 2.3422); // Le Speakeasy
      case '5':
        return const LatLng(48.8666, 2.3522); // Cocktail Corner
      case '6':
        return const LatLng(48.8466, 2.3522); // Le Vin & Co
      default:
        return _defaultLocation;
    }
  }

  // Animer la caméra vers un bar spécifique
  static Future<void> animateToBar(String barId) async {
    if (_controller != null) {
      final coordinates = _getBarCoordinates(barId);
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(coordinates, 16.0),
      );
    }
  }

  // Sauvegarder la référence du contrôleur
  static void setController(GoogleMapController controller) {
    _controller = controller;
  }

  // Obtenir la clé API (à configurer dans votre environnement)
  static String get apiKey => _apiKey;
}
