import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:palengkego/core/services/customer_preferences_service.dart';

class SetDeliveryAddressScreen extends StatefulWidget {
  const SetDeliveryAddressScreen({super.key});

  @override
  State<SetDeliveryAddressScreen> createState() => _SetDeliveryAddressScreenState();
}

class _SetDeliveryAddressScreenState extends State<SetDeliveryAddressScreen> {
  final _streetAddressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentAddress = globalCustomerPreferences.deliveryAddress;
    _streetAddressController.text = currentAddress.streetAddress;
    _notesController.text = currentAddress.notes;
  }

  @override
  void dispose() {
    _streetAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomSheetHeight = 420.0; // Approximate height of bottom sheet
          final headerHeight = 60.0; // SafeArea + padding
          final visibleMapTop = headerHeight;
          final visibleMapBottom = constraints.maxHeight - bottomSheetHeight;
          final visibleMapCenter = (visibleMapTop + visibleMapBottom) / 2;
          final pinTopPosition = visibleMapCenter - 40; // Offset up by half the pin height

          return Stack(
            children: [
              // Map Background (placeholder with grid pattern)
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4F8),
                ),
                child: CustomPaint(
                  painter: MapGridPainter(),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                ),
              ),

              // Center Pin - dynamically positioned above the bottom sheet
              Positioned(
                top: pinTopPosition,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tooltip above the pin
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Move pin to adjust',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pin icon with animation effect
                    const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Color(0xFF0B372B),
                    ),
                    // Pin shadow
                    Container(
                      width: 20,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B372B).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              // Header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF0B372B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Set Delivery Address',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B372B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Frosted Glass Bottom Sheet
              // BackdropFilter works on mobile but NOT on Flutter web.
              // Auto-detect platform: use real blur on mobile, tinted overlay on web.
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: kIsWeb ? 0.1 : 12,
                      sigmaY: kIsWeb ? 0.1 : 12,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kIsWeb
                            ? const Color(0xFFE8F4F8).withOpacity(0.85)
                            : Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(kIsWeb ? 0.6 : 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Pin dropped near info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B372B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.near_me,
                                  size: 24,
                                  color: Color(0xFF0B372B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PIN DROPPED NEAR',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Magsaysay Ave, Naga City',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Street Address Input
                        _buildInputLabel('STREET ADDRESS / LANDMARKS'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _streetAddressController,
                          hintText: 'Unit No., Building, Street Name',
                          prefixIcon: Icons.location_on_outlined,
                        ),

                        const SizedBox(height: 16),

                        // Notes Input
                        _buildInputLabel('ADD NOTES FOR COURIER (OPTIONAL)'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _notesController,
                          hintText: 'e.g. Red gate, ring the doorbell',
                          prefixIcon: Icons.notes_outlined,
                        ),

                        const SizedBox(height: 24),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, {
                                'address': 'Magsaysay Ave, Naga City',
                                'streetAddress': _streetAddressController.text,
                                'notes': _notesController.text,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B372B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: const Text(
                              'Confirm Address',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(
            prefixIcon,
            size: 20,
            color: const Color(0xFF94A3B8),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// Map Grid Painter for placeholder map effect
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1E7DD)
      ..strokeWidth = 1;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw some "roads" as thicker lines
    final roadPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 3;

    // Main roads
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.6),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
