import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../models/order.dart';
import '../models/rating.dart';
import '../models/user.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Products
  
  // Add a product
  Future<void> addProduct(Product product) async {
    try {
      await _supabase
          .from('products')
          .insert(product.toJson());
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }
  
  // Update a product
  Future<void> updateProduct(Product product) async {
    try {
      await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }
  
  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }
  
  // Get a product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .single();
      
      return Product.fromJson(data);
    } catch (e) {
      return null;
    }
  }
  
  // Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);
      
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } catch (e) {
      throw Exception('Failed to get products: ${e.toString()}');
    }
  }
  
  // Get products by farmer ID
  Future<List<Product>> getProductsByFarmerId(String farmerId) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('farmer_id', farmerId)
          .order('created_at', ascending: false);
      
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } catch (e) {
      throw Exception('Failed to get farmer products: ${e.toString()}');
    }
  }
  
  // Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_available', true)
          .order('rating', ascending: false)
          .limit(10);
      
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } catch (e) {
      throw Exception('Failed to get featured products: ${e.toString()}');
    }
  }
  
  // Orders
  
  // Create an order
  Future<void> createOrder(Order order) async {
    try {
      await _supabase
          .from('orders')
          .insert(order.toJson());
      
      // Update product stock
      for (var item in order.items) {
        final product = await getProductById(item.productId);
        if (product != null) {
          final updatedProduct = product.copyWith(
            stockQuantity: product.stockQuantity - item.quantity,
            isAvailable: product.stockQuantity - item.quantity > 0,
          );
          await updateProduct(updatedProduct);
        }
      }
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }
  
  // Update an order
  Future<void> updateOrder(Order order) async {
    try {
      await _supabase
          .from('orders')
          .update(order.toJson())
          .eq('id', order.id);
    } catch (e) {
      throw Exception('Failed to update order: ${e.toString()}');
    }
  }
  
  // Get orders by consumer ID
  Future<List<Order>> getOrdersByConsumerId(String consumerId) async {
    try {
      final data = await _supabase
          .from('orders')
          .select()
          .eq('consumer_id', consumerId)
          .order('order_date', ascending: false);
      
      return data.map<Order>((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Failed to get consumer orders: ${e.toString()}');
    }
  }
  
  // Get orders by farmer ID
  Future<List<Order>> getOrdersByFarmerId(String farmerId) async {
    try {
      final data = await _supabase
          .from('orders')
          .select()
          .eq('farmer_id', farmerId)
          .order('order_date', ascending: false);
      
      return data.map<Order>((order) => Order.fromJson(order)).toList();
    } catch (e) {
      throw Exception('Failed to get farmer orders: ${e.toString()}');
    }
  }
  
  // Ratings
  
  // Add a rating
  Future<void> addRating(Rating rating) async {
    try {
      await _supabase
          .from('ratings')
          .insert(rating.toJson());
      
      // Update the target's average rating
      if (rating.type == RatingType.product) {
        await _updateProductRating(rating.targetId);
      } else if (rating.type == RatingType.farmer) {
        await _updateFarmerRating(rating.targetId);
      }
    } catch (e) {
      throw Exception('Failed to add rating: ${e.toString()}');
    }
  }
  
  // Update product rating
  Future<void> _updateProductRating(String productId) async {
    try {
      // Get all ratings for the product
      final data = await _supabase
          .from('ratings')
          .select()
          .eq('target_id', productId)
          .eq('type', RatingType.product.name);
      
      if (data.isEmpty) return;
      
      // Calculate average rating
      final ratings = data.map<double>((rating) => rating['rating']).toList();
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      
      // Update product rating
      await _supabase
          .from('products')
          .update({
            'rating': averageRating,
            'total_ratings': ratings.length,
          })
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to update product rating: ${e.toString()}');
    }
  }
  
  // Update farmer rating
  Future<void> _updateFarmerRating(String farmerId) async {
    try {
      // Get all ratings for the farmer
      final data = await _supabase
          .from('ratings')
          .select()
          .eq('target_id', farmerId)
          .eq('type', RatingType.farmer.name);
      
      if (data.isEmpty) return;
      
      // Calculate average rating
      final ratings = data.map<double>((rating) => rating['rating']).toList();
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      
      // Update farmer rating
      await _supabase
          .from('users')
          .update({
            'rating': averageRating,
            'total_ratings': ratings.length,
            'badge_type': averageRating >= 4.6 ? 'green' : (averageRating >= 4.0 ? 'orange' : null),
          })
          .eq('id', farmerId);
    } catch (e) {
      throw Exception('Failed to update farmer rating: ${e.toString()}');
    }
  }
  
  // Get ratings by user ID
  Future<List<Rating>> getRatingsByUserId(String userId) async {
    try {
      final data = await _supabase
          .from('ratings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return data.map<Rating>((rating) => Rating.fromJson(rating)).toList();
    } catch (e) {
      throw Exception('Failed to get user ratings: ${e.toString()}');
    }
  }
  
  // Get ratings by target ID and type
  Future<List<Rating>> getRatingsByTarget(String targetId, RatingType type) async {
    try {
      final data = await _supabase
          .from('ratings')
          .select()
          .eq('target_id', targetId)
          .eq('type', type.name)
          .order('created_at', ascending: false);
      
      return data.map<Rating>((rating) => Rating.fromJson(rating)).toList();
    } catch (e) {
      throw Exception('Failed to get target ratings: ${e.toString()}');
    }
  }
}
