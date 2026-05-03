import 'package:flutter/foundation.dart';

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

class CustomerPreferencesService extends ChangeNotifier {
  DeliveryAddress _deliveryAddress = const DeliveryAddress(
    primaryAddress: 'Magsaysay Ave, Naga City',
    streetAddress: '123 Magsaysay Avenue',
  );

  String _paymentMethod = 'cod';
  String? _cardLabel;

  DeliveryAddress get deliveryAddress => _deliveryAddress;
  String get paymentMethod => _paymentMethod;
  String? get cardLabel => _cardLabel;

  String get paymentTitle {
    switch (_paymentMethod) {
      case 'gcash':
        return 'GCash';
      case 'card':
        return _cardLabel ?? 'Saved Card';
      default:
        return 'Cash on Delivery';
    }
  }

  String get paymentSubtitle {
    switch (_paymentMethod) {
      case 'gcash':
        return 'Pay with GCash via Paymongo';
      case 'card':
        return 'Pay with your saved debit or credit card';
      default:
        return 'Pay when you receive your order';
    }
  }

  void updateAddress({
    required String primaryAddress,
    String streetAddress = '',
    String notes = '',
  }) {
    _deliveryAddress = DeliveryAddress(
      primaryAddress: primaryAddress,
      streetAddress: streetAddress,
      notes: notes,
    );
    notifyListeners();
  }

  void updatePaymentMethod(String method, {String? cardLabel}) {
    _paymentMethod = method;
    _cardLabel = cardLabel;
    notifyListeners();
  }
}

final globalCustomerPreferences = CustomerPreferencesService();
