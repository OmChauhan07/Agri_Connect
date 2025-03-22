import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/order.dart';
import '../models/rating.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Order> _consumerOrders = [];
  List<Order> _farmerOrders = [];
  bool _isLoading = false;

  List<Order> get consumerOrders => _consumerOrders;
  List<Order> get farmerOrders => _farmerOrders;
  bool get isLoading => _isLoading;

  // Fetch Consumer Orders
  Future<void> fetchConsumerOrders(String consumerId) async {
    // Set loading state first
    _isLoading = true;
    notifyListeners();

    try {
      print('OrderProvider: Fetching orders for consumer: $consumerId');

      // Fetch data
      final orders = await _databaseService.getOrdersByConsumerId(consumerId);

      print(
          'OrderProvider: Received ${orders.length} orders for consumer from database');

      // Update state with fetched data
      _consumerOrders = orders;

      // Log order status distribution for debugging
      if (orders.isNotEmpty) {
        print('OrderProvider: Consumer orders by status:');
        print(
            '  - Pending: ${orders.where((order) => order.status == OrderStatus.pending).length}');
        print(
            '  - Processing: ${orders.where((order) => order.status == OrderStatus.processing).length}');
        print(
            '  - Shipped: ${orders.where((order) => order.status == OrderStatus.shipped).length}');
        print(
            '  - Delivered: ${orders.where((order) => order.status == OrderStatus.delivered).length}');
        print(
            '  - Cancelled: ${orders.where((order) => order.status == OrderStatus.cancelled).length}');
      }

      _isLoading = false;

      // Notify after state is updated
      notifyListeners();
    } catch (e) {
      // Handle error
      print('OrderProvider: Error fetching consumer orders: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Farmer Orders
  Future<void> fetchFarmerOrders({required String farmerId}) async {
    // Set loading state first
    _isLoading = true;
    notifyListeners();

    try {
      print('OrderProvider: Fetching orders for farmer: $farmerId');

      // Fetch data
      final orders = await _databaseService.getOrdersByFarmerId(farmerId);

      print(
          'OrderProvider: Received ${orders.length} orders from database service');

      // Update state with fetched data
      _farmerOrders = orders;

      if (orders.isNotEmpty) {
        print('OrderProvider: Orders by status:');
        print(
            '  - Pending: ${orders.where((order) => order.status == OrderStatus.pending).length}');
        print(
            '  - Processing: ${orders.where((order) => order.status == OrderStatus.processing).length}');
        print(
            '  - Completed: ${orders.where((order) => order.status == OrderStatus.delivered).length}');
        print(
            '  - Cancelled: ${orders.where((order) => order.status == OrderStatus.cancelled).length}');
      } else {
        print('OrderProvider: No orders found for farmer');
      }

      _isLoading = false;

      // Notify after state is updated
      notifyListeners();
    } catch (e) {
      // Handle error
      print('OrderProvider: Error fetching farmer orders: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create Order
  Future<void> createOrder(Order order) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.createOrder(order);
      _consumerOrders.add(order);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Order
  Future<void> updateOrder(Order order) async {
    _isLoading = true;
    notifyListeners();

    try {
      print(
          'OrderProvider: Updating order ${order.id} with status ${order.status.name}');

      await _databaseService.updateOrder(order);

      // Update in local lists
      final consumerIndex = _consumerOrders.indexWhere((o) => o.id == order.id);
      if (consumerIndex != -1) {
        _consumerOrders[consumerIndex] = order;
        print('OrderProvider: Updated order in consumer orders list');
      } else {
        // If the order is not in consumer list but should be (we're updating from farmer side)
        if (order.status == OrderStatus.delivered ||
            order.status == OrderStatus.cancelled) {
          print(
              'OrderProvider: Order not found in consumer list, will be updated on next fetch');
        }
      }

      final farmerIndex = _farmerOrders.indexWhere((o) => o.id == order.id);
      if (farmerIndex != -1) {
        _farmerOrders[farmerIndex] = order;
        print('OrderProvider: Updated order in farmer orders list');
      } else {
        // If the order is not in farmer list but should be (we're updating from consumer side)
        print(
            'OrderProvider: Order not found in farmer list, will be updated on next fetch');
      }

      // If status changed to delivered, ensure the consumer sees it in their completed orders list
      if (order.status == OrderStatus.delivered) {
        print(
            'OrderProvider: Order status set to delivered, updating all affected lists');

        // We should refresh consumer orders list to make sure it appears in completed tab
        if (consumerIndex == -1) {
          // If we don't have the consumer's orders loaded, load them
          try {
            await fetchConsumerOrders(order.consumerId);
            print(
                'OrderProvider: Fetched consumer orders to update delivered status');
          } catch (e) {
            print('OrderProvider: Failed to fetch consumer orders: $e');
          }
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Order By ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      // Check in local lists first
      Order? order = _consumerOrders.firstWhere((o) => o.id == orderId,
          orElse: () => _farmerOrders.firstWhere((o) => o.id == orderId,
              orElse: () => Order(
                  id: '',
                  consumerId: '',
                  farmerId: '',
                  items: [],
                  totalAmount: 0,
                  orderDate: DateTime.now(),
                  status: OrderStatus.pending)));

      if (order.id.isNotEmpty) {
        return order;
      }

      // Fetch from database if not found locally
      // This would require a new method in DatabaseService
      return null;
    } catch (e) {
      debugPrint('Error getting order: ${e.toString()}');
      return null;
    }
  }

  // Rate Order
  Future<void> rateOrder(Order order, double rating, String comment) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update order as rated
      await updateOrder(order);

      // Add rating for farmer
      final farmerRating = Rating(
        id: const Uuid().v4(),
        userId: order.consumerId,
        targetId: order.farmerId,
        type: RatingType.farmer,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _databaseService.addRating(farmerRating);

      // Add ratings for each product in the order
      for (var item in order.items) {
        final productRating = Rating(
          id: const Uuid().v4(),
          userId: order.consumerId,
          targetId: item.productId,
          type: RatingType.product,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        );

        await _databaseService.addRating(productRating);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
