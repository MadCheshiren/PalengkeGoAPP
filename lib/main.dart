import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palengkego/features/orders/data/shared_order_store.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'core/services/app_services.dart';
import 'core/services/preferences_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/infrastructure/firebase_service.dart';
import 'core/infrastructure/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (contains Supabase keys)
  final envLoad = dotenv.load(fileName: ".env");

  // Initialize Backend Services
  // Prevent unconfigured Firebase from crashing release build for now
  final firebaseInit = kReleaseMode
      ? Future.value()
      : FirebaseService.initialize();
  final prefsFuture = SharedPreferences.getInstance();

  await envLoad; // env must finish before Supabase reads keys
  final supabaseInit = () async {
    try {
      await SupabaseService.initialize();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Supabase init skipped/failed (Ensure .env is populated): $e',
        );
      }
    }
  }();

  final results = await Future.wait([prefsFuture, firebaseInit, supabaseInit]);
  final prefs = results[0] as SharedPreferences;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Color(0xFFB42318),
              ),
              const SizedBox(height: 12),
              const Text(
                'The app hit a widget error.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: Color(0xFF475467),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

  await SharedOrderStore.load(prefs);

  runApp(
    ProviderScope(
      overrides: [
        // Inject the pre-initialized instance so all notifiers can access
        // SharedPreferences synchronously in their build() methods.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const PalengkeGoApp(),
    ),
  );
}

class PalengkeGoApp extends ConsumerWidget {
  const PalengkeGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'PalengkeGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scaffoldMessengerKey: AppServices.scaffoldMessengerKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        return ResponsiveWrapper(child: child!);
      },
    );
  }
}
