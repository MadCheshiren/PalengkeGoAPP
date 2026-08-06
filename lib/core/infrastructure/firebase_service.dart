import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:palengkego/core/config/app_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 (Your Friend's Job):
//   Run `flutterfire configure` in the project root terminal.
//   This generates `lib/firebase_options.dart` automatically.
//   Then commit and push it so both teammates have it.
//
// STEP 2 (Your Friend's Job):
//   Once firebase_options.dart exists, uncomment the line below:
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:palengkego/firebase_options.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Firebase SDK instance providers
// These are safe to keep — they are only accessed when Firebase is actually
// initialized (i.e. when firebaseEnabled == true).
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for Firebase Auth instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider for Cloud Firestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for Firebase Storage instance.
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Convenience provider — reads the FIREBASE_ENABLED dart-define flag
/// from [AppConfig] so any provider can check it without importing AppConfig.
final firebaseEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appConfigProvider).firebaseEnabled;
});

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseService — handles app startup initialization
// ─────────────────────────────────────────────────────────────────────────────

class FirebaseService {
  /// Initializes Firebase at app startup.
  ///
  /// ### Current behavior (before firebase_options.dart exists):
  /// Catches the "no-app" exception so the app runs fine in mock/dev mode.
  ///
  /// ### After your friend runs `flutterfire configure`:
  /// Replace the body of this method with:
  ///
  /// ```dart
  /// await Firebase.initializeApp(
  ///   options: DefaultFirebaseOptions.currentPlatform,
  /// );
  /// ```
  ///
  /// And uncomment the firebase_options.dart import at the top of this file.
  static Future<void> initialize() async {
    try {
      // ── YOUR FRIEND REPLACES THIS BLOCK ──────────────────────────────────
      // Before: dummy call that fails silently
      await Firebase.initializeApp();
      //
      // After (once firebase_options.dart is generated):
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      // ─────────────────────────────────────────────────────────────────────
    } catch (e) {
      // Expected in dev/mock mode before Firebase is configured.
      if (kDebugMode) {
        debugPrint('[FirebaseService] Init skipped (not configured yet): $e');
      }
    }
  }
}
