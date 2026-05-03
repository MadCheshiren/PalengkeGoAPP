import 'package:flutter/material.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.size = 40,
    this.titleSize = 20,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double size;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Color(0xFFF6F8F7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF0B372B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0B372B),
                ),
              ),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: trailing == null ? const SizedBox.shrink() : Center(child: trailing),
          ),
        ],
      ),
    );
  }
}
