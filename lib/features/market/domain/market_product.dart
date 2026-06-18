class MarketProduct {
  const MarketProduct({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.unit,
    required this.weight,
    required this.pricePerKg,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.stockQuantity = 0,
  });

  final String id;
  final String vendorId;
  final String name;
  final double price;
  final String unit;
  final String weight;
  final String pricePerKg;
  final String description;
  final String category;
  final String imageUrl;
  final int stockQuantity;

  factory MarketProduct.fromMap(Map<String, dynamic> map) {
    return MarketProduct(
      id: map['id'] as String? ?? '',
      vendorId: map['vendorId'] as String? ?? '',
      name: map['name'] as String? ?? 'Product',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'kg',
      weight: map['weight'] as String? ?? '1kg',
      pricePerKg: map['pricePerKg'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      stockQuantity: map['stockQuantity'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'price': price,
      'unit': unit,
      'weight': weight,
      'pricePerKg': pricePerKg,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
    };
  }
}
