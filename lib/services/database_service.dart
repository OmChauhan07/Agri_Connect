import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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
      final productJson = product.toJson();
      // Make sure category field is properly included in the database insert
      if (productJson['category'] == null ||
          productJson['category'].toString().isEmpty) {
        productJson['category'] =
            'Vegetables'; // Default category if not provided
      }

      await _supabase.from('products').insert(productJson);
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  // Update a product
  Future<void> updateProduct(Product product) async {
    try {
      final productJson = product.toJson();
      // Make sure category field is properly included in the database update
      if (productJson['category'] == null ||
          productJson['category'].toString().isEmpty) {
        productJson['category'] =
            'Vegetables'; // Default category if not provided
      }

      await _supabase.from('products').update(productJson).eq('id', product.id);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
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
      // First try the featured_products view
      final data = await _supabase.from('featured_products').select();

      // If the view doesn't return products, get some from the products table
      if (data.isEmpty) {
        final topProducts = await _supabase
            .from('products')
            .select()
            .order('rating', ascending: false)
            .limit(10);

        return topProducts
            .map<Product>((product) => Product.fromJson(product))
            .toList();
      }

      return data.map<Product>((product) => Product.fromJson(product)).toList();
    } catch (e) {
      // If there's an error with the view, fallback to querying products directly
      try {
        final data = await _supabase
            .from('products')
            .select()
            .order('created_at', ascending: false)
            .limit(10);

        return data
            .map<Product>((product) => Product.fromJson(product))
            .toList();
      } catch (fallbackError) {
        throw Exception('Failed to get featured products: ${e.toString()}');
      }
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('category', category)
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
      print('Creating order with consumer ID: ${order.consumerId}');
      print('Items count: ${order.items.length}');
      print('Farmer ID: ${order.farmerId}');

      // Start with a transaction by inserting the main order
      final orderData = {
        'id': order.id,
        'consumer_id': order.consumerId,
        'farmer_id': order
            .farmerId, // Include farmer_id since it exists in the orders table
        'total_amount': order.totalAmount,
        'status': order.status.name,
        'delivery_address': order.deliveryAddress ?? '',
        'contact_number': order.contactNumber ?? '',
        'order_date': order.orderDate.toIso8601String(),
      };

      // Insert the order
      print('Inserting order data: $orderData');
      await _supabase.from('orders').insert(orderData);
      print('Order record created successfully');

      // Now insert each order item
      for (var item in order.items) {
        // Get product info to find the correct farmer_id
        final productData = await _supabase
            .from('products')
            .select('farmer_id, stock_quantity')
            .eq('id', item.productId)
            .single();

        final farmerId = productData['farmer_id'];
        final currentStock = productData['stock_quantity'] as int;

        if (currentStock < item.quantity) {
          throw Exception('Not enough stock for product ${item.productId}');
        }

        final orderItemData = {
          'id': const Uuid().v4(),
          'order_id': order.id,
          'product_id': item.productId,
          'farmer_id': farmerId, // Use the farmer_id from the product
          'quantity': item.quantity,
          'price_per_unit': item.price,
          'subtotal': item.price * item.quantity,
        };

        print('Inserting order item: $orderItemData');
        await _supabase.from('order_items').insert(orderItemData);

        // Update the product stock
        final newStock = currentStock - item.quantity;
        final isAvailable = newStock > 0;

        await _supabase.from('products').update({
          'stock_quantity': newStock,
          'is_available': isAvailable
        }).eq('id', item.productId);
      }

      print('Order created successfully with all items');
    } catch (e) {
      print('Error details creating order: ${e.toString()}');
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Update an order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _supabase.rpc('update_order_status', params: {
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
      await _supabase.from('orders').update({
        'status': order.status.name,
        'delivery_address': order.deliveryAddress,
        'total_amount': order.totalAmount,
      }).eq('id', order.id);

      // Order items can't be updated after creation
      // If needed, implement item updates here
    } catch (e) {
      throw Exception('Failed to update order: ${e.toString()}');
    }
  }

  // Get an order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      // Get the order data
      final orderData =
          await _supabase.from('orders').select().eq('id', orderId).single();

      // Get all items for this order
      final itemsData = await _supabase
          .from('order_items')
          .select('*, products(name)')
          .eq('order_id', orderId);

      // Process items with null handling
      final items = (itemsData as List).map<OrderItem>((item) {
        return OrderItem(
          productId: item['product_id'] ?? '',
          productName: item['products'] != null
              ? item['products']['name'] ?? 'Unknown Product'
              : 'Unknown Product',
          quantity: item['quantity'] ?? 0,
          price: item['price_per_unit'] != null
              ? item['price_per_unit'].toDouble()
              : 0.0,
        );
      }).toList();

      // Convert OrderItem objects to a serializable format
      final itemsJson = items
          .map((item) => {
                'product_id': item.productId,
                'product_name': item.productName,
                'quantity': item.quantity,
                'price': item.price,
              })
          .toList();

      // Create and return the order
      return Order.fromJson({
        ...orderData,
        'items': itemsJson,
      });
    } catch (e) {
      print('Error getting order by ID: ${e.toString()}');
      return null;
    }
  }

  // Get orders by consumer ID
  Future<List<Order>> getOrdersByConsumerId(String consumerId) async {
    try {
      // Get all orders for this consumer
      final data = await _supabase
          .from('orders')
          .select()
          .eq('consumer_id', consumerId)
          .order('order_date', ascending: false);

      if (data == null || (data as List).isEmpty) {
        return [];
      }

      // Create a list to store orders
      final List<Order> orders = [];

      // Process each order
      for (final orderData in data) {
        try {
          final orderId = orderData['id'] as String;

          // Get all items for this order
          final itemsData = await _supabase
              .from('order_items')
              .select('*, products(name)')
              .eq('order_id', orderId);

          // Skip orders with no items
          if (itemsData == null || (itemsData as List).isEmpty) {
            continue;
          }

          // Create order items with careful null handling
          final List<Map<String, dynamic>> itemsJson = [];

          for (final item in itemsData) {
            final productName = item['products'] != null
                ? (item['products']['name'] ?? 'Unknown Product')
                : 'Unknown Product';

            itemsJson.add({
              'product_id': item['product_id'] ?? '',
              'product_name': productName,
              'quantity': item['quantity'] ?? 0,
              'price': (item['price_per_unit'] ?? 0).toDouble(),
            });
          }

          // Skip orders with no valid items
          if (itemsJson.isEmpty) {
            continue;
          }

          // Create the order with the items
          final order = Order.fromJson({
            ...orderData,
            'items': itemsJson,
          });

          orders.add(order);
        } catch (e) {
          print('Error processing consumer order: $e');
          // Continue with next order
          continue;
        }
      }

      return orders;
    } catch (e) {
      print('Error getting consumer orders: $e');
      return [];
    }
  }

  // Get orders by farmer ID
  Future<List<Order>> getOrdersByFarmerId(String farmerId) async {
    try {
      print('Fetching orders for farmer: $farmerId');

      // Try direct query first - since we now have farmer_id in orders table
      final directOrdersData =
          await _supabase.from('orders').select().eq('farmer_id', farmerId);

      print(
          'Direct orders query results: ${directOrdersData?.length ?? 0} orders found');

      // Then also get orders via order_items as a fallback
      final orderItemsData = await _supabase
          .from('order_items')
          .select('order_id, farmer_id')
          .eq('farmer_id', farmerId);

      if (orderItemsData == null || (orderItemsData as List).isEmpty) {
        print('No order items found for farmer: $farmerId');

        // If we have direct orders, return those
        if (directOrdersData != null && (directOrdersData as List).isNotEmpty) {
          print('Using ${directOrdersData.length} orders from direct query');

          final List<Order> directOrders = [];
          for (final orderData in directOrdersData) {
            try {
              final orderId = orderData['id'] as String;

              // Get the items for this order
              final itemsData = await _supabase
                  .from('order_items')
                  .select('*, products(name)')
                  .eq('order_id', orderId);

              if (itemsData == null || (itemsData as List).isEmpty) {
                print('No items found for order: $orderId');
                continue;
              }

              // Create order items
              final List<Map<String, dynamic>> itemsJson = [];

              for (final item in itemsData) {
                final productName = item['products'] != null
                    ? (item['products']['name'] ?? 'Unknown Product')
                    : 'Unknown Product';

                itemsJson.add({
                  'product_id': item['product_id'] ?? '',
                  'product_name': productName,
                  'quantity': item['quantity'] ?? 0,
                  'price': (item['price_per_unit'] ?? 0).toDouble(),
                });
              }

              // Create the order
              final order = Order.fromJson({
                ...orderData,
                'items': itemsJson,
              });

              directOrders.add(order);
            } catch (e) {
              print('Error processing direct order: $e');
              continue;
            }
          }

          print('Returning ${directOrders.length} direct orders');
          return directOrders;
        }

        return [];
      }

      print('Found ${(orderItemsData as List).length} order items for farmer');

      // Extract unique order IDs
      final Set<String> orderIds = {};
      for (var item in orderItemsData) {
        if (item['order_id'] != null) {
          orderIds.add(item['order_id'] as String);
        }
      }

      if (orderIds.isEmpty) {
        print('No valid order IDs extracted from order items');
        return [];
      }

      print('Processing ${orderIds.length} unique orders');

      // Create a list to store orders
      final List<Order> orders = [];

      // Fetch each order with its items
      for (final orderId in orderIds) {
        try {
          // Get the order data
          final orderData = await _supabase
              .from('orders')
              .select()
              .eq('id', orderId)
              .single();

          // Get the items for this order that belong to this farmer
          final itemsData = await _supabase
              .from('order_items')
              .select('*, products(name, price, category, image_urls)')
              .eq('order_id', orderId)
              .eq('farmer_id', farmerId);

          // Skip if no items found
          if (itemsData == null || (itemsData as List).isEmpty) {
            print('No items found for order: $orderId');
            continue;
          }

          // Create order items
          final List<Map<String, dynamic>> itemsJson = [];

          for (final item in itemsData) {
            final productName = item['products'] != null
                ? (item['products']['name'] ?? 'Unknown Product')
                : 'Unknown Product';

            itemsJson.add({
              'product_id': item['product_id'] ?? '',
              'product_name': productName,
              'quantity': item['quantity'] ?? 0,
              'price': (item['price_per_unit'] ?? 0).toDouble(),
            });
          }

          // Skip orders with no valid items
          if (itemsJson.isEmpty) {
            continue;
          }

          // Create the order with the items
          final order = Order.fromJson({
            ...orderData,
            'items': itemsJson,
            'farmer_id': farmerId, // Make sure to include the farmer_id
          });

          orders.add(order);
          print('Added order ${order.id} with ${order.items.length} items');
        } catch (e) {
          print('Error processing order $orderId: $e');
          // Continue with next order
          continue;
        }
      }

      print('Returning ${orders.length} orders for farmer');
      return orders;
    } catch (e) {
      print('Error getting farmer orders: $e');
      return [];
    }
  }

  // Ratings

  // Add a rating
  Future<void> addRating(Rating rating) async {
    try {
      await _supabase.from('ratings').insert(rating.toJson());

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
      await _supabase.from('products').update({
        'rating': averageRating,
        'total_ratings': ratings.length,
      }).eq('id', productId);
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
      await _supabase.from('users').update({
        'rating': averageRating,
        'total_ratings': ratings.length,
        'badge_type': averageRating >= 4.6
            ? 'green'
            : (averageRating >= 4.0 ? 'orange' : null),
      }).eq('id', farmerId);
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
  Future<List<Rating>> getRatingsByTarget(
      String targetId, RatingType type) async {
    try {
      final data = await _supabase
          .from('ratings')
          .select('*, users(name, profile_image)')
          .eq('target_id', targetId)
          .eq('type', type.name)
          .order('created_at', ascending: false);

      return data
          .map<Rating>((rating) => Rating.fromJson({
                ...rating,
                'user_name': rating['users']['name'],
                'user_image': rating['users']['profile_image'],
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get target ratings: ${e.toString()}');
    }
  }

  // NGOs and Donations

  // Get all NGOs
  Future<List<NGO>> getAllNGOs() async {
    try {
      final data = await _supabase.from('ngos').select().order('name');

      return data.map<NGO>((ngo) => NGO.fromJson(ngo)).toList();
    } catch (e) {
      throw Exception('Failed to get NGOs: ${e.toString()}');
    }
  }

  // Get NGO by ID
  Future<NGO?> getNGOById(String ngoId) async {
    try {
      final data =
          await _supabase.from('ngos').select().eq('id', ngoId).single();

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
      final uuid = const Uuid().v4();

      // Create a map from the donation and add certificate ID and UUID
      final donationMap = donation.toJson();
      donationMap['id'] = uuid;
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
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomStr =
        (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
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

      return data
          .map<Donation>((donation) => Donation.fromJson({
                ...donation,
                'ngo_name': donation['ngos']['name'],
                'ngo_logo': donation['ngos']['logo_url'],
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user donations: ${e.toString()}');
    }
  }

  // Dashboard statistics

  // Get farmer dashboard statistics
  Future<Map<String, dynamic>> getFarmerDashboardStats(String farmerId) async {
    try {
      final data = await _supabase.rpc('get_farmer_stats', params: {
        'p_farmer_id': farmerId,
      });

      return data;
    } catch (e) {
      throw Exception('Failed to get farmer stats: ${e.toString()}');
    }
  }

  // Get consumer dashboard statistics
  Future<Map<String, dynamic>> getConsumerDashboardStats(
      String consumerId) async {
    try {
      final data = await _supabase.rpc('get_consumer_stats', params: {
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
      final hasUsers = await _supabase.from('users').select('id').limit(1);

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
