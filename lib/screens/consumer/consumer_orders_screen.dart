import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/order_card.dart';
import '../../widgets/rating_bar.dart';

class ConsumerOrdersScreen extends StatefulWidget {
  const ConsumerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerOrdersScreen> createState() => _ConsumerOrdersScreenState();
}

class _ConsumerOrdersScreenState extends State<ConsumerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  List<Order> _cancelledOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => _loadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user == null) return;

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.fetchConsumerOrders(user.id);

      final allOrders = orderProvider.consumerOrders;

      setState(() {
        // Active orders: pending, processing, shipped
        _activeOrders = allOrders
            .where((order) =>
                order.status == OrderStatus.pending ||
                order.status == OrderStatus.processing ||
                order.status == OrderStatus.shipped)
            .toList();

        // Completed orders: delivered
        _completedOrders = allOrders
            .where((order) => order.status == OrderStatus.delivered)
            .toList();

        // Cancelled orders
        _cancelledOrders = allOrders
            .where((order) => order.status == OrderStatus.cancelled)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                _buildTab('Active', _activeOrders.length),
                _buildTab('Completed', _completedOrders.length),
                _buildTab('Cancelled', _cancelledOrders.length),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(_activeOrders, 'active'),
                      _buildOrdersList(_completedOrders, 'completed'),
                      _buildOrdersList(_cancelledOrders, 'cancelled'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, String type) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'active'
                  ? Icons.shopping_bag_outlined
                  : type == 'completed'
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No $type orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'active'
                  ? 'Your current orders will appear here'
                  : type == 'completed'
                      ? 'Your completed orders will appear here'
                      : 'Your cancelled orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (type != 'active') const SizedBox(height: 24),
            if (type != 'active')
              ElevatedButton(
                onPressed: () {
                  // Navigate to marketplace
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Browse Products'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            isFarmerView: false,
            onRatePressed: type == 'completed' && !order.isRated
                ? () => _showRatingDialog(order)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _showRatingDialog(Order order) async {
    double rating = 5.0;
    final TextEditingController commentController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Rate Your Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How would you rate your experience?'),
                const SizedBox(height: 16),
                RatingBar(
                  initialRating: rating,
                  onRatingChanged: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitRating(order, rating, commentController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _submitRating(Order order, double rating, String comment) async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Mark the order as rated
      final updatedOrder = order.copyWith(isRated: true);

      // Submit the rating for both the farmer and the products
      await orderProvider.rateOrder(updatedOrder, rating, comment);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh orders
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: ${e.toString()}')),
      );
    }
  }
}
