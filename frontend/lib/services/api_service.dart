import 'package:supabase_flutter/supabase_flutter.dart';

/// Service d'accès aux données via Supabase.
/// Les signatures restent compatibles avec l'ancien backend pour limiter
/// les changements dans les écrans.
class ApiService {
  ApiService() : client = Supabase.instance.client;
  final SupabaseClient client;

  bool get isAuthenticated => client.auth.currentSession != null;

  Future<String?> get token async => client.auth.currentSession?.accessToken;

  Future<void> logout() => client.auth.signOut();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.session == null) throw Exception('Login échoué');
    return {
      'user': res.user?.toJson(),
      'token': res.session?.accessToken,
    };
  }

  Future<Map<String, dynamic>> register(
    String firstName,
    String email,
    String password,
    Map<String, List<String>> preferences,
  ) async {
    final res = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'prefs': preferences,
      },
    );
    final userId = res.user?.id;
    if (userId != null) {
      await client.from('users').upsert({
        'id': userId,
        'email': email,
        'first_name': firstName,
        'prefs': preferences,
      });
    }
    if (res.session == null && res.user == null) {
      throw Exception('Register échoué');
    }
    return {
      'user': res.user?.toJson(),
      'token': res.session?.accessToken,
    };
  }

  Future<List<Map<String, dynamic>>> getBars() async {
    final rows = await client.from('bars').select();
    return rows.map<Map<String, dynamic>>((b) {
      final map = Map<String, dynamic>.from(b as Map);
      return {
        ...map,
        'id': map['id']?.toString(),
        'coverImage': map['cover_url'],
        'imageUrl': map['cover_url'],
        'pintPrice': map['pint_price'] ?? map['price_level'] ?? '€€',
        'priceLevel': map['price_level'] ?? '€',
        'ambiance': map['ambiance'] ?? [],
        'music': map['music'] ?? [],
      };
    }).toList();
  }

  Future<Map<String, dynamic>> getBar(String id) async {
    final row =
        await client.from('bars').select().eq('id', id).maybeSingle();
    if (row == null) throw Exception('Bar introuvable');
    final map = Map<String, dynamic>.from(row);
    return {
      ...map,
      'id': map['id']?.toString(),
      'coverImage': map['cover_url'],
      'imageUrl': map['cover_url'],
      'pintPrice': map['pint_price'] ?? map['price_level'] ?? '€€',
      'priceLevel': map['price_level'] ?? '€',
      'ambiance': map['ambiance'] ?? [],
      'music': map['music'] ?? [],
    };
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final rows = await client
        .from('events')
        .select(
            'id,title,date,participants,type,bar_id,bar:bars(id,name,cover_url,address,price_level,pint_price)')
        .order('date');
    return rows.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final bar = Map<String, dynamic>.from(map['bar'] ?? {});
      final participants = List.from(map['participants'] ?? []);
      return {
        ...map,
        'id': map['id']?.toString(),
        'barName': bar['name'],
        'bar': bar['name'],
        'bar_id': map['bar_id'],
        'participants': participants,
        'price': 'Gratuit',
        'type': map['type'] ?? 'Événement',
        'date': map['date']?.toString(),
      };
    }).toList();
  }

  Future<void> joinEvent(String id) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Unauthenticated');

    // Si une fonction RPC join_event existe côté Supabase, on l'utilise.
    try {
      await client.rpc('join_event', params: {'p_event_id': id});
      return;
    } catch (_) {
      // fallback: append participants localement
      final existing = await client
          .from('events')
          .select('participants')
          .eq('id', id)
          .maybeSingle();
      final current = List<String>.from(existing?['participants'] ?? []);
      if (!current.contains(user.id)) current.add(user.id);
      await client
          .from('events')
          .update({'participants': current}).eq('id', id);
    }
  }

  Future<Map<String, dynamic>> createEvent({
    required String barId,
    required String title,
    required String date,
  }) async {
    final user = client.auth.currentUser;
    final insert = await client.from('events').insert({
      'bar_id': barId,
      'title': title,
      'date': date,
      'participants': user != null ? [user.id] : [],
      'type': 'Événement',
    }).select().single();
    return Map<String, dynamic>.from(insert);
  }

  Future<Map<String, dynamic>?> getMe() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final profile =
        await client.from('users').select().eq('id', user.id).maybeSingle();
    return {
      'id': user.id,
      'email': user.email,
      'profile': profile,
    };
  }
}
