import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

/// Helper class to easily access localized strings throughout the app
class LocalizationHelper {
  /// Private constructor to prevent instantiation
  LocalizationHelper._();

  /// Get localized strings from the current context
  static AppLocalizations of(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      throw Exception(
          'AppLocalizations not found. Make sure to set up localization correctly.');
    }
    return localizations;
  }

  /// Extension to easily access translations from Text widgets
  static String getTranslatedText(BuildContext context, String key) {
    final localizations = of(context);

    // Map the key to the appropriate getter in AppLocalizations
    switch (key) {
      // Common
      case 'appName':
        return localizations.appName;
      case 'commonCancel':
        return localizations.commonCancel;
      case 'commonConfirm':
        return localizations.commonConfirm;
      case 'commonSave':
        return localizations.commonSave;
      case 'commonDelete':
        return localizations.commonDelete;
      case 'commonEdit':
        return localizations.commonEdit;
      case 'commonLoading':
        return localizations.commonLoading;
      case 'commonError':
        return localizations.commonError;
      case 'commonRetry':
        return localizations.commonRetry;
      case 'commonNoData':
        return localizations.commonNoData;
      case 'commonSuccess':
        return localizations.commonSuccess;
      case 'commonFailure':
        return localizations.commonFailure;
      case 'commonWarning':
        return localizations.commonWarning;
      case 'commonInfo':
        return localizations.commonInfo;

      // Auth
      case 'authWelcome':
        return localizations.authWelcome;
      case 'authLogin':
        return localizations.authLogin;
      case 'authRegister':
        return localizations.authRegister;
      case 'authForgotPassword':
        return localizations.authForgotPassword;
      case 'authVerifyPhone':
        return localizations.authVerifyPhone;
      case 'authEmail':
        return localizations.authEmail;
      case 'authPassword':
        return localizations.authPassword;
      case 'authConfirmPassword':
        return localizations.authConfirmPassword;
      case 'authName':
        return localizations.authName;
      case 'authPhone':
        return localizations.authPhone;
      case 'authUserType':
        return localizations.authUserType;
      case 'authFarmer':
        return localizations.authFarmer;
      case 'authConsumer':
        return localizations.authConsumer;

      // Navigation
      case 'navigationHome':
        return localizations.navigationHome;
      case 'navigationProducts':
        return localizations.navigationProducts;
      case 'navigationOrders':
        return localizations.navigationOrders;
      case 'navigationProfile':
        return localizations.navigationProfile;
      case 'navigationDonate':
        return localizations.navigationDonate;

      // Products
      case 'productsTitle':
        return localizations.productsTitle;
      case 'productsFeatured':
        return localizations.productsFeatured;
      case 'productsAll':
        return localizations.productsAll;
      case 'productsAdd':
        return localizations.productsAdd;
      case 'productsEdit':
        return localizations.productsEdit;
      case 'productsDetails':
        return localizations.productsDetails;
      case 'productsOrganic':
        return localizations.productsOrganic;
      case 'productsOutOfStock':
        return localizations.productsOutOfStock;
      case 'productsAddToCart':
        return localizations.productsAddToCart;
      case 'productsBuyNow':
        return localizations.productsBuyNow;

      // Orders
      case 'ordersTitle':
        return localizations.ordersTitle;
      case 'ordersMyOrders':
        return localizations.ordersMyOrders;
      case 'ordersDetails':
        return localizations.ordersDetails;
      case 'ordersID':
        return localizations.ordersID;
      case 'ordersDate':
        return localizations.ordersDate;
      case 'ordersStatus':
        return localizations.ordersStatus;
      case 'ordersDeliveryAddress':
        return localizations.ordersDeliveryAddress;
      case 'ordersPaymentMethod':
        return localizations.ordersPaymentMethod;
      case 'ordersTotalAmount':
        return localizations.ordersTotalAmount;
      case 'ordersTrack':
        return localizations.ordersTrack;
      case 'ordersCancel':
        return localizations.ordersCancel;
      case 'ordersPending':
        return localizations.ordersPending;
      case 'ordersProcessing':
        return localizations.ordersProcessing;
      case 'ordersShipped':
        return localizations.ordersShipped;
      case 'ordersDelivered':
        return localizations.ordersDelivered;
      case 'ordersCancelled':
        return localizations.ordersCancelled;
      case 'ordersRate':
        return localizations.ordersRate;
      case 'ordersActive':
        return localizations.ordersActive;
      case 'ordersCompleted':
        return localizations.ordersCompleted;

      // Farmer
      case 'farmerProfile':
        return localizations.farmerProfile;
      case 'farmerProducts':
        return localizations.farmerProducts;
      case 'farmerAddProduct':
        return localizations.farmerAddProduct;
      case 'farmerPractices':
        return localizations.farmerPractices;
      case 'farmerCertifications':
        return localizations.farmerCertifications;
      case 'farmerHistory':
        return localizations.farmerHistory;

      // Cart
      case 'cartTitle':
        return localizations.cartTitle;
      case 'cartCheckout':
        return localizations.cartCheckout;
      case 'cartContinue':
        return localizations.cartContinue;
      case 'cartPlaceOrder':
        return localizations.cartPlaceOrder;
      case 'cartSubtotal':
        return localizations.cartSubtotal;
      case 'cartShipping':
        return localizations.cartShipping;
      case 'cartTax':
        return localizations.cartTax;
      case 'cartTotal':
        return localizations.cartTotal;

      // Donations
      case 'donationsTitle':
        return localizations.donationsTitle;
      case 'donationsSupportFarmers':
        return localizations.donationsSupportFarmers;
      case 'donationsToNGO':
        return localizations.donationsToNGO;
      case 'donationsHistory':
        return localizations.donationsHistory;
      case 'donationsAmount':
        return localizations.donationsAmount;
      case 'donationsCertificate':
        return localizations.donationsCertificate;

      // Ratings
      case 'ratingsTitle':
        return localizations.ratingsTitle;
      case 'ratingsReviews':
        return localizations.ratingsReviews;
      case 'ratingsWrite':
        return localizations.ratingsWrite;
      case 'ratingsProduct':
        return localizations.ratingsProduct;
      case 'ratingsFarmer':
        return localizations.ratingsFarmer;

      // Settings
      case 'settingsTitle':
        return localizations.settingsTitle;
      case 'settingsLanguage':
        return localizations.settingsLanguage;
      case 'settingsEnglish':
        return localizations.settingsEnglish;
      case 'settingsHindi':
        return localizations.settingsHindi;
      case 'settingsGujarati':
        return localizations.settingsGujarati;
      case 'settingsDarkMode':
        return localizations.settingsDarkMode;
      case 'settingsNotifications':
        return localizations.settingsNotifications;
      case 'settingsAbout':
        return localizations.settingsAbout;
      case 'settingsHelp':
        return localizations.settingsHelp;
      case 'settingsLogout':
        return localizations.settingsLogout;

      // Language
      case 'languageSettings':
        return localizations.languageSettings;
      case 'languageSelect':
        return localizations.languageSelect;
      case 'languageNote':
        return localizations.languageNote;

      default:
        return key; // Return the key itself if not found
    }
  }
}

// Extension on Text widgets
extension LocalizedText on Text {
  Text localize(BuildContext context) {
    // Skip if data is not a String
    if (data == null || data is! String) return this;

    // Return a new Text widget with the translated string
    return Text(
      LocalizationHelper.getTranslatedText(context, data!),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}
