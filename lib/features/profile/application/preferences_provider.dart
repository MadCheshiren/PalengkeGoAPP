import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/services/preferences_provider.dart';
import 'package:palengkego/features/profile/domain/delivery_address.dart';

class CustomerPreferencesState {
  final DeliveryAddress deliveryAddress;
  final List<DeliveryAddress> savedAddresses;
  final String paymentMethod;
  final String? cardLabel;
  final List<String> blockedStallIds;

  const CustomerPreferencesState({
    required this.deliveryAddress,
    this.savedAddresses = const [],
    required this.paymentMethod,
    this.cardLabel,
    this.blockedStallIds = const [],
  });

  CustomerPreferencesState copyWith({
    DeliveryAddress? deliveryAddress,
    List<DeliveryAddress>? savedAddresses,
    String? paymentMethod,
    String? cardLabel,
    List<String>? blockedStallIds,
  }) {
    return CustomerPreferencesState(
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardLabel: cardLabel ?? this.cardLabel,
      blockedStallIds: blockedStallIds ?? this.blockedStallIds,
    );
  }

  String get paymentTitle {
    switch (paymentMethod) {
      case 'gcash':
        return 'GCash';
      case 'card':
        return cardLabel ?? 'Saved Card';
      case 'cop':
        return 'Cash on Pickup';
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

const _kDeliveryAddressKey = 'pref_delivery_address';
const _kSavedAddressesKey = 'pref_saved_addresses';
const _kPaymentMethodKey = 'pref_payment_method';

class CustomerPreferencesNotifier extends Notifier<CustomerPreferencesState> {
  @override
  CustomerPreferencesState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    // Load delivery address
    DeliveryAddress? currentAddress;
    final addressStr = prefs.getString(_kDeliveryAddressKey);
    if (addressStr != null) {
      try {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          const JsonDecoder().convert(addressStr) as Map,
        );
        currentAddress = DeliveryAddress.fromFirestore(data);
      } catch (_) {}
    }

    // Load saved addresses
    List<DeliveryAddress> savedAddresses = [];
    final savedListStr = prefs.getStringList(_kSavedAddressesKey);
    if (savedListStr != null) {
      for (final str in savedListStr) {
        try {
          final Map<String, dynamic> data = Map<String, dynamic>.from(
            const JsonDecoder().convert(str) as Map,
          );
          savedAddresses.add(DeliveryAddress.fromFirestore(data));
        } catch (_) {}
      }
    }

    // Load payment method
    final paymentMethod = prefs.getString(_kPaymentMethodKey) ?? 'cod';

    const defaultAddress = DeliveryAddress(
      label: 'Home',
      primaryAddress: 'Magsaysay Ave, Naga City',
      streetAddress: '123 Magsaysay Avenue',
    );

    currentAddress ??= defaultAddress;
    if (savedAddresses.isEmpty) {
      savedAddresses = [
        defaultAddress,
        const DeliveryAddress(
          label: 'School',
          primaryAddress: 'Ateneo de Naga University',
          streetAddress: 'Ateneo Avenue',
        ),
      ];
    }

    return CustomerPreferencesState(
      deliveryAddress: currentAddress,
      savedAddresses: savedAddresses,
      paymentMethod: paymentMethod,
      blockedStallIds: [],
    );
  }

  Future<void> _persistState(CustomerPreferencesState nextState) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      _kDeliveryAddressKey,
      const JsonEncoder().convert(nextState.deliveryAddress.toFirestore()),
    );
    final savedListStr = nextState.savedAddresses
        .map((a) => const JsonEncoder().convert(a.toFirestore()))
        .toList();
    await prefs.setStringList(_kSavedAddressesKey, savedListStr);
    await prefs.setString(_kPaymentMethodKey, nextState.paymentMethod);
  }

  void saveDeliveryAddress(DeliveryAddress address) {
    final updatedList =
        state.savedAddresses
            .where(
              (addr) =>
                  addr.label.toLowerCase().trim() !=
                  address.label.toLowerCase().trim(),
            )
            .toList()
          ..add(address);

    final next = state.copyWith(
      deliveryAddress: address,
      savedAddresses: updatedList,
    );
    state = next;
    _persistState(next);
  }

  void updateAddress({
    required String primaryAddress,
    String streetAddress = '',
    String notes = '',
    String label = 'Home',
    int? iconCodePoint,
  }) {
    final newAddress = DeliveryAddress(
      label: label,
      primaryAddress: primaryAddress,
      streetAddress: streetAddress,
      notes: notes,
      iconCodePoint: iconCodePoint,
    );
    saveDeliveryAddress(newAddress);
  }

  void selectAddress(DeliveryAddress address) {
    final next = state.copyWith(deliveryAddress: address);
    state = next;
    _persistState(next);
  }

  void updatePaymentMethod(String method, {String? cardLabel}) {
    final next = state.copyWith(paymentMethod: method, cardLabel: cardLabel);
    state = next;
    _persistState(next);
  }

  void blockStall(String stallNameOrId) {
    if (!state.blockedStallIds.contains(stallNameOrId)) {
      state = state.copyWith(
        blockedStallIds: [...state.blockedStallIds, stallNameOrId],
      );
    }
  }
}

final preferencesProvider =
    NotifierProvider<CustomerPreferencesNotifier, CustomerPreferencesState>(
      CustomerPreferencesNotifier.new,
    );
