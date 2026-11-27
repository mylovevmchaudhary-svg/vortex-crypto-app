/// Supabase & REST API configuration for real production sync.
///
/// Run `backend/supabase_schema.sql` in your Supabase SQL editor, then
/// paste your Supabase Project URL and Anon Key here.
class BackendConfig {
  const BackendConfig._();

  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';

  static bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
