import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../models/product.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/rating_bar.dart';
import '../../widgets/badge_icon.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  Product? _product;
  UserModel? _farmer;
  int _quantity = 1;
  int _currentImageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }
  
  Future<void> _loadProductDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      // Fetch product details
      final product = await productProvider.getProductById(widget.productId);
      setState(() {
        _product = product;
      });
      
      // Fetch farmer details
      if (product != null) {
        final farmer = await productProvider.getFarmerById(product.farmerId);
        setState(() {
          _farmer = farmer;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading product details: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _incrementQuantity() {
    if (_product != null && _quantity < _product!.stockQuantity) {
      setState(() {
        _quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum available quantity reached')),
      );
    }
  }
  
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }
  
  void _proceedToCheckout() {
    if (_product == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          products: [_product!],
          quantities: [_quantity],
          totalAmount: _product!.price * _quantity,
          farmerId: _product!.farmerId,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('Product Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }
    
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('Product Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Product not found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Product Details Content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: AppColors.primaryColor,
                expandedHeight: 300,
                floating: false,
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  // Share Button
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.black),
                      onPressed: () {
                        // TODO: Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share feature coming soon')),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _product.imageUrls.isNotEmpty
                      ? Stack(
                          children: [
                            // Image Carousel
                            CarouselSlider(
                              items: _product.imageUrls.map((url) {
                                return Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              }).toList(),
                              options: CarouselOptions(
                                height: 300,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                autoPlay: _product.imageUrls.length > 1,
                              ),
                            ),
                            
                            // Image Indicators
                            if (_product.imageUrls.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _product.imageUrls.asMap().entries.map((entry) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == entry.key
                                            ? AppColors.primaryColor
                                            : Colors.white.withOpacity(0.5),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            
                            // Organic Badge
                            if (_product.isOrganic)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.eco, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Organic',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
              
              // Product Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Expanded(
                            child: Text(
                              _product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Product Price
                          Text(
                            '\$${_product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Rating
                      Row(
                        children: [
                          RatingBarDisplay(
                            rating: _product.rating ?? 0,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_product.totalRatings ?? 0} ratings)',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Availability Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _product.isAvailable && _product.stockQuantity > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _product.isAvailable && _product.stockQuantity > 0
                              ? 'In Stock (${_product.stockQuantity} available)'
                              : 'Out of Stock',
                          style: TextStyle(
                            color: _product.isAvailable && _product.stockQuantity > 0
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Farmer Info
                      if (_farmer != null)
                        GestureDetector(
                          onTap: () {
                            // Navigate to farmer details
                            Navigator.pushNamed(
                              context,
                              '/farmer-detail',
                              arguments: _farmer!.id,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                // Farmer Avatar
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _farmer!.profileImage != null
                                      ? NetworkImage(_farmer!.profileImage!)
                                      : null,
                                  child: _farmer!.profileImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 24,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Farmer Name & Rating
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _farmer!.name ?? 'Farmer',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_farmer!.badgeType != null)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: BadgeIcon(
                                                badgeType: _farmer!.badgeType!,
                                                size: 14,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_farmer!.rating?.toStringAsFixed(1) ?? '0.0'} (${_farmer!.totalRatings ?? 0} ratings)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // View Profile Button
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // Product Details
                      const Text(
                        'Product Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _product.description,
                        style: TextStyle(
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Product Dates
                      const Text(
                        'Important Dates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Harvest Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Harvest Date: ${dateFormat.format(_product.harvestDate)}',
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Best Before Date
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Best Before: ${dateFormat.format(_product.bestBeforeDate)}',
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        // Minus Button
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 1 ? _decrementQuantity : null,
                          color: _quantity > 1 ? AppColors.primaryColor : Colors.grey,
                        ),
                        // Quantity
                        Text(
                          _quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Plus Button
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _product.stockQuantity > _quantity ? _incrementQuantity : null,
                          color: _product.stockQuantity > _quantity ? AppColors.primaryColor : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Buy Now Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _product.isAvailable && _product.stockQuantity > 0
                          ? _proceedToCheckout
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
