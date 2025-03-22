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

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Order> _pendingOrders = [];
  List<Order> _processingOrders = [];
  List<Order> _shippedOrders = [];
  List<Order> _deliveredOrders = [];
  List<Order> _cancelledOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadOrders();
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
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user == null) return;

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.fetchFarmerOrders(user.id);
      
      final allOrders = orderProvider.farmerOrders;
      
      setState(() {
        _pendingOrders = allOrders.where((order) => order.status == OrderStatus.pending).toList();
        _processingOrders = allOrders.where((order) => order.status == OrderStatus.processing).toList();
        _shippedOrders = allOrders.where((order) => order.status == OrderStatus.shipped).toList();
        _deliveredOrders = allOrders.where((order) => order.status == OrderStatus.delivered).toList();
        _cancelledOrders = allOrders.where((order) => order.status == OrderStatus.cancelled).toList();
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
                      _buildOrdersList(_pendingOrders, OrderStatus.pending),
                      _buildOrdersList(_processingOrders, OrderStatus.processing),
                      _buildOrdersList(_shippedOrders, OrderStatus.shipped),
                      _buildOrdersList(_deliveredOrders, OrderStatus.delivered),
                      _buildOrdersList(_cancelledOrders, OrderStatus.cancelled),
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
  
  Widget _buildOrdersList(List<Order> orders, OrderStatus status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status.name} orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
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
            isFarmerView: true,
            onActionPressed: (newStatus) => _updateOrderStatus(order, newStatus),
          );
        },
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
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      
      // Create a copy of the order with the new status
      final updatedOrder = order.copyWith(status: newStatus);
      
      await orderProvider.updateOrder(updatedOrder);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${newStatus.name}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh orders list
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: ${e.toString()}')),
      );
    }
  }
}
