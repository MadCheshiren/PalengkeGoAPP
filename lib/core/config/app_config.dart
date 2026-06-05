import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/config/app_environment.dart';

class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.useFirebase,
    required this.paymongoPublicKey,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool useFirebase;
  final String paymongoPublicKey;

  /// Loads configuration from compile-time arguments using `--dart-define`.
  /// Defaults are provided for local development if no flags are passed.
  factory AppConfig.load() {
    return AppConfig._(
      environment: AppEnvironment.fromString(
        const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
      ),
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://dev.api.palengkego.com', // Placeholder
      ),
      useFirebase: const bool.fromEnvironment(
        'USE_FIREBASE',
        defaultValue: false, // Default to mock repositories
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
