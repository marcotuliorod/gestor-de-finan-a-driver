import 'package:supabase_flutter/supabase_flutter.dart';

class AppSupabaseClient {
  AppSupabaseClient._();

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
