import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/profile/domain/delivery_address.dart';

class CustomerPreferencesState {
  final DeliveryAddress deliveryAddress;
  final String paymentMethod;
  final String? cardLabel;

  const CustomerPreferencesState({
    required this.deliveryAddress,
    required this.paymentMethod,
    this.cardLabel,
  });

  CustomerPreferencesState copyWith({
    DeliveryAddress? deliveryAddress,
    String? paymentMethod,
    String? cardLabel,
  }) {
    return CustomerPreferencesState(
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardLabel: cardLabel ?? this.cardLabel,
    );
  }

  String get paymentTitle {
    switch (paymentMethod) {
      case 'gcash':
        return 'GCash';
      case 'card':
        return cardLabel ?? 'Saved Card';
      default:
        return 'Cash on Delivery';
    }
  }

  String get paymentSubtitle {
    switch (paymentMethod) {
      case 'gcash':
        return 'Pay with GCash via Paymongo';
      case 'card':
        return 'Pay with your saved debit or credit card';
      default:
        return 'Pay when you receive your order';
    }
  }
}

class CustomerPreferencesNotifier extends Notifier<CustomerPreferencesState> {
  @override
  CustomerPreferencesState build() {
    return const CustomerPreferencesState(
      deliveryAddress: DeliveryAddress(
        primaryAddress: 'Magsaysay Ave, Naga City',
        streetAddress: '123 Magsaysay Avenue',
      ),
      paymentMethod: 'cod',
    );
  }

  void updateAddress({
    required String primaryAddress,
    String streetAddress = '',
    String notes = '',
  }) {
    state = state.copyWith(
      deliveryAddress: DeliveryAddress(
        primaryAddress: primaryAddress,
        streetAddress: streetAddress,
        notes: notes,
      ),
    );
  }

  void updatePaymentMethod(String method, {String? cardLabel}) {
    state = state.copyWith(
      paymentMethod: method,
      cardLabel: cardLabel,
    );
  }
}

final preferencesProvider =
    NotifierProvider<CustomerPreferencesNotifier, CustomerPreferencesState>(
        CustomerPreferencesNotifier.new);
