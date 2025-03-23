import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/localization_helper.dart';
import '../../widgets/rating_bar.dart';

class FarmerDetailScreen extends StatefulWidget {
  final String farmerId;

  const FarmerDetailScreen({
    Key? key,
    required this.farmerId,
  }) : super(key: key);

  @override
  State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
}

class _FarmerDetailScreenState extends State<FarmerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  UserModel? _farmer;
  List<Product> _farmerProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFarmerDetails();
  }

  Future<void> _loadFarmerDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, fetch farmer details from API
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Get farmer details
      // This is a mock implementation - in a real app, you would fetch from your API
      _farmer = await authProvider.getUserById(widget.farmerId);

      // Get farmer products
      if (_farmer != null) {
        // In a real app, you would fetch the farmer's products from the API
        // For now, we'll filter all products to only show those from this farmer
        await productProvider.fetchAllProducts();
        _farmerProducts = productProvider.allProducts
            .where((product) => product.farmerId == widget.farmerId)
            .toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading farmer details: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationHelper.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _farmer == null
              ? Center(
                  child: Text('Farmer not found'),
                )
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Farmer Details Card
                          _buildFarmerDetailsCard(),

                          // Tab Bar
                          Container(
                            color: Colors.white,
                            child: TabBar(
                              controller: _tabController,
                              labelColor: AppColors.primary,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: AppColors.primary,
                              tabs: [
                                Tab(text: loc.farmerProducts),
                                Tab(text: loc.ratingsFarmer),
                                Tab(text: loc.farmerPractices),
                              ],
                            ),
                          ),

                          // Tab Content
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildProductsTab(),
                                _buildReviewsTab(),
                                _buildPracticesTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _farmer?.profileImage != null
            ? Image.network(
                _farmer!.profileImage!,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.primary,
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              // Share farmer profile
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farmer Name
          Row(
            children: [
              Expanded(
                child: Text(
                  _farmer?.name ?? 'Organic Farmer',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_farmer?.badgeType != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _farmer?.badgeType == 'green'
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.eco,
                        size: 16,
                        color: _farmer?.badgeType == 'green'
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _farmer?.badgeType == 'green'
                            ? 'Certified Organic'
                            : 'Natural Farming',
                        style: TextStyle(
                          fontSize: 12,
                          color: _farmer?.badgeType == 'green'
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Rating
          Row(
            children: [
              RatingBarDisplay(
                rating: _farmer?.rating ?? 0,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${_farmer?.rating?.toStringAsFixed(1) ?? '0.0'} (${_farmer?.totalRatings ?? 0} reviews)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Address
          if (_farmer?.address != null)
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _farmer!.address!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          // Contact
          if (_farmer?.phoneNumber != null)
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _farmer!.phoneNumber!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                  onPressed: () {
                    // Message farmer
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                  onPressed: () {
                    // Call farmer
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return _farmerProducts.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products available from this farmer',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _farmerProducts.length,
            itemBuilder: (context, index) {
              final product = _farmerProducts[index];
              return GestureDetector(
                onTap: () {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          );
  }

  Widget _buildReviewsTab() {
    // Mock reviews - in a real app, you would fetch these from your API
    final List<Map<String, dynamic>> _mockReviews = [
      {
        'name': 'John Doe',
        'rating': 5.0,
        'date': '2023-06-15',
        'comment': 'Great quality produce! Will buy again.',
      },
      {
        'name': 'Alice Smith',
        'rating': 4.5,
        'date': '2023-06-10',
        'comment': 'Fresh vegetables and very friendly service.',
      },
      {
        'name': 'Robert Johnson',
        'rating': 5.0,
        'date': '2023-05-28',
        'comment': 'Excellent organic produce. Highly recommended!',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockReviews.length,
      itemBuilder: (context, index) {
        final review = _mockReviews[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Reviewer Avatar
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reviewer Name & Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            RatingBarDisplay(
                              rating: review['rating'],
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              review['date'],
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
              const SizedBox(height: 12),
              // Review Comment
              Text(
                review['comment'],
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPracticesTab() {
    // Mock farming practices - in a real app, you would fetch these from your API
    final List<Map<String, dynamic>> _farmingPractices = [
      {
        'title': 'Organic Certification',
        'icon': Icons.verified,
        'description':
            'All products certified organic by Indian Organic Certification Agency (IOCA).',
      },
      {
        'title': 'No Pesticides',
        'icon': Icons.nature,
        'description':
            'We use natural methods to control pests without harmful chemicals.',
      },
      {
        'title': 'Water Conservation',
        'icon': Icons.water_drop,
        'description':
            'Drip irrigation systems to minimize water usage and maximize efficiency.',
      },
      {
        'title': 'Local Seeds',
        'icon': Icons.grass,
        'description':
            'Using indigenous seed varieties to preserve local biodiversity.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmingPractices.length,
      itemBuilder: (context, index) {
        final practice = _farmingPractices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  practice['icon'],
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      practice['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
