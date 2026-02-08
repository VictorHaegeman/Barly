import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton utilitaire pour Supabase.
class SupabaseService {
  SupabaseService._internal();
  static final SupabaseService instance = SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  /// A appeler avant runApp dans main.dart
  static Future<void> init({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  Future<AuthResponse> signIn(String email, String password) =>
      client.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp(
    String email,
    String password,
    String firstName, {
    Map<String, dynamic>? preferences,
  }) =>
      client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'prefs': preferences ?? {},
        },
      );

  Future<void> signOut() => client.auth.signOut();

  Future<List<Map<String, dynamic>>> getBars() async {
    final res = await client.from('bars').select();
    return (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final res = await client
        .from('events')
        .select('*, bar:bars(name, address, cover_url, price_level)');
    return (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> getMe() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final res =
        await client.from('users').select().eq('id', user.id).maybeSingle();
    if (res == null) return null;
    return Map<String, dynamic>.from(res);
  }

  Future<void> joinEvent(String eventId) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('not authenticated');
    await client.rpc('join_event', params: {
      'p_event_id': eventId,
    });
  }
}
