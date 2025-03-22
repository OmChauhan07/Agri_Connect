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
