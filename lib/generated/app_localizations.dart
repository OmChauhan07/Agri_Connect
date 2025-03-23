import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AgriConnect'**
  String get appName;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get commonNoData;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonFailure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get commonFailure;

  /// No description provided for @commonWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get commonWarning;

  /// No description provided for @commonInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get commonInfo;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AgriConnect'**
  String get authWelcome;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone'**
  String get authVerifyPhone;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get authPhone;

  /// No description provided for @authUserType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get authUserType;

  /// No description provided for @authFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get authFarmer;

  /// No description provided for @authConsumer.
  ///
  /// In en, this message translates to:
  /// **'Consumer'**
  String get authConsumer;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navigationProducts;

  /// No description provided for @navigationOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navigationOrders;

  /// No description provided for @navigationProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// No description provided for @navigationDonate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get navigationDonate;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsTitle;

  /// No description provided for @productsFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get productsFeatured;

  /// No description provided for @productsAll.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get productsAll;

  /// No description provided for @productsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get productsAdd;

  /// No description provided for @productsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get productsEdit;

  /// No description provided for @productsDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productsDetails;

  /// No description provided for @productsOrganic.
  ///
  /// In en, this message translates to:
  /// **'Organic Certified'**
  String get productsOrganic;

  /// No description provided for @productsOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get productsOutOfStock;

  /// No description provided for @productsAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get productsAddToCart;

  /// No description provided for @productsBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get productsBuyNow;

  /// No description provided for @productsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available Products'**
  String get productsAvailable;

  /// No description provided for @productsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get productsSearch;

  /// No description provided for @productsNoFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get productsNoFound;

  /// No description provided for @productsFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter Products'**
  String get productsFilter;

  /// No description provided for @productsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productsCategory;

  /// No description provided for @productsGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get productsGridView;

  /// No description provided for @productsListView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get productsListView;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersMyOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersMyOrders;

  /// No description provided for @ordersDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get ordersDetails;

  /// No description provided for @ordersID.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get ordersID;

  /// No description provided for @ordersDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get ordersDate;

  /// No description provided for @ordersStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get ordersStatus;

  /// No description provided for @ordersDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get ordersDeliveryAddress;

  /// No description provided for @ordersPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get ordersPaymentMethod;

  /// No description provided for @ordersTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get ordersTotalAmount;

  /// No description provided for @ordersTrack.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get ordersTrack;

  /// No description provided for @ordersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get ordersCancel;

  /// No description provided for @ordersPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ordersPending;

  /// No description provided for @ordersProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get ordersProcessing;

  /// No description provided for @ordersShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get ordersShipped;

  /// No description provided for @ordersDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get ordersDelivered;

  /// No description provided for @ordersCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersCancelled;

  /// No description provided for @ordersRate.
  ///
  /// In en, this message translates to:
  /// **'Rate this Order'**
  String get ordersRate;

  /// No description provided for @ordersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersActive;

  /// No description provided for @ordersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersCompleted;

  /// No description provided for @farmerProfile.
  ///
  /// In en, this message translates to:
  /// **'Farm Profile'**
  String get farmerProfile;

  /// No description provided for @farmerProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get farmerProducts;

  /// No description provided for @farmerAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get farmerAddProduct;

  /// No description provided for @farmerPractices.
  ///
  /// In en, this message translates to:
  /// **'Farming Practices'**
  String get farmerPractices;

  /// No description provided for @farmerCertifications.
  ///
  /// In en, this message translates to:
  /// **'Organic Certifications'**
  String get farmerCertifications;

  /// No description provided for @farmerHistory.
  ///
  /// In en, this message translates to:
  /// **'Farming History'**
  String get farmerHistory;

  /// No description provided for @farmerTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated Farmers'**
  String get farmerTopRated;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @cartCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cartCheckout;

  /// No description provided for @cartContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Shopping'**
  String get cartContinue;

  /// No description provided for @cartPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get cartPlaceOrder;

  /// No description provided for @cartSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cartSubtotal;

  /// No description provided for @cartShipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping Fee'**
  String get cartShipping;

  /// No description provided for @cartTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get cartTax;

  /// No description provided for @cartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cartTotal;

  /// No description provided for @cartPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get cartPrice;

  /// No description provided for @donationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get donationsTitle;

  /// No description provided for @donationsSupportFarmers.
  ///
  /// In en, this message translates to:
  /// **'Support Farmers'**
  String get donationsSupportFarmers;

  /// No description provided for @donationsToNGO.
  ///
  /// In en, this message translates to:
  /// **'Donate to NGO'**
  String get donationsToNGO;

  /// No description provided for @donationsHistory.
  ///
  /// In en, this message translates to:
  /// **'Donation History'**
  String get donationsHistory;

  /// No description provided for @donationsAmount.
  ///
  /// In en, this message translates to:
  /// **'Donation Amount'**
  String get donationsAmount;

  /// No description provided for @donationsCertificate.
  ///
  /// In en, this message translates to:
  /// **'Donation Certificate'**
  String get donationsCertificate;

  /// No description provided for @ratingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratingsTitle;

  /// No description provided for @ratingsReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get ratingsReviews;

  /// No description provided for @ratingsWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get ratingsWrite;

  /// No description provided for @ratingsProduct.
  ///
  /// In en, this message translates to:
  /// **'Rate this Product'**
  String get ratingsProduct;

  /// No description provided for @ratingsFarmer.
  ///
  /// In en, this message translates to:
  /// **'Rate this Farmer'**
  String get ratingsFarmer;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get settingsHindi;

  /// No description provided for @settingsGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get settingsGujarati;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get languageSelect;

  /// No description provided for @languageNote.
  ///
  /// In en, this message translates to:
  /// **'The app will use the selected language for all text content.'**
  String get languageNote;

  /// No description provided for @donationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing your donation.'**
  String get donationError;

  /// No description provided for @localizationExamples.
  ///
  /// In en, this message translates to:
  /// **'Localization Examples'**
  String get localizationExamples;

  /// No description provided for @basicTextExample.
  ///
  /// In en, this message translates to:
  /// **'Basic Text Example'**
  String get basicTextExample;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @buttonsAndActions.
  ///
  /// In en, this message translates to:
  /// **'Buttons and Actions'**
  String get buttonsAndActions;

  /// No description provided for @formFields.
  ///
  /// In en, this message translates to:
  /// **'Form Fields'**
  String get formFields;

  /// No description provided for @errorMessages.
  ///
  /// In en, this message translates to:
  /// **'Error Messages'**
  String get errorMessages;

  /// No description provided for @productInfo.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get productInfo;

  /// No description provided for @categoriesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoriesAll;

  /// No description provided for @categoriesVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoriesVegetables;

  /// No description provided for @categoriesFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get categoriesFruits;

  /// No description provided for @categoriesGrains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get categoriesGrains;

  /// No description provided for @categoriesDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoriesDairy;

  /// No description provided for @categoriesMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get categoriesMeat;

  /// No description provided for @categoriesHerbs.
  ///
  /// In en, this message translates to:
  /// **'Herbs'**
  String get categoriesHerbs;

  /// No description provided for @categoriesOrganic.
  ///
  /// In en, this message translates to:
  /// **'Organic'**
  String get categoriesOrganic;

  /// No description provided for @categoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get categoriesAvailable;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'gu': return AppLocalizationsGu();
    case 'hi': return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
