import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palengkego/core/navigation/app_router.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/core/widgets/app_bottom_nav_bar.dart';
import 'package:palengkego/features/cart/application/cart_provider.dart';
import 'package:palengkego/features/home/presentation/pages/home_screen.dart';
import 'package:palengkego/features/home/presentation/pages/market_screen.dart';
import 'package:palengkego/features/orders/presentation/pages/order_history_screen.dart';
import 'package:palengkego/features/recipes/presentation/pages/recipes_screen.dart';

/// Shared tab state so pushed detail pages can switch tabs and return cleanly.
/// Tabs: 0=Home, 1=Market, 2=Orders, 3=Recipes
final mainTabNotifier = ValueNotifier<int>(0);

/// Shared cart badge notifier used by the main shell and sub-pages.
final cartCountNotifier = ValueNotifier<int>(0);

void updateCartBadgeCount(int count) {
  cartCountNotifier.value = count;
}

void navigateToMainTab(BuildContext context, int index) {
  // Cart is no longer a tab - push cart screen as standalone route
  if (index == 4) {
    Navigator.of(context).pushNamed(AppRoutes.cart);
    return;
  }

  // Clamp to valid tab range (0-3)
  mainTabNotifier.value = index.clamp(0, 3);

  if (Navigator.of(context).canPop()) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }

  Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.main,
    (route) => false,
    arguments: MainRouteArgs(initialIndex: index),
  );
}

class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final List<Widget> _pages = [
    HomeScreen(onMarketSelected: () => mainTabNotifier.value = 1),
    const MarketScreen(),
    const OrderHistoryScreen(),
    const RecipesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Clamp index to valid range after removing cart from tabs
    final clampedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
    mainTabNotifier.value = clampedIndex;
    cartCountNotifier.value = ref.read(cartServiceProvider).itemCount;
  }

  void _onItemTapped(int index) {
      if (index == 4) {
        // Cart button pushes the cart screen as a standalone route
        Navigator.of(context).pushNamed(AppRoutes.cart);
        return;
      }
    mainTabNotifier.value = index.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: mainTabNotifier,
      builder: (context, selectedIndex, _) {
        // Clamp to valid range — mainTabNotifier may retain stale value (e.g. 4)
        // from before cart was removed from tabs, especially on hot reload
        // Clamp to valid range (0-3: Home, Market, Orders, Recipes)
        final safeIndex = selectedIndex.clamp(0, _pages.length - 1);
        return Scaffold(
          body: IndexedStack(index: safeIndex, children: _pages),
          bottomNavigationBar: ValueListenableBuilder<int>(
            valueListenable: cartCountNotifier,
            builder: (context, cartCount, _) {
              return AppBottomNavBar(
                selectedIndex: safeIndex,
                onTap: _onItemTapped,
                cartBadgeCount: cartCount > 0 ? cartCount : null,
                isCartAction: true,
              );
            },
          ),
        );
      },
    );
  }
}
