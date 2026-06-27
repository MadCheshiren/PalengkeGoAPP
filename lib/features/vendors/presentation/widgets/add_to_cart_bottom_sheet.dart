import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/utils/unit_helper.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';

import 'package:palengkego/features/vendors/domain/vendor_product.dart';

class AddToCartBottomSheet extends ConsumerStatefulWidget {
  final String vendorName;
  final VendorProduct product;

  const AddToCartBottomSheet({
    super.key,
    required this.vendorName,
    required this.product,
  });

  static Future<void> show(
    BuildContext context, {
    required String vendorName,
    required VendorProduct product,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
      builder: (context) =>
          AddToCartBottomSheet(vendorName: vendorName, product: product),
    );
  }

  @override
  ConsumerState<AddToCartBottomSheet> createState() =>
      _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends ConsumerState<AddToCartBottomSheet> {
  late final List<String> _weights;
  String? _selectedWeight;
  double _customWeightKg = 1.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Read unit directly from pricePerKg (e.g. '₱150/kg' or '₱10/pc').
    // Only fall back to name-heuristic if pricePerKg is absent/empty.
    final isPiece = _isPieceProduct();
    _weights = isPiece
        ? ['1 pc', '3 pcs', '6 pcs', '12 pcs']
        : ['1kg', '1/2kg', '1/4kg', '1/8kg'];
    _selectedWeight = _weights.first;
  }

  /// Returns true when the product is sold per-piece.
  /// Checks pricePerKg string first (most reliable), then falls back to name.
  bool _isPieceProduct() {
    final pkgLower = widget.product.pricePerKg.toLowerCase();
    if (pkgLower.contains('/kg')) return false;
    if (pkgLower.contains('/pc') || pkgLower.contains('/piece')) return true;
    // fallback: name-based heuristic
    return UnitHelper.isPieceUnit(
      widget.product.name,
      widget.product.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = widget.product.discountedPrice;
    final selectedMultiplier = _customWeightKg;
    final selectedUnitPrice = basePrice * selectedMultiplier;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, -4),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      width: 107,
                      height: 99,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 107,
                        height: 99,
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(
                          Icons.image_rounded,
                          size: 28,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0B372B),
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _priceLabel(basePrice),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6D9773),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _weights.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _weights.length <= 2 ? 2 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 18,
                  childAspectRatio: 2.32,
                ),
                itemBuilder: (context, index) {
                  final weightLabel = _weights[index];
                  final isSelected = weightLabel == _selectedWeight;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWeight = weightLabel;
                        if (weightLabel == '1kg') {
                          _customWeightKg = 1.0;
                        } else if (weightLabel == '1/2kg') {
                          _customWeightKg = 0.5;
                        } else if (weightLabel == '1/4kg') {
                          _customWeightKg = 0.25;
                        } else if (weightLabel == '1/8kg') {
                          _customWeightKg = 0.125;
                        } else if (weightLabel == '1 pc') {
                          _customWeightKg = 1;
                        } else if (weightLabel == '3 pcs') {
                          _customWeightKg = 3;
                        } else if (weightLabel == '6 pcs') {
                          _customWeightKg = 6;
                        } else if (weightLabel == '12 pcs') {
                          _customWeightKg = 12;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0C3A2D)
                            : const Color(0xFFF1F5F4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0C3A2D)
                              : const Color(0xFFF3F4F6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color.fromRGBO(0, 0, 0, 0.25)
                                : const Color.fromRGBO(0, 0, 0, 0.18),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        weightLabel,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF0C3A2D),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Quantity',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0B372B),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F2),
                      border: Border.all(color: const Color(0xFFE5E7E6)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _roundQuantityButton(
                          icon: Icons.remove_rounded,
                          onTap:
                              (_selectedWeight == '1kg' ||
                                  _selectedWeight == null)
                              ? () {
                                  if (_customWeightKg > 1.0) {
                                    setState(() {
                                      _customWeightKg -= 0.5;
                                      if (_customWeightKg == 1.0) {
                                        _selectedWeight = '1kg';
                                      }
                                    });
                                  }
                                }
                              : () {}, // Disabled if not custom
                          foreground:
                              (_selectedWeight == '1kg' ||
                                      _selectedWeight == null) &&
                                  _customWeightKg > 1.0
                              ? const Color(0xFF6D9773)
                              : const Color(0xFF94A3B8), // Greyed out
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            (_selectedWeight == '1kg' ||
                                    _selectedWeight == null)
                                ? _formatCustomWeightNum(_customWeightKg)
                                : '1', // Fixed quantity for other weights
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  (_selectedWeight == '1kg' ||
                                      _selectedWeight == null)
                                  ? const Color(0xFF0B372B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            _isPieceProduct() ? 'pc' : 'kg',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color:
                                  (_selectedWeight == '1kg' ||
                                      _selectedWeight == null)
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ),
                        _roundQuantityButton(
                          icon: Icons.add_rounded,
                          onTap:
                              (_selectedWeight == '1kg' ||
                                  _selectedWeight == null)
                              ? () {
                                  if (_customWeightKg <
                                      widget.product.stockQuantity) {
                                    setState(() {
                                      _customWeightKg += 0.5;
                                      _selectedWeight = null;
                                    });
                                  } else {
                                    if (!mounted) return;
                                    ScaffoldMessenger.maybeOf(
                                      context,
                                    )?.showSnackBar(
                                      const SnackBar(
                                        content: Text('Maximum stock reached'),
                                      ),
                                    );
                                  }
                                }
                              : () {}, // Disabled if not custom
                          background:
                              (_selectedWeight == '1kg' ||
                                  _selectedWeight == null)
                              ? const Color(0xFF0C3A2D)
                              : const Color(
                                  0xFFE2E8F0,
                                ), // Greyed out background
                          foreground:
                              (_selectedWeight == '1kg' ||
                                  _selectedWeight == null)
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_isSubmitting || widget.product.stockQuantity <= 0)
                      ? null
                      : () {
                          if (!mounted) return;
                          if (widget.product.stockQuantity <= 0) {
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                              const SnackBar(
                                content: Text('Maximum stock reached'),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isSubmitting = true;
                          });

                          ref
                              .read(cartServiceProvider)
                              .addToCart(
                                vendorName: widget.vendorName,
                                productName: widget.product.name,
                                price: selectedUnitPrice,
                                weight:
                                    _selectedWeight ??
                                    _formatCustomWeight(_customWeightKg),
                                pricePerKg: _priceLabel(basePrice),
                                image: widget.product.imageUrl.isNotEmpty
                                    ? widget.product.imageUrl
                                    : 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop',
                                quantity:
                                    1, // Quantity is always 1, weight acts as the multiplier
                                stockQuantity: widget.product.stockQuantity,
                              );

                          // Look up messenger BEFORE popping
                          final messenger = ScaffoldMessenger.of(context);

                          if (mounted) {
                            Navigator.pop(context);
                          }

                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                '${widget.product.name} added to cart',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3A2D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: const Color.fromRGBO(11, 55, 43, 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: const Text(
                    'Add to cart',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    Color background = Colors.transparent,
    required Color foreground,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: foreground),
      ),
    );
  }

  String _formatCustomWeightNum(double val) {
    if (val == val.truncateToDouble()) {
      return val.toInt().toString();
    }
    final intPart = val.toInt();
    final fraction = val - intPart;
    String fractionStr = '';
    if (fraction == 0.5) {
      fractionStr = '1/2';
    } else {
      fractionStr = fraction.toStringAsFixed(1);
    }

    if (intPart == 0) return fractionStr;
    return '$intPart $fractionStr';
  }

  String _formatCustomWeight(double val) {
    return '${_formatCustomWeightNum(val)}kg';
  }

  String _priceLabel(double basePrice) {
    final unit = _isPieceProduct() ? 'pc' : 'kg';
    return 'PHP ${basePrice.toInt()}/$unit';
  }
}
