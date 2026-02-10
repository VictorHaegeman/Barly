/// Renseigne tes clés Supabase via --dart-define.
/// En production, toujours utiliser les variables d'environnement.
class SupabaseOptions {
  static const url =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const anonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// Valeurs de secours pour le développement local (laisser vide pour éviter
  /// de compromettre des clés en clair dans le code).
  static const fallbackUrl = '';
  static const fallbackAnonKey = '';

  static String get resolvedUrl => url.isNotEmpty ? url : fallbackUrl;
  static String get resolvedAnonKey =>
      anonKey.isNotEmpty ? anonKey : fallbackAnonKey;
}
