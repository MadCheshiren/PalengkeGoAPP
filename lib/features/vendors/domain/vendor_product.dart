class VendorProduct {
  const VendorProduct({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.pricePerKg,
    required this.weight,
    required this.imageUrl,
  });

  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final String pricePerKg;
  final String weight;
  final String imageUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'description': description,
      'price': price,
      'pricePerKg': pricePerKg,
      'weight': weight,
      'imageUrl': imageUrl,
    };
  }
}
