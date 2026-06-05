import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/market/data/market_repository.dart';
import 'package:palengkego/features/market/data/mock_market_repository.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MockMarketRepository();
});
