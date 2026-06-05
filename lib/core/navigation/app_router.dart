import 'package:flutter/material.dart';
import 'package:palengkego/core/navigation/app_routes.dart';
import 'package:palengkego/features/auth/presentation/pages/login_screen.dart';
import 'package:palengkego/features/auth/presentation/pages/registration_screen.dart';
import 'package:palengkego/features/cart/presentation/pages/shopping_cart_screen.dart';
import 'package:palengkego/features/checkout/presentation/pages/add_credit_card_screen.dart';
import 'package:palengkego/features/checkout/presentation/pages/checkout_screen.dart';
import 'package:palengkego/features/checkout/presentation/pages/order_confirmation_screen.dart';
import 'package:palengkego/features/checkout/presentation/pages/payment_methods_screen.dart';
import 'package:palengkego/features/main/presentation/pages/main_screen.dart';
import 'package:palengkego/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:palengkego/features/onboarding/presentation/pages/splash_screen.dart';
import 'package:palengkego/features/orders/domain/market_order.dart';
import 'package:palengkego/features/orders/presentation/pages/track_order_screen.dart';
import 'package:palengkego/features/profile/presentation/pages/set_delivery_address_screen.dart';
import 'package:palengkego/features/recipes/presentation/pages/cookbook_screen.dart';

class MainRouteArgs {
  const MainRouteArgs({this.initialIndex = 0});

  final int initialIndex;
}

class PaymentMethodsRouteArgs {
  const PaymentMethodsRouteArgs({this.currentMethod = 'cod'});

  final String currentMethod;
}

class OrderConfirmationRouteArgs {
  const OrderConfirmationRouteArgs({
    required this.isPickup,
    required this.orders,
    this.address,
  });

  final bool isPickup;
  final List<MarketOrder> orders;
  final String? address;
}

class TrackOrderRouteArgs {
  const TrackOrderRouteArgs({
    required this.order,
    required this.isPickup,
  });

  final MarketOrder order;
  final bool isPickup;
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _materialRoute(settings, const SplashScreen());
      case AppRoutes.onboarding:
        return _materialRoute(settings, const OnboardingScreen());
      case AppRoutes.login:
        return _materialRoute(settings, const LoginScreen());
      case AppRoutes.registration:
        return _materialRoute(settings, const RegistrationScreen());
      case AppRoutes.main:
        final args = settings.arguments;
        final initialIndex = args is MainRouteArgs ? args.initialIndex : 0;
        return _materialRoute(
          settings,
          MainScreen(initialIndex: initialIndex),
        );
      case AppRoutes.cart:
        return _slideRoute(settings, const ShoppingCartScreen());
      case AppRoutes.checkout:
        return _slideRoute(settings, const CheckoutScreen());
      case AppRoutes.paymentMethods:
        final args = settings.arguments;
        final currentMethod =
            args is PaymentMethodsRouteArgs ? args.currentMethod : 'cod';
        return _materialRoute(
          settings,
          PaymentMethodsScreen(currentMethod: currentMethod),
        );
      case AppRoutes.addCreditCard:
        return _materialRoute(settings, const AddCreditCardScreen());
      case AppRoutes.orderConfirmation:
        final args = settings.arguments;
        if (args is! OrderConfirmationRouteArgs) {
          return _errorRoute(settings);
        }
        return _scaleFadeRoute(
          settings,
          OrderConfirmationScreen(
            isPickup: args.isPickup,
            orders: args.orders,
            address: args.address,
          ),
        );
      case AppRoutes.trackOrder:
        final args = settings.arguments;
        if (args is! TrackOrderRouteArgs) {
          return _errorRoute(settings);
        }
        return _materialRoute(
          settings,
          TrackOrderScreen(order: args.order, isPickup: args.isPickup),
        );
      case AppRoutes.setDeliveryAddress:
        return _materialRoute(settings, const SetDeliveryAddressScreen());
      case AppRoutes.cookbook:
        return _slideRoute(settings, const CookbookScreen());
      default:
        return _errorRoute(settings);
    }
  }

  static MaterialPageRoute<dynamic> _materialRoute(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => child,
    );
  }

  static PageRouteBuilder<dynamic> _slideRoute(
    RouteSettings settings,
    Widget child,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => child,
      transitionsBuilder: (_, animation, _, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
    );
  }

  static PageRouteBuilder<dynamic> _scaleFadeRoute(
    RouteSettings settings,
    Widget child,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => child,
      transitionsBuilder: (_, animation, _, child) {
        final scaleTween = Tween(begin: 0.95, end: 1.0).chain(
          CurveTween(curve: Curves.easeOutCubic),
        );
        final fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
    );
  }

  static MaterialPageRoute<dynamic> _errorRoute(RouteSettings settings) {
    return _materialRoute(
      settings,
      const Scaffold(
        body: Center(child: Text('Route not found')),
      ),
    );
  }
}
