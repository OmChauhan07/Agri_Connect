import 'package:flutter/material.dart';
import '../models/order.dart';

// App information
class AppInfo {
  static const String appName = 'AgriConnect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Connecting organic farmers with consumers';
}

// App Routes
class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String farmerHome = '/farmer-home';
  static const String consumerHome = '/home';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String productDetail = '/product-detail';
  static const String farmerDetail = '/farmer-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String searchResults = '/search-results';
  static const String farmers = '/farmers';
  static const String products = '/products';
  static const String categoryProducts = '/category-products';
}

// Error Messages
class ErrorMessages {
  static const String generalError = 'Something went wrong. Please try again later.';
  static const String authError = 'Authentication failed. Please check your credentials.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String inputError = 'Please check your input and try again.';
  static const String emptyFieldError = 'This field cannot be empty';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String passwordLengthError = 'Password must be at least 6 characters';
  static const String serverError = 'Server error. Please try again later.';
  static const String notFoundError = 'The requested resource was not found';
}

// Date Formats
class DateFormats {
  static const String fullDate = 'MMMM dd, yyyy';
  static const String shortDate = 'MMM dd, yyyy';
  static const String dayMonth = 'dd MMM';
  static const String dateTime = 'MMM dd, yyyy - HH:mm';
}

// Product Categories
class ProductCategories {
  static const List<String> categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Grains',
    'Meat',
    'Others',
  ];
}

// Order Status Messages
class OrderStatusMessages {
  static String getMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order has been placed and is awaiting confirmation.';
      case OrderStatus.processing:
        return 'Your order has been confirmed and is being processed.';
      case OrderStatus.shipped:
        return 'Your order has been shipped and is on its way.';
      case OrderStatus.delivered:
        return 'Your order has been delivered successfully.';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled.';
      default:
        return 'Unknown status';
    }
  }
}

// Badge Types
class BadgeTypes {
  static const String orange = 'orange';
  static const String green = 'green';
}

// Supabase Tables
class SupabaseTables {
  static const String users = 'users';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String ratings = 'ratings';
}

// Supabase Storage Buckets
class SupabaseStorage {
  static const String usersBucket = 'users';
  static const String productsBucket = 'products';
}
