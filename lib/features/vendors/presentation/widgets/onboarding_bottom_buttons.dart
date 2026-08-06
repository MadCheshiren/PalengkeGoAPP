import 'package:flutter/material.dart';

class OnboardingBottomButtons extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const OnboardingBottomButtons({
    super.key,
    required this.currentStep,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Business Information (Step 0): Back + Save
          if (currentStep == 0) ...[
            Expanded(
              child: GestureDetector(
                onTap: onPrevious,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF0B372B)),
                  ),
                  child: const Center(
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B372B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Steps 1-3: Just Save/Submit (full width)
          if (currentStep >= 1)
            Expanded(
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B372B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      currentStep == 3 ? 'Submit' : 'Save',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
