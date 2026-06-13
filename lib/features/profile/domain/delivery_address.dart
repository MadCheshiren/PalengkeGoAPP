class DeliveryAddress {
  const DeliveryAddress({
    required this.primaryAddress,
    this.streetAddress = '',
    this.notes = '',
    this.contactName = 'Juan Dela Cruz (+63)94*****23',
  });

  final String primaryAddress;
  final String streetAddress;
  final String notes;
  final String contactName;

  String get displayLine {
    if (streetAddress.trim().isEmpty) return primaryAddress;
    return '$streetAddress, $primaryAddress';
  }
}
