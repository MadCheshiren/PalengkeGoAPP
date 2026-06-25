class OrderLineItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final String weight;
  final String pricePerKg;
  final String image;

  const OrderLineItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.weight,
    required this.pricePerKg,
    required this.image,
  });

  double get total => unitPrice * quantity;

  String get quantityLabel {
    if (weight == '1kg') {
      return '$quantity kg';
    }
    if (weight == '1pc' || weight == '1 pc') {
      return '$quantity kg';
    }
    return '$quantity x $weight';
  }
}
