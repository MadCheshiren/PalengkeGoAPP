import 'package:palengkego/core/theme/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/profile/application/preferences_provider.dart';
import 'package:palengkego/features/profile/domain/delivery_address.dart';

class SetDeliveryAddressScreen extends ConsumerStatefulWidget {
  const SetDeliveryAddressScreen({super.key});

  @override
  ConsumerState<SetDeliveryAddressScreen> createState() =>
      _SetDeliveryAddressScreenState();
}

class _SetDeliveryAddressScreenState
    extends ConsumerState<SetDeliveryAddressScreen> {
  final _labelController = TextEditingController();
  final _primaryAddressController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _notesController = TextEditingController();

  IconData? _selectedCustomIcon;

  static const List<String> _nagaBarangays = [
    'Abella',
    'Bagumbayan Norte',
    'Bagumbayan Sur',
    'Calauag',
    'Cararayan',
    'Carolina',
    'Concepcion Grande',
    'Concepcion Pequeña',
    'Dayangdang',
    'Del Rosario',
    'Dinaga',
    'Igualdad Interior',
    'Lerma',
    'Liboton',
    'Mabolo',
    'Pacol',
    'Panicuason',
    'Peñafrancia',
    'Sabang',
    'San Felipe',
    'San Francisco',
    'San Isidro',
    'Santa Cruz',
    'Tabuco',
    'Tinago',
    'Triangulo',
  ];

  @override
  void initState() {
    super.initState();
    final currentAddress = ref.read(preferencesProvider).deliveryAddress;
    _labelController.text = currentAddress.label == 'other'
        ? ''
        : currentAddress.label;
    _primaryAddressController.text = currentAddress.primaryAddress.isEmpty
        ? 'Magsaysay Ave, Naga City'
        : currentAddress.primaryAddress;
    _streetAddressController.text = currentAddress.streetAddress;
    _notesController.text = currentAddress.notes;
    if (currentAddress.iconCodePoint != null) {
      _selectedCustomIcon = IconData(
        currentAddress.iconCodePoint!,
        fontFamily: 'MaterialIcons',
      );
    }
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is DeliveryAddress) {
        _labelController.text = args.label == 'other' ? '' : args.label;
        _primaryAddressController.text = args.primaryAddress.isEmpty
            ? 'Magsaysay Ave, Naga City'
            : args.primaryAddress;
        _streetAddressController.text = args.streetAddress;
        _notesController.text = args.notes;
        if (args.iconCodePoint != null) {
          _selectedCustomIcon = IconData(
            args.iconCodePoint!,
            fontFamily: 'MaterialIcons',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _primaryAddressController.dispose();
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
          const bottomSheetHeight = 420.0; // Approximate height of bottom sheet
          const headerHeight = 60.0; // SafeArea + padding
          const visibleMapTop = headerHeight;
          final visibleMapBottom = constraints.maxHeight - bottomSheetHeight;
          final visibleMapCenter = (visibleMapTop + visibleMapBottom) / 2;
          final pinTopPosition =
              visibleMapCenter - 40; // Offset up by half the pin height

          return Stack(
            children: [
              // Map Background (placeholder with grid pattern)
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: const BoxDecoration(color: Color(0xFFE8F4F8)),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Move pin to adjust',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pin icon with animation effect
                    const Icon(
                      Icons.location_on,
                      size: 48,
                      color: AppTheme.primaryGreen,
                    ),
                    // Pin shadow
                    Container(
                      width: 20,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
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
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Set Delivery Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Draggable Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: 0.45,
                minChildSize: 0.2,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: kIsWeb ? 0.1 : 12,
                          sigmaY: kIsWeb ? 0.1 : 12,
                        ),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          decoration: BoxDecoration(
                            color: kIsWeb
                                ? const Color(
                                    0xFFE8F4F8,
                                  ).withValues(alpha: 0.85)
                                : Colors.white.withValues(alpha: 0.18),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: kIsWeb ? 0.6 : 0.35,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Drag Handle Pill
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.muted.withValues(
                                        alpha: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),

                                // Pin dropped near info
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
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
                                          color: AppTheme.primaryGreen
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.near_me,
                                          size: 24,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'PIN DROPPED NEAR',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.muted,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            TextField(
                                              controller:
                                                  _primaryAddressController,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                border: InputBorder.none,
                                                hintText: 'Enter City/Area',
                                                hintStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppTheme.muted,
                                                ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1F2937),
                                              ),
                                              onChanged: (val) {
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Naga City Barangay Autocomplete List
                                if (_primaryAddressController.text.isNotEmpty)
                                  _buildBarangaySuggestions(
                                    _primaryAddressController,
                                  ),

                                const SizedBox(height: 20),

                                // Label Input (Home, Work, etc)
                                _buildInputLabel(
                                  'LABEL (e.g. Home, Work, School)',
                                ),
                                const SizedBox(height: 8),
                                _buildLabelChips(),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _labelController,
                                        hintText: 'Custom Label',
                                        prefixIcon:
                                            _selectedCustomIcon ??
                                            Icons.label_outline,
                                        textCapitalization:
                                            TextCapitalization.words,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        _selectedCustomIcon ??
                                            Icons.add_reaction_outlined,
                                        color: AppTheme.primaryGreen,
                                      ),
                                      onPressed: () => _showIconPicker(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Street Address Input
                                _buildInputLabel('STREET ADDRESS / LANDMARKS'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _streetAddressController,
                                  hintText: 'Unit No., Building, Street Name',
                                  prefixIcon: Icons.location_on_outlined,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onChanged: (val) => setState(() {}),
                                ),
                                if (_streetAddressController.text.isNotEmpty)
                                  _buildBarangaySuggestions(
                                    _streetAddressController,
                                  ),

                                const SizedBox(height: 16),

                                // Notes Input
                                _buildInputLabel(
                                  'ADD NOTES FOR COURIER (OPTIONAL)',
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _notesController,
                                  hintText: 'e.g. Red gate, ring the doorbell',
                                  prefixIcon: Icons.notes_outlined,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),

                                const SizedBox(height: 24),

                                // Confirm Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        DeliveryAddress(
                                          label: _labelController.text.isEmpty
                                              ? 'Home'
                                              : _labelController.text,
                                          primaryAddress:
                                              _primaryAddressController.text,
                                          streetAddress:
                                              _streetAddressController.text,
                                          notes: _notesController.text,
                                          iconCodePoint:
                                              (_selectedCustomIcon ??
                                                      Icons.favorite_rounded)
                                                  .codePoint,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: const Text(
                                      'Confirm Address',
                                      style: TextStyle(
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
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showIconPicker(BuildContext context) {
    final icons = [
      Icons.home_outlined,
      Icons.work_outline_rounded,
      Icons.school_outlined,
      Icons.favorite_outline_rounded,
      Icons.lock_outline_rounded,
      Icons.star_outline_rounded,
      Icons.fitness_center_rounded,
      Icons.local_cafe_outlined,
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Label Icon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: icons.map((icon) {
                final isSelected = _selectedCustomIcon == icon;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCustomIcon = icon;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBarangaySuggestions(TextEditingController controller) {
    final query = controller.text.toLowerCase().trim();
    final matches = _nagaBarangays
        .where((b) => b.toLowerCase().contains(query))
        .take(5)
        .toList();

    if (matches.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: matches.map((barangay) {
          return ListTile(
            dense: true,
            leading: const Icon(
              Icons.location_city_rounded,
              size: 18,
              color: AppTheme.primaryGreen,
            ),
            title: Text(
              '$barangay, Naga City',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            onTap: () {
              setState(() {
                controller.text = '$barangay, Naga City';
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLabelChips() {
    final predefinedLabels = <Map<String, dynamic>>[
      {'name': 'Home', 'icon': Icons.home_outlined},
      {'name': 'Work', 'icon': Icons.work_outline},
      {'name': 'School', 'icon': Icons.school_outlined},
    ];

    final currentText = _labelController.text.trim();
    if (currentText.isNotEmpty) {
      final isPredefined = predefinedLabels.any(
        (l) => l['name'].toString().toLowerCase() == currentText.toLowerCase(),
      );
      if (!isPredefined) {
        predefinedLabels.add({
          'name': currentText,
          'icon': _selectedCustomIcon ?? Icons.favorite_border_rounded,
        });
      }
    }

    try {
      final savedAddresses = ref.watch(preferencesProvider).savedAddresses;
      for (final addr in savedAddresses) {
        final label = addr.label.trim();
        if (label.isNotEmpty) {
          final exists = predefinedLabels.any(
            (l) => l['name'].toString().toLowerCase() == label.toLowerCase(),
          );
          if (!exists) {
            predefinedLabels.add({
              'name': label,
              'icon': addr.iconCodePoint != null
                  ? IconData(addr.iconCodePoint!, fontFamily: 'MaterialIcons')
                  : Icons.favorite_border_rounded,
            });
          }
        }
      }
    } catch (_) {}

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: predefinedLabels.map((label) {
          final isSelected =
              _labelController.text.toLowerCase().trim() ==
              (label['name'] as String).toLowerCase().trim();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label['name'] as String),
              avatar: Icon(
                label['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : AppTheme.primaryGreen,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _labelController.text = selected
                      ? label['name'] as String
                      : '';
                  if (selected &&
                      !(label['name'] == 'Home' ||
                          label['name'] == 'Work' ||
                          label['name'] == 'School')) {
                    _selectedCustomIcon = label['icon'] as IconData;
                  }
                });
              },
              selectedColor: AppTheme.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppTheme.border,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextCapitalization textCapitalization = TextCapitalization.words,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextFormField(
        controller: controller,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.muted,
          ),
          prefixIcon: Icon(prefixIcon, size: 20, color: AppTheme.muted),
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
      ..color = AppTheme.border
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
