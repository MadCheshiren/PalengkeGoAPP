import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/app_services.dart';
import 'package:palengkego/features/auth/application/auth_provider.dart';
import 'package:palengkego/features/vendors/application/vendor_provider.dart';
import 'package:palengkego/features/vendors/domain/vendor_product.dart';
import 'package:palengkego/core/utils/image_picker_helper.dart';
import 'dart:io';
import '../widgets/vendor_screen_header.dart';

/// Vendor Add / Edit Product Screen
/// Pass [existingProduct] to enter edit mode.
class VendorAddProductScreen extends ConsumerStatefulWidget {
  final VendorProduct? existingProduct;

  const VendorAddProductScreen({super.key, this.existingProduct});

  @override
  ConsumerState<VendorAddProductScreen> createState() =>
      _VendorAddProductScreenState();
}

class _VendorAddProductScreenState
    extends ConsumerState<VendorAddProductScreen> {
  bool _inStock = true;
  bool _isSaving = false;
  String _selectedCategory = '';
  String _imageUrl = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  bool get _isEditMode => widget.existingProduct != null;

  double? get _calculatedDiscountedPrice {
    final double? price = double.tryParse(_priceController.text.trim());
    final double? discount = double.tryParse(_discountController.text.trim());
    if (price != null && discount != null && discount > 0) {
      return price * (1 - (discount / 100));
    }
    return null;
  }

  bool get _isPieceUnit {
    return _selectedCategory == 'Vegetables' ||
        _selectedCategory == 'Fruits' ||
        _selectedCategory == 'Maritatas' ||
        _selectedCategory == 'Sari-Sari';
  }

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
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    if (p != null) {
      _nameController.text = p.name;
      _priceController.text = p.price.toStringAsFixed(0);
      _stockController.text = p.stockQuantity.toString();
      if (p.discountPercentage != null && p.discountPercentage! > 0) {
        _discountController.text = p.discountPercentage.toString();
      }
      _selectedCategory = p.category;
      _imageUrl = p.imageUrl;
      _inStock = p.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    // Defer to next frame — same Flutter Web ScrollView deactivation fix.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isSaving) return;
      _performSave();
    });
  }

  Future<void> _performSave() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppServices.showError('Please enter a product name.');
      return;
    }
    if (_selectedCategory.isEmpty) {
      AppServices.showError('Please select a category.');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      AppServices.showError('Please enter a price.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final int stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final double? discount = double.tryParse(_discountController.text.trim());
      // Read ref synchronously BEFORE any await — safe even if widget unmounts later.
      final vendorId = ref.read(currentVendorIdProvider);
      final manager = ref.read(vendorProductsManagerProvider(vendorId));

      final product = VendorProduct(
        id: _isEditMode
            ? widget.existingProduct!.id
            : 'p${DateTime.now().millisecondsSinceEpoch}',
        vendorId: vendorId,
        name: name,
        description: '',
        category: _selectedCategory,
        price: price,
        pricePerKg: _isPieceUnit
            ? 'PHP ${price.toInt()}/pc'
            : 'PHP ${price.toInt()}/kg',
        weight: _isPieceUnit ? '1 pc' : '1kg',
        imageUrl: _imageUrl,
        isActive: _inStock,
        stockQuantity: stock,
        discountPercentage: discount,
      );

      if (_isEditMode) {
        await manager.updateProduct(product);
      } else {
        await manager.addProduct(product);
      }

      if (!mounted) return;

      setState(() => _isSaving = false);

      // Show success bottom sheet
      await _showSuccessSheet(name);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppServices.showError('Failed to save product: $e');
    }
  }

  Future<void> _showSuccessSheet(String productName) async {
    // Capture the navigator BEFORE the sheet opens.
    // After Navigator.pop(ctx) fires inside the sheet, the parent widget's
    // context may already be deactivated on Flutter Web — using the pre-captured
    // navigator avoids the "deactivated widget ancestor" crash.
    final navigator = Navigator.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 36,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEditMode ? 'Product Updated!' : 'Product Added!',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B372B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"$productName" has been ${_isEditMode ? 'updated in' : 'added to'} your inventory and is now visible to customers.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // close the sheet
                  navigator
                      .pop(); // close add/edit screen (pre-captured, never stale)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B372B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back to Products',
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
    );
  }

  void _deleteProduct() {
    // On Flutter Web, tapping a button inside a ScrollView can fire the
    // handler while the element tree is mid-layout / briefly deactivated.
    // Deferring to the next frame guarantees the tree is stable.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showDeleteConfirmation();
    });
  }

  Future<void> _showDeleteConfirmation() async {
    // All context lookups happen synchronously before any await.
    final navigator = Navigator.of(context);
    final productName = widget.existingProduct!.name;
    final productId = widget.existingProduct!.id;
    final vendorId = ref.read(currentVendorIdProvider);
    final manager = ref.read(vendorProductsManagerProvider(vendorId));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Product?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$productName"? This will remove it from your inventory and the customer view immediately.',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (mounted) setState(() => _isSaving = true);

    try {
      await manager.deleteProduct(productId);
      // Use global key — zero context traversal, safe after any async gap.
      AppServices.showSnackBar('"$productName" has been deleted.');
      navigator.pop();
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
      AppServices.showError('Failed to delete product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            VendorScreenHeader(
              title: _isEditMode ? 'Edit Product' : 'Add Product',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        final file = await ImagePickerHelper.pickImage(context);
                        if (!mounted) return;
                        if (file != null) {
                          setState(() {
                            _imageUrl = file.path;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            if (_imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _imageUrl.startsWith('http')
                                    ? Image.network(
                                        _imageUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 48,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                      )
                                    : Image.file(
                                        File(_imageUrl),
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
                                'Tap to select a photo of the product',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                            if (_imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Tap to change image',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  color: const Color(
                                    0xFF0B372B,
                                  ).withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product Name
                    _buildLabel('Product Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: 'e.g. Organic Avocados',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),

                    // Category
                    _buildLabel('Category'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showCategoryPicker(context),
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
                                  ? 'Select Category'
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(_isPieceUnit ? 'Price / pc' : 'Price / kg'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                hint: '0.00',
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                prefixText: 'PHP  ',
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Discount %'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                hint: 'e.g. 15',
                                controller: _discountController,
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                suffixText: '%',
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_calculatedDiscountedPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_offer_rounded, color: Color(0xFF16A34A), size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                'Discounted Price:',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  color: Color(0xFF166534),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'PHP ${_calculatedDiscountedPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Stock Quantity
                    _buildLabel('Stock Quantity'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: '0',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      suffixText: _isPieceUnit ? 'pcs' : 'kg',
                    ),
                    const SizedBox(height: 24),

                    // In Stock Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                          onChanged: (value) =>
                              setState(() => _inStock = value),
                          activeThumbColor: const Color(0xFF0B372B),
                          activeTrackColor: const Color(
                            0xFF0B372B,
                          ).withValues(alpha: 0.3),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Save / Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B372B),
                          disabledBackgroundColor: const Color(0xFF9CA3AF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Update Product' : 'Save Product',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    // Delete Button — edit mode only
                    if (_isEditMode) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : _deleteProduct,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Color(0xFFEF4444),
                          ),
                          label: const Text(
                            'Delete Product',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFEF4444),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
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
    String? prefixText,
    String? suffixText,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        color: Color(0xFF111827),
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
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
      builder: (ctx) {
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
                  final isSelected = category == _selectedCategory;
                  return ListTile(
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF0B372B),
                          )
                        : null,
                    title: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFF0B372B)
                            : const Color(0xFF374151),
                      ),
                    ),
                    onTap: () {
                      setState(() => _selectedCategory = category);
                      Navigator.pop(ctx);
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
