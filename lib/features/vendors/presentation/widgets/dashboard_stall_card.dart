import 'package:flutter/material.dart';
import 'package:palengkego/features/vendors/application/vendor_stall_controller.dart';

class DashboardStallCard extends StatelessWidget {
  final bool isStallOpen;
  final ValueChanged<bool> onToggleStallOpen;

  const DashboardStallCard({
    super.key,
    required this.isStallOpen,
    required this.onToggleStallOpen,
  });

  @override
  Widget build(BuildContext context) {
    final controller = VendorStallController.instance;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFD5E7DE),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: controller.bannerImage != null
                  ? DecorationImage(
                      image: NetworkImage(controller.bannerImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: controller.bannerImage == null
                ? const Center(
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 48,
                      color: Color(0xFF0B372B),
                    ),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (controller.avatarImage != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      image: DecorationImage(
                        image: NetworkImage(controller.avatarImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.name,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.location,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isStallOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isStallOpen
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isStallOpen,
                      onChanged: onToggleStallOpen,
                      activeThumbColor: const Color(0xFF0B372B),
                      activeTrackColor: const Color(0xFF0B372B).withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
