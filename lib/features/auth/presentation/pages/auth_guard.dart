import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/auth/domain/app_user.dart';

/// Guard widget that wraps protected pages.
/// If no user is authenticated, reactively renders a fallback login screen.
class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key, required this.child, this.allowedRoles});

  final Widget child;
  final Set<UserRole>? allowedRoles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F8F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF0B372B),
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: Color(0xFF0B372B),
                ),
                const SizedBox(height: 24),
                Text(
                  'Account Required',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B372B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You need to be logged in to access this page.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B372B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.registration);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0B372B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B372B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (allowedRoles != null && !allowedRoles!.contains(user.role)) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F8F7),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 64,
                  color: Color(0xFF0B372B),
                ),
                SizedBox(height: 24),
                Text(
                  'Access Restricted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B372B),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'This page is only available for the correct account type.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}
