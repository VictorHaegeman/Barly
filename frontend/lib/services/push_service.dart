import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

/// Initialise Firebase + Firebase Messaging et enregistre le token FCM
/// auprès du profil utilisateur Supabase (metadata + table users si besoin).
class PushService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  /// À appeler au démarrage après Supabase.init().
  static Future<void> init() async {
    if (_initialized) return;
    await Firebase.initializeApp();

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken();
    if (token != null) {
      await _persistToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _persistToken(token);
    });

    _initialized = true;
  }

  static Future<void> _persistToken(String token) async {
    try {
      final api = ApiService();
      await api.saveFcmToken(token);
    } catch (_) {
      // pas bloquant
    }
  }
}
