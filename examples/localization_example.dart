import 'package:flutter/material.dart';
import '../lib/utils/localization_helper.dart';

/// A reusable product card that demonstrates localization best practices
class LocalizedProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final String imageUrl;
  final bool isOrganic;
  final VoidCallback onAddToCart;

  const LocalizedProductCard({
    Key? key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.isOrganic = false,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the localization helper at the start of the build method
    final loc = LocalizationHelper.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Price with localized label
                Row(
                  children: [
                    Text(
                      '${loc.cartPrice}: ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '₹${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Organic badge if applicable
                if (isOrganic)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      loc.productsOrganic,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Add to cart button with localized text
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    child: Text(loc.productsAddToCart),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example usage:
///
/// ```dart
/// LocalizedProductCard(
///   productName: 'Organic Tomatoes',
///   price: 45.50,
///   imageUrl: 'https://example.com/tomato.jpg',
///   isOrganic: true,
///   onAddToCart: () {
///     // Handle add to cart
///   },
/// )
/// ```

/// This example demonstrates how to use the localization system in the app
class LocalizationExample extends StatelessWidget {
  const LocalizationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the localization helper instance for the current context
    final loc = LocalizationHelper.of(context);

    return Scaffold(
      // Use localized app name in the app bar
      appBar: AppBar(
        title: Text(loc.appName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              "Localization Examples",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Example card for basic text
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Basic Text Example",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    ListTile(
                      title: Text("Hello"),
                      subtitle: Text(loc.authWelcome),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Example card for buttons and actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Buttons and Actions",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(loc.commonSave),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: Text(loc.commonCancel),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(loc.commonConfirm),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Example card for form fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Form Fields",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    TextField(
                      decoration: InputDecoration(
                        labelText: loc.authEmail,
                        hintText: "example@email.com",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: loc.authPassword,
                        hintText: "••••••••",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Example card for error messages
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Error Messages",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    Text(
                      loc.commonError,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Network connection failed",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Example card for product information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Information",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(loc.productsTitle),
                      subtitle: Text(loc.productsDetails),
                      trailing: Text(
                        "₹100",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Price: ₹100"),
                          Text("${loc.cartTax}: ₹5"),
                          Text(
                            "${loc.cartTotal}: ₹105",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How to use this example:
///
/// 1. Import the localization helper in your file:
///    ```dart
///    import 'package:your_app/utils/localization_helper.dart';
///    ```
///
/// 2. In your build method, get the localization instance:
///    ```dart
///    final loc = LocalizationHelper.of(context);
///    ```
///
/// 3. Use the localized strings in your widgets:
///    ```dart
///    Text(loc.someKey)
///    ```
///
/// 4. To add new strings:
///    - Add them to assets/translations/app_en.arb (and other language files)
///    - Run 'flutter gen-l10n' to generate the updated AppLocalizations class
///    - Access them through the loc helper
