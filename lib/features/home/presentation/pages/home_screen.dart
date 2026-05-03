import 'package:flutter/material.dart';
import 'package:palengkego/features/home/presentation/pages/market_screen.dart';

/// Temporary home tab placeholder.
/// The current Figma-provided customer home frame matches the market listing
/// much more closely than the older standalone home implementation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MarketScreen();
  }
}
