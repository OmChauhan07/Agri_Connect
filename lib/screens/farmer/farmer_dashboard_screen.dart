import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/product_card.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  bool _isLoading = true;
  List<Product> _topProducts = [];
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _deliveredOrders = 0;
  double _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user == null) return;

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Fetch farmer's products
      await productProvider.fetchFarmerProducts(user.id);
      
      // Fetch farmer's orders
      await orderProvider.fetchFarmerOrders(user.id);
      
      final orders = orderProvider.farmerOrders;
      
      // Calculate dashboard statistics
      _totalOrders = orders.length;
      _pendingOrders = orders.where((order) => 
        order.status == OrderStatus.pending || 
        order.status == OrderStatus.processing ||
        order.status == OrderStatus.shipped
      ).length;
      _deliveredOrders = orders.where((order) => 
        order.status == OrderStatus.delivered
      ).length;
      
      // Calculate total revenue
      _totalRevenue = orders
          .where((order) => order.status == OrderStatus.delivered)
          .fold(0, (sum, order) => sum + order.totalAmount);
      
      // Get top rated products
      final allProducts = productProvider.farmerProducts;
      allProducts.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      _topProducts = allProducts.take(3).toList();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & User Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${user?.name ?? 'Farmer'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (user?.badgeType != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      color: user?.badgeType == 'green'
                                          ? Colors.green[300]
                                          : Colors.orange[300],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified Organic Farmer',
                                      style: TextStyle(
                                        color: Colors.grey[100],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user?.rating?.toStringAsFixed(1) ?? '0.0'} (${user?.totalRatings ?? 0} ratings)',
                                    style: TextStyle(
                                      color: Colors.grey[100],
                                      fontSize: 14,
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
                  const SizedBox(height: 24),
                  
                  // Statistics
                  const Text(
                    'Your Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Stat Cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Total Orders
                      _buildStatCard(
                        icon: Icons.shopping_bag,
                        color: Colors.blue,
                        title: 'Total Orders',
                        value: _totalOrders.toString(),
                      ),
                      // Pending Orders
                      _buildStatCard(
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                        title: 'Pending',
                        value: _pendingOrders.toString(),
                      ),
                      // Delivered Orders
                      _buildStatCard(
                        icon: Icons.check_circle,
                        color: Colors.green,
                        title: 'Delivered',
                        value: _deliveredOrders.toString(),
                      ),
                      // Revenue
                      _buildStatCard(
                        icon: Icons.attach_money,
                        color: Colors.purple,
                        title: 'Revenue',
                        value: currencyFormat.format(_totalRevenue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Top Products
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Top Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to products tab
                          // Using bottom navigation
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Product List
                  _topProducts.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory,
                                  size: 48,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No products listed yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to add product screen
                                    Navigator.pushNamed(context, '/add-product');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text('Add Product'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _topProducts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = _topProducts[index];
                            return ProductCard(
                              product: product,
                              isFarmerView: true,
                              onTap: () {
                                // Navigate to product detail/edit screen
                              },
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
