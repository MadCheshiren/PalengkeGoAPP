import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provider for the Supabase Client.
///
/// This provides a singleton instance of the SupabaseClient, which is used
/// primarily for the recipes backend and recommendation engine.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Service class to handle Supabase initialization.
class SupabaseService {
  /// Initializes the Supabase client using credentials from the .env file.
  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception('Missing Supabase credentials in .env file');
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
}
