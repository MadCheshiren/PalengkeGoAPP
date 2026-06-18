class CartItem {
  final String vendorName;
  final String productName;
  final double price;
  final String weight;
  final String pricePerKg;
  final String image;
  final int quantity;
  final bool selected;
  final int stockQuantity;

  const CartItem({
    required this.vendorName,
    required this.productName,
    required this.price,
    required this.weight,
    required this.pricePerKg,
    required this.image,
    this.quantity = 1,
    this.selected = true,
    this.stockQuantity = 10,
  });

  double get total => price * quantity;

  CartItem copyWith({
    String? vendorName,
    String? productName,
    double? price,
    String? weight,
    String? pricePerKg,
    String? image,
    int? quantity,
    bool? selected,
    int? stockQuantity,
  }) {
    return CartItem(
      vendorName: vendorName ?? this.vendorName,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}
