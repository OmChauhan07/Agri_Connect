import 'package:flutter/material.dart';

class AppColors {
  // Primary color and variants
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFFC8E6C9);
  static const Color accent = Color(0xFFFF9800);
  
  // Badge colors
  static const Color orangeBadge = Color(0xFFFF9800);
  static const Color greenBadge = Color(0xFF4CAF50);
  
  // Common colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  
  // Order status colors
  static const Color pending = Color(0xFFFFC107);
  static const Color processing = Color(0xFF2196F3);
  static const Color shipped = Color(0xFF9C27B0);
  static const Color delivered = Color(0xFF4CAF50);
  static const Color cancelled = Color(0xFFF44336);
  
  // Rating colors
  static const Color ratingActive = Color(0xFFFFB74D);
  static const Color ratingInactive = Color(0xFFE0E0E0);
}

class AppStrings {
  // App Name
  static const String appName = "AgriConnect";
  
  // Authentication
  static const String welcome = "Welcome to AgriConnect";
  static const String login = "Login";
  static const String register = "Register";
  static const String forgotPassword = "Forgot Password?";
  static const String verifyPhone = "Verify Phone";
  static const String email = "Email";
  static const String password = "Password";
  static const String confirmPassword = "Confirm Password";
  static const String name = "Name";
  static const String phone = "Phone";
  static const String userType = "User Type";
  static const String farmer = "Farmer";
  static const String consumer = "Consumer";
  
  // Home
  static const String home = "Home";
  static const String products = "Products";
  static const String orders = "Orders";
  static const String profile = "Profile";
  static const String donate = "Donate";
  
  // Products
  static const String featuredProducts = "Featured Products";
  static const String allProducts = "All Products";
  static const String addProduct = "Add Product";
  static const String editProduct = "Edit Product";
  static const String productDetails = "Product Details";
  static const String organicCertified = "Organic Certified";
  static const String outOfStock = "Out of Stock";
  static const String addToCart = "Add to Cart";
  static const String buyNow = "Buy Now";
  
  // Orders
  static const String myOrders = "My Orders";
  static const String orderDetails = "Order Details";
  static const String orderID = "Order ID";
  static const String orderDate = "Order Date";
  static const String orderStatus = "Order Status";
  static const String deliveryAddress = "Delivery Address";
  static const String paymentMethod = "Payment Method";
  static const String totalAmount = "Total Amount";
  static const String trackOrder = "Track Order";
  static const String cancelOrder = "Cancel Order";
  
  // Farmer
  static const String farmProfile = "Farm Profile";
  static const String myProducts = "My Products";
  static const String addNewProduct = "Add New Product";
  static const String farmingPractices = "Farming Practices";
  static const String organicCertifications = "Organic Certifications";
  static const String farmingHistory = "Farming History";
  
  // Cart & Checkout
  static const String cart = "Cart";
  static const String checkout = "Checkout";
  static const String continueShopping = "Continue Shopping";
  static const String placeOrder = "Place Order";
  static const String subtotal = "Subtotal";
  static const String shippingFee = "Shipping Fee";
  static const String tax = "Tax";
  static const String total = "Total";
  
  // Donations
  static const String donations = "Donations";
  static const String supportFarmers = "Support Farmers";
  static const String donateToNGO = "Donate to NGO";
  static const String donationHistory = "Donation History";
  static const String donationAmount = "Donation Amount";
  static const String donationCertificate = "Donation Certificate";
  
  // Ratings & Reviews
  static const String ratings = "Ratings";
  static const String reviews = "Reviews";
  static const String writeReview = "Write a Review";
  static const String rateThisProduct = "Rate this Product";
  static const String rateThisFarmer = "Rate this Farmer";
  
  // Miscellaneous
  static const String loading = "Loading...";
  static const String error = "Error";
  static const String retry = "Retry";
  static const String noData = "No Data Found";
  static const String cancel = "Cancel";
  static const String save = "Save";
  static const String delete = "Delete";
  static const String edit = "Edit";
  static const String confirm = "Confirm";
  static const String success = "Success";
  static const String failure = "Failure";
  static const String warning = "Warning";
  static const String info = "Information";
}

class AppSizes {
  // Font Sizes
  static const double fontTiny = 10.0;
  static const double fontSmall = 12.0;
  static const double fontMedium = 14.0;
  static const double fontNormal = 16.0;
  static const double fontLarge = 18.0;
  static const double fontExtraLarge = 20.0;
  static const double fontHuge = 24.0;
  
  // Icon Sizes
  static const double iconTiny = 12.0;
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconExtraLarge = 48.0;
  
  // Spacing
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Button Sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyPhone = '/verify-phone';
  static const String consumerHome = '/consumer-home';
  static const String farmerHome = '/farmer-home';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderDetails = '/order-details';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String profile = '/profile';
  static const String farmProfile = '/farm-profile';
  static const String donations = '/donations';
  static const String donationHistory = '/donation-history';
  static const String farmerDetails = '/farmer-details';
}

// Order Status Enum
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled
}

// Rating Type Enum
enum RatingType {
  product,
  farmer
}

// Payment Method Enum
enum PaymentMethod {
  cashOnDelivery,
  upi,
  creditCard,
  debitCard,
  netBanking
}

// User Type Enum
enum UserType {
  farmer,
  consumer
}

// Product Category Enum
enum ProductCategory {
  vegetables,
  fruits,
  dairy,
  grains,
  spices,
  honey,
  other
}

// Farmer Badge Type Enum
enum FarmerBadgeType {
  none,
  orange,
  green
}

// Format extensions for enums
extension OrderStatusExtension on OrderStatus {
  String get name {
    return toString().split('.').last;
  }
  
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
  
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.pending;
      case OrderStatus.processing:
        return AppColors.processing;
      case OrderStatus.shipped:
        return AppColors.shipped;
      case OrderStatus.delivered:
        return AppColors.delivered;
      case OrderStatus.cancelled:
        return AppColors.cancelled;
    }
  }
}

extension RatingTypeExtension on RatingType {
  String get name {
    return toString().split('.').last;
  }
  
  String get displayName {
    switch (this) {
      case RatingType.product:
        return 'Product';
      case RatingType.farmer:
        return 'Farmer';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get name {
    return toString().split('.').last;
  }
  
  String get displayName {
    switch (this) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
    }
  }
}

extension UserTypeExtension on UserType {
  String get name {
    return toString().split('.').last;
  }
  
  String get displayName {
    switch (this) {
      case UserType.farmer:
        return 'Farmer';
      case UserType.consumer:
        return 'Consumer';
    }
  }
}

extension ProductCategoryExtension on ProductCategory {
  String get name {
    return toString().split('.').last;
  }
  
  String get displayName {
    switch (this) {
      case ProductCategory.vegetables:
        return 'Vegetables';
      case ProductCategory.fruits:
        return 'Fruits';
      case ProductCategory.dairy:
        return 'Dairy Products';
      case ProductCategory.grains:
        return 'Grains';
      case ProductCategory.spices:
        return 'Spices';
      case ProductCategory.honey:
        return 'Honey';
      case ProductCategory.other:
        return 'Other';
    }
  }
}

extension FarmerBadgeTypeExtension on FarmerBadgeType {
  String get name {
    return toString().split('.').last;
  }
  
  String get displayName {
    switch (this) {
      case FarmerBadgeType.none:
        return 'No Badge';
      case FarmerBadgeType.orange:
        return 'Orange Badge';
      case FarmerBadgeType.green:
        return 'Green Badge';
    }
  }
  
  Color get color {
    switch (this) {
      case FarmerBadgeType.none:
        return Colors.grey;
      case FarmerBadgeType.orange:
        return AppColors.orangeBadge;
      case FarmerBadgeType.green:
        return AppColors.greenBadge;
    }
  }
}