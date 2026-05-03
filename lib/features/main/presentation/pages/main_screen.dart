import 'package:flutter/material.dart';
import 'package:palengkego/core/services/cart_service.dart';
import 'package:palengkego/core/utils/page_transitions.dart';
import 'package:palengkego/core/widgets/app_bottom_nav_bar.dart';
import 'package:palengkego/features/cart/presentation/pages/shopping_cart_screen.dart';
import 'package:palengkego/features/home/presentation/pages/market_screen.dart';
import 'package:palengkego/features/orders/presentation/pages/order_history_screen.dart';
import 'package:palengkego/features/recipes/presentation/pages/recipes_screen.dart';

/// Shared tab state so pushed detail pages can switch tabs and return cleanly.
/// Tabs: 0=Market, 1=Orders, 2=Recipes (Home merged into Market)
final mainTabNotifier = ValueNotifier<int>(0);

/// Shared cart badge notifier used by the main shell and sub-pages.
final cartCountNotifier = ValueNotifier<int>(0);

void updateCartBadgeCount(int count) {
  cartCountNotifier.value = count;
}

void navigateToMainTab(BuildContext context, int index) {
  // Cart is no longer a tab - push cart screen as standalone route
  if (index == 4) {
    Navigator.of(context).push(
      PageTransitions.slideFromRight(const ShoppingCartScreen()),
    );
    return;
  }

  // Clamp to valid tab range (0-2)
  mainTabNotifier.value = index.clamp(0, 2);

  if (Navigator.of(context).canPop()) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
    (route) => false,
  );
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = const [
    MarketScreen(),
    OrderHistoryScreen(),
    RecipesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Clamp index to valid range after removing cart from tabs
    final clampedIndex = widget.initialIndex.clamp(0, _pages.length - 1);
    mainTabNotifier.value = clampedIndex;
    cartCountNotifier.value = globalCart.itemCount;
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      // Cart button pushes the cart screen as a standalone route
      Navigator.of(context).push(
        PageTransitions.slideFromRight(const ShoppingCartScreen()),
      );
      return;
    }
    mainTabNotifier.value = index.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: mainTabNotifier,
      builder: (context, selectedIndex, _) {
        // Clamp to valid range — mainTabNotifier may retain stale value (e.g. 4)
        // from before cart was removed from tabs, especially on hot reload
        // Clamp to valid range (0-2: Market, Orders, Recipes)
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
