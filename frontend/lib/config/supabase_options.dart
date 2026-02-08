/// Renseigne tes clés Supabase via --dart-define ou en dur ici pour le dev local.
/// En production, toujours utiliser les variables d'environnement.
class SupabaseOptions {
  static const url =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const anonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// Valeurs de secours pour le développement local (à supprimer en prod).
  static const fallbackUrl = '';
  static const fallbackAnonKey = '';

  static String get resolvedUrl => url.isNotEmpty ? url : fallbackUrl;
  static String get resolvedAnonKey =>
      anonKey.isNotEmpty ? anonKey : fallbackAnonKey;
}
