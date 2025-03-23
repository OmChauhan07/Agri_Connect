# Localization Implementation Guide

## Introduction

This guide provides a step-by-step approach to implement multi-language support across all screens in the FarmersMarketplace app. The localization system is already set up with support for English, Hindi, and Gujarati, and this guide will help you apply it consistently throughout the application.

## Prerequisites

Before starting, ensure that:
1. The localization system is set up with ARB files in `assets/translations/`
2. The LocalizationHelper utility is available in `lib/utils/localization_helper.dart`
3. The `l10n.yaml` configuration is properly set up

## Implementation Strategy

Follow these steps to implement localization across all screens:

### 1. Import the LocalizationHelper

Add the following import to each screen file:

```dart
import '../../utils/localization_helper.dart';
```

### 2. Access the Localization Helper in build method

Add this line at the beginning of your build method:

```dart
final loc = LocalizationHelper.of(context);
```

### 3. Replace Hardcoded Text

Find all instances of hardcoded text and replace them with localized strings. Here are the common patterns:

#### Replace direct Text widgets

**Before:**
```dart
const Text(
  'Featured Products',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
```

**After:**
```dart
Text(
  loc.productsFeatured,
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
```

#### Replace text in other widgets

**Before:**
```dart
BottomNavigationBarItem(
  icon: const Icon(Icons.home),
  label: 'Home',
),
```

**After:**
```dart
BottomNavigationBarItem(
  icon: const Icon(Icons.home),
  label: loc.navigationHome,
),
```

#### Replace text in AppBar titles

**Before:**
```dart
appBar: AppBar(
  title: const Text('Profile'),
),
```

**After:**
```dart
appBar: AppBar(
  title: Text(loc.navigationProfile),
),
```

### 4. Use the Extension Method for Simple Cases

For simple Text widgets, you can use the extension method:

**Before:**
```dart
const Text('Home')
```

**After:**
```dart
const Text('navigationHome').localize(context)
```

This is especially useful for widgets that are deeply nested.

### 5. Handle String Interpolation

For text that includes variables:

**Before:**
```dart
Text('Hello, ${user.name}')
```

**After:**
```dart
// Option 1: Separate the strings
Text('${loc.commonHello}, ${user.name}')

// Option 2: Use a parameterized key if supported
// This would require modification to the LocalizationHelper
Text(locHelper.getFormattedMessage('userGreeting', {'name': user.name}))
```

## Screen-by-Screen Implementation Process

Follow this process for each screen in the app:

1. **Initial Assessment**: Review the screen to identify all text elements that need localization
2. **Import and Setup**: Add the import and access to LocalizationHelper
3. **Convert Main Elements**: Start with major elements like AppBar titles, section headers
4. **Convert Secondary Elements**: Progress to buttons, labels, and other UI elements
5. **Test**: Switch languages to test that all elements are properly translated
6. **Fix Issues**: Address any missing or incorrectly translated strings

## Priority Screens for Implementation

Implement localization in the following order:

1. **Navigation and Common UI Components**:
   - Bottom navigation bar
   - Drawer menu (if present)
   - Main app header

2. **Authentication Screens**:
   - Login
   - Registration
   - Password reset

3. **Main User Journeys**:
   - Home/Marketplace screen
   - Product detail screen
   - Cart and checkout
   - Farmer profile screen

4. **Secondary Screens**:
   - Settings
   - Profile
   - Orders history
   - Donations

## Best Practices

1. **Keep Translations Consistent**: Use the same key for the same concept across the app
2. **Handle Plurals Carefully**: Consider text that changes with numbers
3. **Test with All Languages**: Test with all supported languages to ensure proper layout
4. **Long Strings**: Be aware that translations might be significantly longer in some languages
5. **RTL Support**: If adding right-to-left languages in the future, ensure your layouts handle RTL correctly

## Handling Missing Translations

If you encounter a string that needs translation but doesn't have a corresponding key:

1. Add the key to all ARB files with appropriate translations
2. Add the key to the LocalizationHelper's getTranslatedText method
3. Run `flutter gen-l10n` to regenerate the localization files

## Example Implementation

Here's a complete example for a Product Card widget:

```dart
class ProductCard extends StatelessWidget {
  final Product product;
  
  const ProductCard({Key? key, required this.product}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final loc = LocalizationHelper.of(context);
    
    return Card(
      child: Column(
        children: [
          Image.network(product.imageUrl),
          Text(product.name),
          Text('${loc.cartPrice}: ₹${product.price.toStringAsFixed(2)}'),
          ElevatedButton(
            onPressed: () {},
            child: Text(loc.productsAddToCart),
          ),
          if (product.isOrganic)
            Chip(label: Text(loc.productsOrganic)),
        ],
      ),
    );
  }
}
```

By following this guide, you'll be able to systematically implement localization across the entire app, ensuring a consistent and high-quality multilingual experience for your users. 