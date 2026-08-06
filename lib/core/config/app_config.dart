import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/config/app_environment.dart';

class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.firebaseEnabled,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.paymongoPublicKey,
  });

  final AppEnvironment environment;
  final bool firebaseEnabled;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String paymongoPublicKey;

  /// Loads configuration from compile-time arguments using `--dart-define`.
  /// Defaults are provided for local development if no flags are passed.
  factory AppConfig.load() {
    return AppConfig._(
      environment: AppEnvironment.fromString(
        const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
      ),
      firebaseEnabled: const bool.fromEnvironment(
        'FIREBASE_ENABLED',
        defaultValue: false, // Default to mock repositories
      ),
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '',
      ),
      supabaseAnonKey: const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      ),
      paymongoPublicKey: const String.fromEnvironment(
        'PAYMONGO_PUBLIC_KEY',
        defaultValue: 'pk_test_placeholder', // Placeholder
      ),
    );
  }
}

/// A global provider for the AppConfig so it can be read anywhere via Riverpod.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.load();
});
