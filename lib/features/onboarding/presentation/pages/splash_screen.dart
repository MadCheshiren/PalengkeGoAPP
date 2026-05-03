import 'package:flutter/material.dart';
import 'package:palengkego/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B372B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image (no background version)
            Image.asset(
              'assets/images/logonobg.png',
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // App Name
            const Text(
              'PalengkeGo',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'SKIP THE ROAM, ORDER FROM HOME',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 80),
            // Loading Spinner
            AnimatedBuilder(
              animation: _loadingController,
              builder: (context, child) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.transparent,
                      width: 4,
                    ),
                  ),
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(
                        const Color(0xFFF59E0B),
                        const Color(0xFF6D9773),
                        _loadingController.value,
                      )!,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
