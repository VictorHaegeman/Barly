import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
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
      await _upsertUserProfileWithEmailFallback({
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
        'drinks': map['drinks'] ?? [],
      };
    }).toList();
  }

  Future<Map<String, dynamic>> getBar(String id) async {
    final row = await client.from('bars').select().eq('id', id).maybeSingle();
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
      'drinks': map['drinks'] ?? [],
    };
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    List<dynamic> rows;
    try {
      rows = await client
          .from('events')
          .select(
              'id,title,date,participants,type,is_private,is_free,ticket_price,description,created_by,bar_id,bar:bars(id,name,cover_url,address,price_level,pint_price)')
          .order('date');
    } catch (_) {
      try {
        // Compatibilite si les nouvelles colonnes n'existent pas encore.
        rows = await client
            .from('events')
            .select(
                'id,title,date,participants,type,is_private,bar_id,bar:bars(id,name,cover_url,address,price_level,pint_price)')
            .order('date');
      } catch (_) {
        rows = await client
            .from('events')
            .select(
                'id,title,date,participants,type,bar_id,bar:bars(id,name,cover_url,address,price_level,pint_price)')
            .order('date');
      }
    }

    return rows.map<Map<String, dynamic>>((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final bar = Map<String, dynamic>.from(map['bar'] ?? {});
      final participants = List.from(map['participants'] ?? []);
      final isPrivate = map['is_private'] == true;
      final isFree = map['is_free'] != false;
      final ticketPrice = map['ticket_price']?.toString().trim();
      final priceLabel = isPrivate
          ? 'Code requis'
          : (isFree
              ? 'Gratuit'
              : (ticketPrice == null || ticketPrice.isEmpty
                  ? 'Payant'
                  : ticketPrice));
      return {
        ...map,
        'id': map['id']?.toString(),
        'barName': bar['name'],
        'bar': bar['name'],
        'bar_id': map['bar_id'],
        'participants': participants,
        'price': priceLabel,
        'isFree': isFree,
        'ticket_price': map['ticket_price'],
        'description': map['description'],
        'created_by': map['created_by'],
        'type': map['type'] ?? 'Evenement',
        'date': map['date']?.toString(),
        'isPrivate': isPrivate,
      };
    }).toList();
  }

  Future<void> joinEvent(
    String id, {
    bool isPrivate = false,
    String? privateCode,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Unauthenticated');

    if (isPrivate) {
      final code = (privateCode ?? '').trim();
      if (code.length != 6) {
        throw Exception('Code prive invalide (6 chiffres requis)');
      }
      try {
        await client.rpc('join_private_event', params: {
          'p_event_id': id,
          'p_code': code,
        });
        return;
      } catch (_) {
        // fallback: verify hash locally if RPC not yet deployed
        Map<String, dynamic>? existing;
        try {
          existing = await client
              .from('events')
              .select('participants,access_code_hash')
              .eq('id', id)
              .maybeSingle();
        } catch (error) {
          if (_extractMissingColumnName(error) == 'access_code_hash') {
            throw Exception(
              'Schema Supabase events obsolete: execute supabase/schema.sql',
            );
          }
          rethrow;
        }
        final requiredHash = (existing?['access_code_hash'] ?? '').toString();
        if (requiredHash.isEmpty) {
          throw Exception(
            'Schema Supabase events obsolete: execute supabase/schema.sql',
          );
        }
        if (requiredHash.isNotEmpty && _hashAccessCode(code) != requiredHash) {
          throw Exception('Code prive incorrect');
        }
        final current = List<String>.from(existing?['participants'] ?? []);
        if (!current.contains(user.id)) current.add(user.id);
        await client
            .from('events')
            .update({'participants': current}).eq('id', id);
        return;
      }
    }

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
    String? type,
    bool isPrivate = false,
    bool isFree = true,
    String? ticketPrice,
    String? accessCode,
    String? description,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Unauthenticated');
    if (isPrivate) {
      final code = (accessCode ?? '').trim();
      if (!RegExp(r'^\d{6}$').hasMatch(code)) {
        throw Exception('Code prive invalide (6 chiffres requis)');
      }
    } else if (!isFree && (ticketPrice == null || ticketPrice.trim().isEmpty)) {
      throw Exception('Le prix est requis pour un evenement payant');
    }

    final payload = {
      'bar_id': barId,
      'title': title,
      'date': date,
      'participants': [user.id],
      'type': type ?? 'Evenement',
      'created_by': user.id,
      'is_private': isPrivate,
      'is_free': isPrivate ? true : isFree,
      'ticket_price': isPrivate || isFree ? null : ticketPrice?.trim(),
      'access_code_hash':
          isPrivate ? _hashAccessCode((accessCode ?? '').trim()) : null,
      'description':
          description?.trim().isEmpty == true ? null : description?.trim(),
    };

    final insert = await _insertEventWithFallback(
      payload: payload,
      isPrivate: isPrivate,
      isFree: isFree,
    );

    return Map<String, dynamic>.from(insert);
  }

  Future<Map<String, dynamic>?> getMe() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final profile =
        await client.from('users').select().eq('id', user.id).maybeSingle();
    final prefs = Map<String, dynamic>.from(
        profile?['prefs'] ?? user.userMetadata?['prefs'] ?? {});
    return {
      'id': user.id,
      'email': user.email,
      'firstName': profile?['first_name'] ?? user.userMetadata?['first_name'],
      'avatarUrl': profile?['avatar_url'],
      'phone': profile?['phone'],
      'prefs': prefs,
      'notif_push':
          profile?['notif_push'] ?? user.userMetadata?['notif_push'] ?? true,
      'notif_email':
          profile?['notif_email'] ?? user.userMetadata?['notif_email'] ?? false,
      'price_level':
          profile?['price_level'] ?? user.userMetadata?['price_level'],
      'fcm_token': user.userMetadata?['fcm_token'],
    };
  }

  Future<void> updateProfile({
    String? firstName,
    String? email,
    String? phone,
    String? avatarUrl,
    Map<String, dynamic>? prefs,
    String? priceLevel,
    bool? notifPush,
    bool? notifEmail,
    String? fcmToken,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Unauthenticated');

    final authData = <String, dynamic>{
      if (firstName != null) 'first_name': firstName,
      if (prefs != null) 'prefs': prefs,
      if (priceLevel != null) 'price_level': priceLevel,
      if (notifPush != null) 'notif_push': notifPush,
      if (notifEmail != null) 'notif_email': notifEmail,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
    if (email != null || phone != null || authData.isNotEmpty) {
      await client.auth.updateUser(
        UserAttributes(
          email: email,
          phone: phone,
          data: authData.isEmpty ? null : authData,
        ),
      );
    }

    final update = <String, dynamic>{'id': user.id};
    final profileEmail = email ?? user.email;
    if (profileEmail != null && profileEmail.isNotEmpty) {
      update['email'] = profileEmail;
    }
    if (firstName != null) update['first_name'] = firstName;
    if (phone != null) update['phone'] = phone;
    if (avatarUrl != null) update['avatar_url'] = avatarUrl;
    if (prefs != null) update['prefs'] = prefs;
    if (priceLevel != null) update['price_level'] = priceLevel;
    if (notifPush != null) update['notif_push'] = notifPush;
    if (notifEmail != null) update['notif_email'] = notifEmail;

    final removedColumns = await _upsertUserProfileWithEmailFallback(update);
    final fallbackMeta = <String, dynamic>{};
    if (removedColumns.containsKey('prefs')) {
      fallbackMeta['prefs'] = removedColumns['prefs'];
    }
    if (removedColumns.containsKey('price_level')) {
      fallbackMeta['price_level'] = removedColumns['price_level'];
    }
    if (removedColumns.containsKey('first_name')) {
      fallbackMeta['first_name'] = removedColumns['first_name'];
    }
    if (removedColumns.containsKey('notif_push')) {
      fallbackMeta['notif_push'] = removedColumns['notif_push'];
    }
    if (removedColumns.containsKey('notif_email')) {
      fallbackMeta['notif_email'] = removedColumns['notif_email'];
    }
    if (fallbackMeta.isNotEmpty) {
      try {
        await client.auth.updateUser(UserAttributes(data: fallbackMeta));
      } catch (_) {
        // Ignore silently: profile write succeeded in users table fallback path.
      }
    }
  }

  Future<void> saveFcmToken(String token) async {
    await updateProfile(fcmToken: token);
  }

  Future<Map<String, dynamic>> _upsertUserProfileWithEmailFallback(
    Map<String, dynamic> payload,
  ) async {
    final fallback = Map<String, dynamic>.from(payload);
    final removed = <String, dynamic>{};
    while (true) {
      try {
        await client.from('users').upsert(fallback);
        return removed;
      } catch (error) {
        final missingColumn = _extractMissingColumnName(error);
        if (missingColumn == null ||
            missingColumn == 'id' ||
            !fallback.containsKey(missingColumn)) {
          rethrow;
        }
        removed[missingColumn] = fallback.remove(missingColumn);
      }
    }
  }

  Future<Map<String, dynamic>> _insertEventWithFallback({
    required Map<String, dynamic> payload,
    required bool isPrivate,
    required bool isFree,
  }) async {
    final fallback = Map<String, dynamic>.from(payload);
    while (true) {
      try {
        final inserted =
            await client.from('events').insert(fallback).select().single();
        return Map<String, dynamic>.from(inserted);
      } catch (error) {
        final missingColumn = _extractMissingColumnName(error);
        if (missingColumn == null || !fallback.containsKey(missingColumn)) {
          if (isPrivate || !isFree) {
            throw Exception(
              'Schema Supabase events obsolete: execute supabase/schema.sql',
            );
          }
          rethrow;
        }
        final requiresModernSchema = isPrivate &&
                (missingColumn == 'is_private' ||
                    missingColumn == 'access_code_hash') ||
            (!isFree && missingColumn == 'ticket_price');
        if (requiresModernSchema) {
          throw Exception(
            'Schema Supabase events obsolete: execute supabase/schema.sql',
          );
        }
        fallback.remove(missingColumn);
      }
    }
  }

  String? _extractMissingColumnName(Object error) {
    if (error is! PostgrestException) return null;
    final text = [
      error.message,
      error.details,
      error.hint,
      error.code,
    ].join(' ').toLowerCase();
    final pgrst = RegExp(r"could not find the '([a-z0-9_]+)' column");
    final pgrstMatch = pgrst.firstMatch(text);
    if (pgrstMatch != null) return pgrstMatch.group(1);

    final relation =
        RegExp(r'column [a-z0-9_]+\."?([a-z0-9_]+)"? does not exist');
    final relationMatch = relation.firstMatch(text);
    if (relationMatch != null) return relationMatch.group(1);

    final generic = RegExp(r'column "?([a-z0-9_]+)"? does not exist');
    final genericMatch = generic.firstMatch(text);
    if (genericMatch != null) return genericMatch.group(1);

    return null;
  }

  String _hashAccessCode(String code) {
    return md5.convert(utf8.encode(code)).toString();
  }

  Future<void> sendPhoneOtp(String phone) async {
    await client.auth.signInWithOtp(phone: phone);
  }

  Future<void> verifyPhoneOtp(
      {required String phone, required String code}) async {
    await client.auth.verifyOTP(
      token: code,
      type: OtpType.sms,
      phone: phone,
    );
  }

  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Unauthenticated');
    final path = '${user.id}/$fileName';
    await client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
    final url = client.storage.from('avatars').getPublicUrl(path);
    await updateProfile(avatarUrl: url);
    return url;
  }

  Future<Map<String, dynamic>> createBar({
    required String name,
    String? address,
    String? coverUrl,
    List<String>? ambiance,
    List<String>? music,
    List<String>? drinks,
    String? priceLevel,
    String? pintPrice,
    String? description,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Unauthenticated');
    final payload = {
      'name': name,
      'address': address,
      'cover_url': coverUrl,
      'ambiance': ambiance ?? [],
      'music': music ?? [],
      'drinks': drinks ?? [],
      'price_level': priceLevel,
      'pint_price': pintPrice,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    };
    dynamic row;
    try {
      row = await client.from('bars').insert(payload).select().single();
    } catch (error) {
      if (_extractMissingColumnName(error) != 'drinks') rethrow;
      final fallback = Map<String, dynamic>.from(payload)..remove('drinks');
      row = await client.from('bars').insert(fallback).select().single();
    }
    return Map<String, dynamic>.from(row);
  }
}
