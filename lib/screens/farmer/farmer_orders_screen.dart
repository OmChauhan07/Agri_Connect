import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/order_card.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({Key? key}) : super(key: key);

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Order> _pendingOrders = [];
  List<Order> _processingOrders = [];
  List<Order> _shippedOrders = [];
  List<Order> _deliveredOrders = [];
  List<Order> _cancelledOrders = [];
  String _currentFarmerId = '';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user ID from auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        print('FarmerOrdersScreen: No user logged in');
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Please log in to view orders';
        });
        return;
      }

      _currentFarmerId = user.id;
      print('FarmerOrdersScreen: Loading orders for farmer: $_currentFarmerId');

      // Load orders through the provider
      await Provider.of<OrderProvider>(context, listen: false)
          .fetchFarmerOrders(farmerId: _currentFarmerId);

      final orders =
          Provider.of<OrderProvider>(context, listen: false).farmerOrders;
      print('FarmerOrdersScreen: Loaded ${orders.length} orders');

      // Update local order lists for tabs
      setState(() {
        final allOrders = orders;

        _pendingOrders = allOrders
            .where((order) => order.status == OrderStatus.pending)
            .toList();
        print('FarmerOrdersScreen: Pending orders: ${_pendingOrders.length}');

        _processingOrders = allOrders
            .where((order) => order.status == OrderStatus.processing)
            .toList();
        print(
            'FarmerOrdersScreen: Processing orders: ${_processingOrders.length}');

        _shippedOrders = allOrders
            .where((order) => order.status == OrderStatus.shipped)
            .toList();
        print('FarmerOrdersScreen: Shipped orders: ${_shippedOrders.length}');

        _deliveredOrders = allOrders
            .where((order) => order.status == OrderStatus.delivered)
            .toList();
        print(
            'FarmerOrdersScreen: Delivered orders: ${_deliveredOrders.length}');

        _cancelledOrders = allOrders
            .where((order) => order.status == OrderStatus.cancelled)
            .toList();
        print(
            'FarmerOrdersScreen: Cancelled orders: ${_cancelledOrders.length}');

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      print('FarmerOrdersScreen: Error loading orders: $e');

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load orders: ${e.toString()}';
      });

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to load orders: ${e.toString().split('\n')[0]}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                _buildTab('Pending', _pendingOrders.length),
                _buildTab('Processing', _processingOrders.length),
                _buildTab('Shipped', _shippedOrders.length),
                _buildTab('Delivered', _deliveredOrders.length),
                _buildTab('Cancelled', _cancelledOrders.length),
              ],
            ),
          ),

          // Tab Content - Using basic widgets instead of TabBarView
          Expanded(
            child: orderProvider.farmerOrders.isEmpty
                ? const Center(child: Text('No orders available.'))
                : _buildCurrentOrders(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrders() {
    // Select the appropriate orders list based on current tab
    // Avoid operations that might trigger rebuilds
    final List<Order> currentOrders;
    final OrderStatus currentStatus;

    final index = _tabController.index;

    // Use a direct approach without switch statement to reduce complexity
    if (index == 0) {
      currentOrders = _pendingOrders;
      currentStatus = OrderStatus.pending;
    } else if (index == 1) {
      currentOrders = _processingOrders;
      currentStatus = OrderStatus.processing;
    } else if (index == 2) {
      currentOrders = _shippedOrders;
      currentStatus = OrderStatus.shipped;
    } else if (index == 3) {
      currentOrders = _deliveredOrders;
      currentStatus = OrderStatus.delivered;
    } else if (index == 4) {
      currentOrders = _cancelledOrders;
      currentStatus = OrderStatus.cancelled;
    } else {
      // Fallback
      currentOrders = _pendingOrders;
      currentStatus = OrderStatus.pending;
    }

    // Show empty state if no orders
    if (currentOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(currentStatus),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${currentStatus.name} orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Show orders list - use simpler ListView to avoid unnecessary complexity
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: currentOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildOrderCard(currentOrders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(order.orderDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 8),

                // Total Items
                Text(
                  'Items: ${order.items.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 8),

                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.delivered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildActionButtons(order),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(Order order) {
    switch (order.status) {
      case OrderStatus.pending:
        return [
          _actionButton('Accept', Colors.green,
              () => _updateOrderStatus(order, OrderStatus.processing)),
          const SizedBox(width: 8),
          _actionButton('Cancel', Colors.red,
              () => _updateOrderStatus(order, OrderStatus.cancelled)),
        ];
      case OrderStatus.processing:
        return [
          _actionButton('Ship', Colors.blue,
              () => _updateOrderStatus(order, OrderStatus.shipped)),
        ];
      case OrderStatus.shipped:
        return [
          _actionButton('Delivered', Colors.green,
              () => _updateOrderStatus(order, OrderStatus.delivered)),
        ];
      default:
        return [];
    }
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(80, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildTab(String title, int count) {
    return Tab(
      child: Row(
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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.processing:
        return Icons.hourglass_bottom;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      if (!mounted) return;

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Create a copy of the order with the new status
      final updatedOrder = order.copyWith(status: newStatus);

      print(
          'FarmerOrdersScreen: Updating order ${order.id} status from ${order.status.name} to ${newStatus.name}');

      // Start showing a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updating order status...'),
          duration: Duration(seconds: 1),
        ),
      );

      await orderProvider.updateOrder(updatedOrder);

      if (!mounted) return;

      // Display appropriate message based on the new status
      String message;
      if (newStatus == OrderStatus.delivered) {
        message =
            'Order marked as delivered! Consumer will see it in their completed orders.';
      } else {
        message = 'Order status updated to ${newStatus.name}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      // Reload orders without directly calling setState
      _loadOrders();
    } catch (e) {
      if (!mounted) return;

      print('FarmerOrdersScreen: Error updating order status: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
