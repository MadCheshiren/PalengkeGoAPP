import 'package:flutter/material.dart';

class OnboardingIdCardStep extends StatelessWidget {
  final String selectedIdType;
  final ValueChanged<String> onIdTypeChanged;

  const OnboardingIdCardStep({
    super.key,
    required this.selectedIdType,
    required this.onIdTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Complete list of Philippine government IDs from Figma
    final idTypes = [
      'Unified Multi-Purpose Identification (UMID) Card',
      'Social Security System (SSS) Card',
      'Government Service Insurance System (GSIS) e-Card',
      'Land Transportation Office (LTO) Driver\'s License',
      'Philippine Postal ID',
      'Philippine Passport',
      'PhilHealth ID',
      'PhilID / ePhilID (PhilSys)',
      'Professional Regulation Commission (PRC) ID',
      'Alien Certification of Registration',
      'Foreign Passport',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(idTypes.length, (index) {
            final type = idTypes[index];
            final isSelected = selectedIdType == type;
            return GestureDetector(
              onTap: () => onIdTypeChanged(type),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0FDF4)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0B372B)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF0B372B),
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
