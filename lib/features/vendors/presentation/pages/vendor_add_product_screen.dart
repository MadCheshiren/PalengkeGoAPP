import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/vendors/application/vendor_provider.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import '../widgets/vendor_screen_header.dart';

/// Vendor Add Product Screen
/// Form to add a new product to the vendor's inventory.
class VendorAddProductScreen extends ConsumerStatefulWidget {
  const VendorAddProductScreen({super.key});

  @override
  ConsumerState<VendorAddProductScreen> createState() => _VendorAddProductScreenState();
}

class _VendorAddProductScreenState extends ConsumerState<VendorAddProductScreen> {
  bool _inStock = true;
  bool _isSaving = false;
  String _selectedCategory = '';
  String _imageUrl = '';

  bool get _isPieceUnit {
    return _selectedCategory == 'Vegetables' ||
        _selectedCategory == 'Fruits' ||
        _selectedCategory == 'Maritatas' ||
        _selectedCategory == 'Sari-Sari';
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _categories = [
    'Fish & Seafood',
    'Meat & Poultry',
    'Vegetables',
    'Fruits',
    'Rice & Grains',
    'Spices & Condiments',
    'Maritatas',
    'Sari-Sari',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (_isSaving || !mounted) return;
    
    // Prevent layout shift crashes from the keyboard overlays when the button turns into a loader
    FocusScope.of(context).unfocus();
    
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final priceStr = _priceController.text.trim();
      final double price = double.tryParse(priceStr) ?? 0.0;
      final vendorId = ref.read(currentVendorIdProvider);

      final newProduct = VendorProduct(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        vendorId: vendorId,
        name: name,
        description: '', // Reset description to empty or actual description if needed later
        category: _selectedCategory,
        price: price,
        pricePerKg: _isPieceUnit ? 'PHP ${price.toInt()}/PC/s' : 'PHP ${price.toInt()}/KG/s',
        weight: _isPieceUnit ? '1 pc' : '1 kg',
        imageUrl: _imageUrl,
        isActive: _inStock,
      );

      await ref.read(vendorProductsManagerProvider(vendorId)).addProduct(newProduct);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Product added successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Close add product screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to add product: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const VendorScreenHeader(title: 'Add Product'),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // General Information
                    const Text(
                      'General Information',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload Photo Area
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _imageUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          else ...[
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Color(0xFF0B372B),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Upload Photo',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B372B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap to select or take a photo of the\nproduct',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _imageUrl = 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=200&h=200';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _imageUrl.isEmpty ? 'Upload Image' : 'Change Image',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0B372B),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product Name
                    _buildLabel('Product Name'),
                    const SizedBox(height: 8),
                    _buildTextField(hint: 'e.g. Organic Avocados', controller: _nameController),
                    const SizedBox(height: 20),

                    // Category
                    _buildLabel('Category'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _showCategoryPicker(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory.isEmpty
                                  ? 'Select Item'
                                  : _selectedCategory,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                color: _selectedCategory.isEmpty
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF111827),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(_isPieceUnit ? 'Price / PC/s' : 'Price / KG/s'),
                        const SizedBox(height: 8),
                        _buildTextField(hint: '0.00', controller: _priceController, keyboardType: TextInputType.number),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // In Stock Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'In Stock',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Available for customers to buy',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _inStock,
                          onChanged: (value) {
                            setState(() {
                              _inStock = value;
                            });
                          },
                          activeThumbColor: const Color(0xFF0B372B),
                          activeTrackColor: const Color(
                            0xFF0B372B,
                          ).withValues(alpha: 0.3),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save Product Button
                    GestureDetector(
                      onTap: _isSaving ? null : _saveProduct,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isSaving ? const Color(0xFF9CA3AF) : const Color(0xFF0B372B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Save Product',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        color: Color(0xFF111827),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 14,
          color: Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0B372B), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Select Category',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                ..._categories.map((category) {
                  return ListTile(
                    title: Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
