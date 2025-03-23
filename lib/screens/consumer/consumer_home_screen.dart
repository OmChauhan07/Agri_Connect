import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/localization_helper.dart';
import 'donation_screen.dart';
import 'consumer_orders_screen.dart';
import 'consumer_profile_screen.dart';

class ConsumerHomeScreen extends StatefulWidget {
  const ConsumerHomeScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const DonationScreen(),
    const ConsumerOrdersScreen(),
    const ConsumerProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final loc = LocalizationHelper.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          // If not on the first tab, go to the first tab
          _onTabTapped(0);
          return false; // Don't close the app
        }
        // Show exit app confirmation dialog
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(loc.commonWarning),
                content: Text('Are you sure you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(loc.commonCancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Exit'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove the back button
          title: Text(_getScreenTitle()),
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: loc.navigationHome,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.volunteer_activism),
                label: loc.navigationDonate,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_bag),
                label: loc.navigationOrders,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: loc.navigationProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get the title based on the current tab
  String _getScreenTitle() {
    final loc = LocalizationHelper.of(context);
    switch (_currentIndex) {
      case 0:
        return loc.navigationHome;
      case 1:
        return loc.navigationDonate;
      case 2:
        return loc.navigationOrders;
      case 3:
        return loc.navigationProfile;
      default:
        return loc.navigationHome;
    }
  }
}

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Load featured farmers and products
      await productProvider.fetchFeaturedFarmers();
      await productProvider.fetchFeaturedProducts();
      await productProvider.fetchAllProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading marketplace: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final loc = LocalizationHelper.of(context);

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: AppColors.primary,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.primary,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for products or farmers...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          // Navigate to all products with search query
                          Navigator.pushNamed(
                            context,
                            '/products',
                            arguments: {'searchQuery': value},
                          );
                        }
                      },
                    ),
                  ),

                  // Featured Farmers
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Top Rated Farmers',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to all farmers
                                Navigator.pushNamed(context, '/farmers');
                              },
                              child: Text(
                                'More',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Horizontal Farmer List
                        SizedBox(
                          height: 150,
                          child: productProvider.featuredFarmers.isEmpty
                              ? Center(
                                  child: Text(
                                    'No featured farmers yet',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: productProvider
                                              .featuredFarmers.length >
                                          5
                                      ? 5 // Show only top 5 farmers
                                      : productProvider.featuredFarmers.length,
                                  itemBuilder: (context, index) {
                                    final farmer =
                                        productProvider.featuredFarmers[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to farmer details
                                          Navigator.pushNamed(
                                            context,
                                            '/farmer-detail',
                                            arguments: farmer.id,
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            // Farmer Avatar
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 50,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage: farmer
                                                              .profileImage !=
                                                          null
                                                      ? NetworkImage(
                                                          farmer.profileImage!)
                                                      : null,
                                                  child: farmer.profileImage ==
                                                          null
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        )
                                                      : null,
                                                ),
                                                if (farmer.badgeType != null)
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            spreadRadius: 1,
                                                            blurRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        Icons.eco,
                                                        color:
                                                            farmer.badgeType ==
                                                                    'green'
                                                                ? Colors.green
                                                                : Colors.orange,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            // Farmer Name
                                            Text(
                                              farmer.name ?? 'Farmer',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            // Farmer Rating
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${farmer.rating?.toStringAsFixed(1) ?? '0.0'}',
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
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Top Rated Products
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              loc.productsFeatured,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to all products
                                Navigator.pushNamed(context, '/products');
                              },
                              child: Text(
                                loc.productsAll,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Horizontal Products List
                        SizedBox(
                          height: 220,
                          child: productProvider.featuredProducts.isEmpty
                              ? Center(
                                  child: Text(
                                    'No featured products yet',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      productProvider.featuredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product =
                                        productProvider.featuredProducts[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: GestureDetector(
                                        onTap: () {
                                          // Navigate to product details
                                          Navigator.pushNamed(
                                            context,
                                            '/product-detail',
                                            arguments: product.id,
                                          );
                                        },
                                        child: Container(
                                          width: 160,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Product Image
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(10),
                                                ),
                                                child: product
                                                        .imageUrls.isNotEmpty
                                                    ? Image.network(
                                                        product.imageUrls.first,
                                                        height: 120,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: 120,
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.image,
                                                          color: Colors.grey,
                                                          size: 40,
                                                        ),
                                                      ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Product Name
                                                    Text(
                                                      product.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    // Product Price
                                                    Text(
                                                      '₹${product.price.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    // Product Rating
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 14,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          '${product.rating?.toStringAsFixed(1) ?? '0.0'} (${product.totalRatings ?? 0})',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // All Categories
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category Grid
                        GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildCategoryCard('Vegetables', Icons.eco),
                            _buildCategoryCard('Fruits', Icons.apple),
                            _buildCategoryCard('Grains', Icons.grass),
                            _buildCategoryCard('Dairy', Icons.breakfast_dining),
                            _buildCategoryCard('Herbs', Icons.spa),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // All Products
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Products Grid
                        productProvider.allProducts.isEmpty
                            ? Center(
                                child: Text(
                                  'No products available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: productProvider.allProducts.length >
                                        4
                                    ? 4 // Just show 4 products in the home screen
                                    : productProvider.allProducts.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      productProvider.allProducts[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigate to product details
                                      Navigator.pushNamed(
                                        context,
                                        '/product-detail',
                                        arguments: product.id,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product Image
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                            child: product.imageUrls.isNotEmpty
                                                ? Image.network(
                                                    product.imageUrls.first,
                                                    height: 120,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    height: 120,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                  ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Product Name
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                // Product Price
                                                Text(
                                                  '₹${product.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                // Product Rating
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                      size: 14,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${product.rating?.toStringAsFixed(1) ?? '0.0'}',
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
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                        // See All Button
                        if (productProvider.allProducts.length > 4)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to all products
                                  Navigator.pushNamed(context, '/products');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: AppColors.primary),
                                  ),
                                ),
                                child: Text(loc.productsAll),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to all products screen with category filter
        Navigator.pushNamed(
          context,
          '/products',
          arguments: {'category': title},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
