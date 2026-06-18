class VendorProduct {
  const VendorProduct({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.pricePerKg,
    required this.weight,
    required this.imageUrl,
    this.isActive = true,
    this.stockQuantity = 0,
    this.discountPercentage,
  });

  final String id;
  final String vendorId;
  final String name;
  final String description;
  final String category;
  final double price;
  final String pricePerKg;
  final String weight;
  final String imageUrl;
  final bool isActive;
  final int stockQuantity;
  final double? discountPercentage;

  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;
  double get discountedPrice => hasDiscount ? price * (1 - (discountPercentage! / 100)) : price;

  VendorProduct copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? description,
    String? category,
    double? price,
    String? pricePerKg,
    String? weight,
    String? imageUrl,
    bool? isActive,
    int? stockQuantity,
    double? discountPercentage,
  }) {
    return VendorProduct(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'pricePerKg': pricePerKg,
      'weight': weight,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'stockQuantity': stockQuantity,
      'discountPercentage': discountPercentage,
    };
  }
}
