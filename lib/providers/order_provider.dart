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
    _isLoading = true;
    notifyListeners();
    
    try {
      _consumerOrders = await _databaseService.getOrdersByConsumerId(consumerId);
    } catch (e) {
      debugPrint('Error fetching consumer orders: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch Farmer Orders
  Future<void> fetchFarmerOrders(String farmerId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _farmerOrders = await _databaseService.getOrdersByFarmerId(farmerId);
    } catch (e) {
      debugPrint('Error fetching farmer orders: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
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
      await _databaseService.updateOrder(order);
      
      // Update in local lists
      final consumerIndex = _consumerOrders.indexWhere((o) => o.id == order.id);
      if (consumerIndex != -1) {
        _consumerOrders[consumerIndex] = order;
      }
      
      final farmerIndex = _farmerOrders.indexWhere((o) => o.id == order.id);
      if (farmerIndex != -1) {
        _farmerOrders[farmerIndex] = order;
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
      Order? order = _consumerOrders.firstWhere((o) => o.id == orderId, orElse: () => 
        _farmerOrders.firstWhere((o) => o.id == orderId, orElse: () => 
          Order(
            id: '', 
            consumerId: '', 
            farmerId: '', 
            items: [], 
            totalAmount: 0, 
            orderDate: DateTime.now(), 
            status: OrderStatus.pending
          )
        )
      );
      
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
