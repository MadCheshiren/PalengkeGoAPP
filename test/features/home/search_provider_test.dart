import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/features/home/application/search_provider.dart';

void main() {
  group('SearchQueryNotifier', () {
    test('starts with an empty query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchQueryProvider), isEmpty);
    });

    test('update() sets the query string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).update('bangus');
      expect(container.read(searchQueryProvider), 'bangus');
    });

    test('clear() resets the query to empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(searchQueryProvider.notifier);
      notifier.update('tilapia');
      expect(container.read(searchQueryProvider), isNotEmpty);

      notifier.clear();
      expect(container.read(searchQueryProvider), isEmpty);
    });
  });

  group('filteredVendorsProvider', () {
    test('returns all vendors in category when query is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final all = container.read(filteredVendorsProvider('All'));
      expect(all, isNotEmpty);
    });

    test('filters vendors by name (case-insensitive)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Seed a query that matches a known vendor name fragment in mock data
      container.read(searchQueryProvider.notifier).update('diosa');

      final results = container.read(filteredVendorsProvider('All'));
      // All results should contain 'diosa' in name or category
      for (final v in results) {
        expect(
          v.name.toLowerCase().contains('diosa') ||
              v.category.toLowerCase().contains('diosa'),
          isTrue,
        );
      }
    });

    test('filters vendors by category chip + query simultaneously', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Query that should match nothing in the Fish category
      container
          .read(searchQueryProvider.notifier)
          .update('zzznomatch_xyz');

      final results = container.read(filteredVendorsProvider('Fish'));
      expect(results, isEmpty);
    });

    test('returns empty list when no vendors match query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(searchQueryProvider.notifier)
          .update('qqqqq_no_vendor_ever');

      final results = container.read(filteredVendorsProvider('All'));
      expect(results, isEmpty);
    });

    test('results update when query changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(searchQueryProvider.notifier);

      // Initially all vendors
      final allCount = container.read(filteredVendorsProvider('All')).length;

      // Apply a non-matching query
      notifier.update('zzznomatch');
      expect(container.read(filteredVendorsProvider('All')), isEmpty);

      // Clear query — should restore all
      notifier.clear();
      expect(
        container.read(filteredVendorsProvider('All')).length,
        allCount,
      );
    });
  });
}
