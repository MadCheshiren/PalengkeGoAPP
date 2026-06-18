import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/models/mock_models.dart';

final promosProvider = Provider<List<Promo>>((ref) {
  return [
    Promo(
      id: 'promo_1',
      title: 'Fresh from Naga\nCity Market',
      discountPercentage: 20,
      validUntil: DateTime.now().add(const Duration(days: 1)),
      eligibleProductIds: ['prod_1', 'prod_2'],
    ),
    Promo(
      id: 'promo_2',
      title: 'Seafood Weekend Special',
      discountPercentage: 15,
      validUntil: DateTime.now().add(const Duration(days: 3)),
      eligibleProductIds: ['prod_3', 'prod_4'],
    ),
  ];
});
