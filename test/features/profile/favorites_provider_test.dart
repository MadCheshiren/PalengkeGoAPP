import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/profile/application/favorites_provider.dart';

void main() {
  group('FavoritesNotifier', () {
    test('starts with an empty set of favorites', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(favoritesProvider), isEmpty);
    });

    test('toggle adds a vendor id when not yet favorited', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(favoritesProvider.notifier).toggle('v1');
      expect(container.read(favoritesProvider), contains('v1'));
    });

    test('toggle removes a vendor id that is already favorited', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('v1');
      expect(container.read(favoritesProvider), contains('v1'));

      notifier.toggle('v1');
      expect(container.read(favoritesProvider), isNot(contains('v1')));
    });

    test('isFavorite returns correct boolean', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      expect(notifier.isFavorite('v2'), isFalse);

      notifier.toggle('v2');
      expect(notifier.isFavorite('v2'), isTrue);
    });

    test('multiple vendors can be favorited independently', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('v1');
      notifier.toggle('v3');
      notifier.toggle('v5');

      final state = container.read(favoritesProvider);
      expect(state, containsAll(['v1', 'v3', 'v5']));
      expect(state, hasLength(3));
    });

    test('toggling one vendor does not affect others', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('v1');
      notifier.toggle('v2');

      // Remove v1
      notifier.toggle('v1');

      final state = container.read(favoritesProvider);
      expect(state, isNot(contains('v1')));
      expect(state, contains('v2'));
    });
  });

  group('favoriteVendorsProvider', () {
    test('returns empty list when no favorites selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vendors = container.read(favoriteVendorsProvider);
      expect(vendors, isEmpty);
    });

    test('returns vendor objects for favorited ids', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // v1 and v2 are seeded in MockMarketRepository
      container.read(favoritesProvider.notifier).toggle('v1');
      container.read(favoritesProvider.notifier).toggle('v2');

      final vendors = container.read(favoriteVendorsProvider);
      expect(vendors.length, 2);
      expect(vendors.map((v) => v.id), containsAll(['v1', 'v2']));
    });

    test('vendor list updates when a favorite is removed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(favoritesProvider.notifier);
      notifier.toggle('v1');
      notifier.toggle('v2');

      expect(container.read(favoriteVendorsProvider).length, 2);

      notifier.toggle('v1'); // remove

      expect(container.read(favoriteVendorsProvider).length, 1);
      expect(container.read(favoriteVendorsProvider).first.id, 'v2');
    });
  });
}
