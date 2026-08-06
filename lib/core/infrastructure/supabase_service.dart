import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the Supabase Client.
///
/// This provides a singleton instance of the SupabaseClient, which is used
/// primarily for the recipes backend and recommendation engine.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Service class to handle Supabase initialization.
class SupabaseService {
  /// Initializes the Supabase client using credentials from [AppConfig]
  /// (passed as [url] and [anonKey] from `--dart-define` values).
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (url.isEmpty || anonKey.isEmpty) {
      throw ArgumentError('Supabase url and anon key must be provided');
    }

    await Supabase.initialize(url: url, publishableKey: anonKey);
  }
}
