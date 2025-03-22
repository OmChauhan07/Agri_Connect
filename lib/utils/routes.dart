import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/consumer/product_detail_screen.dart';
import '../screens/consumer/order_confirmation_screen.dart';
import '../screens/consumer/consumer_orders_screen.dart';
import '../screens/consumer/consumer_home_screen.dart';
import '../screens/farmer/add_product_screen.dart';
import '../screens/farmer/farmer_dashboard_screen.dart';
import '../screens/settings/language_screen.dart';

class Routes {
  // Route names
  static const String login = '/login';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String addProduct = '/add-product';
  static const String farmerDashboard = '/farmer-dashboard';
  static const String orderConfirmation = '/order-confirmation';
  static const String myOrders = '/my-orders';
  static const String languageSettings = '/language-settings';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const ConsumerHomeScreen());

      case productDetail:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );

      case addProduct:
        return MaterialPageRoute(
          builder: (_) => const AddProductScreen(),
        );

      case farmerDashboard:
        return MaterialPageRoute(
          builder: (_) => const FarmerDashboardScreen(),
        );

      case orderConfirmation:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(orderId: orderId),
        );

      case myOrders:
        return MaterialPageRoute(
          builder: (_) => const ConsumerOrdersScreen(),
        );

      case languageSettings:
        return MaterialPageRoute(
          builder: (_) => const LanguageScreen(),
        );

      // Add other routes as needed

      default:
        // Return a 404 error page for unknown routes
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
