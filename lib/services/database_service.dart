import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../models/order.dart';
import '../models/rating.dart';
import '../models/user.dart';
import '../models/ngo.dart';
import '../models/donation.dart';
import '../utils/constants.dart';

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
          .from('featured_products')
          .select();
      
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } catch (e) {
      throw Exception('Failed to get featured products: ${e.toString()}');
    }
  }
  
  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('category', category)
          .eq('is_available', true)
          .order('rating', ascending: false);
      
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: ${e.toString()}');
    }
  }
  
  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('is_available', true)
          .or('name.ilike.%${query}%,description.ilike.%${query}%')
          .order('rating', ascending: false);
      
      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }
  
  // Orders
  
  // Create an order
  Future<void> createOrder(Order order) async {
    try {
      // Use the stored procedure to create the order
      final items = order.items.map((item) => {
        'product_id': item.productId,
        'quantity': item.quantity,
      }).toList();
      
      await _supabase
          .rpc('create_order', params: {
            'p_consumer_id': order.consumerId,
            'p_delivery_address': order.deliveryAddress ?? '',
            'p_contact_number': '',  // TODO: Add contact number to Order model
            'p_items': items,
          });
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }
  
  // Update an order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _supabase
          .rpc('update_order_status', params: {
            'p_order_id': orderId,
            'p_status': status.name,
          });
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }
  
  // Update an order (full update)
  Future<void> updateOrder(Order order) async {
    try {
      // Update order status (main table)
      await _supabase
          .from('orders')
          .update({
            'status': order.status.name,
            'delivery_address': order.deliveryAddress,
            'total_amount': order.totalAmount,
          })
          .eq('id', order.id);
          
      // Order items can't be updated after creation
      // If needed, implement item updates here
    } catch (e) {
      throw Exception('Failed to update order: ${e.toString()}');
    }
  }
  
  // Get an order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final orderData = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();
      
      final itemsData = await _supabase
          .from('order_items')
          .select('*, products(name)')
          .eq('order_id', orderId);
      
      final items = itemsData.map<OrderItem>((item) => OrderItem(
        productId: item['product_id'],
        productName: item['products']['name'],
        quantity: item['quantity'],
        price: item['price_per_unit'],
      )).toList();
      
      return Order.fromJson({
        ...orderData,
        'items': items,
      });
    } catch (e) {
      return null;
    }
  }
  
  // Get orders by consumer ID
  Future<List<Order>> getOrdersByConsumerId(String consumerId) async {
    try {
      final data = await _supabase
          .from('orders')
          .select('*, order_items(*, products(name))')
          .eq('consumer_id', consumerId)
          .order('order_date', ascending: false);
      
      return data.map<Order>((order) {
        final items = (order['order_items'] as List).map<OrderItem>((item) => OrderItem(
          productId: item['product_id'],
          productName: item['products']['name'],
          quantity: item['quantity'],
          price: item['price_per_unit'],
        )).toList();
        
        return Order.fromJson({
          ...order,
          'items': items,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get consumer orders: ${e.toString()}');
    }
  }
  
  // Get orders by farmer ID
  Future<List<Order>> getOrdersByFarmerId(String farmerId) async {
    try {
      final data = await _supabase
          .from('order_items')
          .select('*, orders(*), products(name)')
          .eq('farmer_id', farmerId)
          .order('created_at', ascending: false);
      
      // Group by order_id
      final Map<String, Order> orderMap = {};
      
      for (var item in data) {
        final orderId = item['order_id'];
        final orderItem = OrderItem(
          productId: item['product_id'],
          productName: item['products']['name'],
          quantity: item['quantity'],
          price: item['price_per_unit'],
        );
        
        if (orderMap.containsKey(orderId)) {
          orderMap[orderId]!.items.add(orderItem);
        } else {
          final order = Order.fromJson({
            ...item['orders'],
            'items': [orderItem],
          });
          orderMap[orderId] = order;
        }
      }
      
      return orderMap.values.toList();
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
      
      // The triggers will automatically update the target's rating
    } catch (e) {
      throw Exception('Failed to add rating: ${e.toString()}');
    }
  }
  
  // Update product rating - Using triggers now but keeping as fallback
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
  
  // Update farmer rating - Using triggers now but keeping as fallback
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
          .select('*, users(name, profile_image)')
          .eq('target_id', targetId)
          .eq('type', type.name)
          .order('created_at', ascending: false);
      
      return data.map<Rating>((rating) => Rating.fromJson({
        ...rating,
        'user_name': rating['users']['name'],
        'user_image': rating['users']['profile_image'],
      })).toList();
    } catch (e) {
      throw Exception('Failed to get target ratings: ${e.toString()}');
    }
  }
  
  // NGOs and Donations
  
  // Get all NGOs
  Future<List<NGO>> getAllNGOs() async {
    try {
      final data = await _supabase
          .from('ngos')
          .select()
          .order('name');
      
      return data.map<NGO>((ngo) => NGO.fromJson(ngo)).toList();
    } catch (e) {
      throw Exception('Failed to get NGOs: ${e.toString()}');
    }
  }
  
  // Get NGO by ID
  Future<NGO?> getNGOById(String ngoId) async {
    try {
      final data = await _supabase
          .from('ngos')
          .select()
          .eq('id', ngoId)
          .single();
      
      return NGO.fromJson(data);
    } catch (e) {
      return null;
    }
  }
  
  // Create a donation
  Future<Donation> createDonation(Donation donation) async {
    try {
      // Generate a certificate ID
      final certificateId = generateCertificateId();
      
      // Create a map from the donation and add certificate ID
      final donationMap = donation.toJson();
      donationMap['certificate_id'] = certificateId;
      
      final data = await _supabase
          .from('donations')
          .insert(donationMap)
          .select()
          .single();
      
      return Donation.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create donation: ${e.toString()}');
    }
  }
  
  // Generate a unique certificate ID for donations
  String generateCertificateId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomStr = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'DON-$dateStr-$randomStr';
  }
  
  // Get donation by ID
  Future<Donation?> getDonationById(String donationId) async {
    try {
      final data = await _supabase
          .from('donations')
          .select('*, ngos(name, logo_url)')
          .eq('id', donationId)
          .single();
      
      return Donation.fromJson({
        ...data,
        'ngo_name': data['ngos']['name'],
        'ngo_logo': data['ngos']['logo_url'],
      });
    } catch (e) {
      return null;
    }
  }
  
  // Get donations by consumer ID
  Future<List<Donation>> getDonationsByConsumerId(String consumerId) async {
    try {
      final data = await _supabase
          .from('donations')
          .select('*, ngos(name, logo_url)')
          .eq('consumer_id', consumerId)
          .order('donation_date', ascending: false);
      
      return data.map<Donation>((donation) => Donation.fromJson({
        ...donation,
        'ngo_name': donation['ngos']['name'],
        'ngo_logo': donation['ngos']['logo_url'],
      })).toList();
    } catch (e) {
      throw Exception('Failed to get user donations: ${e.toString()}');
    }
  }
  
  // Dashboard statistics
  
  // Get farmer dashboard statistics
  Future<Map<String, dynamic>> getFarmerDashboardStats(String farmerId) async {
    try {
      final data = await _supabase
          .rpc('get_farmer_stats', params: {
            'p_farmer_id': farmerId,
          });
      
      return data;
    } catch (e) {
      throw Exception('Failed to get farmer stats: ${e.toString()}');
    }
  }
  
  // Get consumer dashboard statistics
  Future<Map<String, dynamic>> getConsumerDashboardStats(String consumerId) async {
    try {
      final data = await _supabase
          .rpc('get_consumer_stats', params: {
            'p_consumer_id': consumerId,
          });
      
      return data;
    } catch (e) {
      throw Exception('Failed to get consumer stats: ${e.toString()}');
    }
  }
  
  // Initialize database with stored procedures
  Future<void> initializeDatabase() async {
    try {
      // Check if the database has been initialized
      final hasUsers = await _supabase
          .from('users')
          .select('id')
          .limit(1);
      
      if (hasUsers.isNotEmpty) {
        // Database already initialized
        return;
      }
      
      // Get the SQL file content
      // This would come from your assets
      final sqlScript = '''
      -- Run the database creation script
      -- This would be a simplified version for this method
      -- Insert sample NGOs
      INSERT INTO ngos (name, description, website_url, contact_email, contact_phone) VALUES
      ('Food For All', 'An organization dedicated to eliminating hunger by providing nutritious meals to those in need.', 'https://foodforall.org', 'contact@foodforall.org', '+91-9876543210'),
      ('Green Earth Initiative', 'We work towards sustainable farming practices and food security.', 'https://greenearthinitiative.org', 'info@greenearthinitiative.org', '+91-8765432109'),
      ('Rural Development Trust', 'Focusing on rural development through agriculture, education, and healthcare.', 'https://ruraldevelopmenttrust.org', 'support@ruraldevelopmenttrust.org', '+91-7654321098');
      ''';
      
      // Execute the SQL script
      await _supabase.rpc('exec_sql', params: {
        'sql_query': sqlScript,
      });
    } catch (e) {
      throw Exception('Failed to initialize database: ${e.toString()}');
    }
  }
}
