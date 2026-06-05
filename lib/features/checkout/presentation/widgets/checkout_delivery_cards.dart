import 'package:flutter/material.dart';
import 'package:palengkego/core/services/customer_preferences_service.dart';

class CheckoutDeliveryAddressCard extends StatelessWidget {
  const CheckoutDeliveryAddressCard({
    super.key,
    required this.deliveryAddress,
  });

  final DeliveryAddress deliveryAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deliveryAddress.contactName,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deliveryAddress.displayLine,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutDeliveryMapCard extends StatelessWidget {
  final VoidCallback? onTap;
  const CheckoutDeliveryMapCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD9FBE6), Color(0xFFE9F7EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(
                painter: _MapPatternPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.place_rounded,
              size: 40,
              color: Color(0xFF0B372B),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0B372B)),
                  SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B372B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF9CA3AF).withOpacity(0.18)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final smallRoadPaint = Paint()
      ..color = const Color(0xFF9CA3AF).withOpacity(0.12)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-20, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.15),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height),
      Offset(size.width * 0.85, -10),
      roadPaint,
    );
    canvas.drawLine(
      Offset(-10, size.height * 0.78),
      Offset(size.width + 10, size.height * 0.58),
      smallRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, size.height + 10),
      Offset(size.width * 0.18, -10),
      smallRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
