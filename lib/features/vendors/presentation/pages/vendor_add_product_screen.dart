import 'package:flutter/material.dart';
import '../widgets/vendor_screen_header.dart';

/// Vendor Add Product Screen
/// Form to add a new product to the vendor's inventory.
class VendorAddProductScreen extends StatefulWidget {
  const VendorAddProductScreen({super.key});

  @override
  State<VendorAddProductScreen> createState() => _VendorAddProductScreenState();
}

class _VendorAddProductScreenState extends State<VendorAddProductScreen> {
  bool _inStock = true;
  String _selectedCategory = '';

  final List<String> _categories = [
    'Fish & Seafood',
    'Meat & Poultry',
    'Vegetables',
    'Fruits',
    'Rice & Grains',
    'Spices & Condiments',
  ];

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
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Upload Image',
                                style: TextStyle(
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
                    _buildTextField(
                      hint: 'e.g. Organic Avocados',
                    ),
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

                    // Price fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Price / Kilo'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                hint: '\$ 0.00',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Price / Piece'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                hint: '\$ 0.00',
                              ),
                            ],
                          ),
                        ),
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
                          activeTrackColor: const Color(0xFF0B372B).withValues(alpha: 0.3),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save Product Button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product saved locally.'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B372B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
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
          borderSide: const BorderSide(
            color: Color(0xFF0B372B),
            width: 1,
          ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
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
        );
      },
    );
  }
}
