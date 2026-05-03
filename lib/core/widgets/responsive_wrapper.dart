import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 450, maxWidth: 450),
          child: ClipRect(
            child: child,
          ),
        ),
      ),
    );
  }
}
