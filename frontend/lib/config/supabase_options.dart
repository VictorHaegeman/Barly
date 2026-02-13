/// Provide Supabase keys through --dart-define only.
/// Never commit fallback keys to source control.
class SupabaseOptions {
  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const anonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String get resolvedUrl => url;
  static String get resolvedAnonKey => anonKey;
}
