import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';
import 'package:palengkego/features/auth/presentation/pages/auth_guard.dart';

class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier(this.initialUser);

  final AppUser? initialUser;

  @override
  AppUser? build() => initialUser;
}

void main() {
  Widget buildGuardedApp(AppUser? user) {
    return ProviderScope(
      overrides: [authProvider.overrideWith(() => TestAuthNotifier(user))],
      child: const MaterialApp(
        home: AuthGuard(child: Scaffold(body: Text('Protected content'))),
      ),
    );
  }

  group('AuthGuard', () {
    testWidgets('renders login screen when no user is authenticated', (
      tester,
    ) async {
      await tester.pumpWidget(buildGuardedApp(null));

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Protected content'), findsNothing);
    });

    testWidgets('renders protected child when a user is authenticated', (
      tester,
    ) async {
      await tester.pumpWidget(buildGuardedApp(MockUsers.customer));

      expect(find.text('Protected content'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsNothing);
    });
  });
}
