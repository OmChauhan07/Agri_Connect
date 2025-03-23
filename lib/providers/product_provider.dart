import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  List<Product> _allProducts = [];
  List<Product> _farmerProducts = [];
  List<Product> _featuredProducts = [];
  List<UserModel> _featuredFarmers = [];
  bool _isLoading = false;

  List<Product> get allProducts => _allProducts;
  List<Product> get farmerProducts => _farmerProducts;
  List<Product> get featuredProducts => _featuredProducts;
  List<UserModel> get featuredFarmers => _featuredFarmers;
  bool get isLoading => _isLoading;

  // Fetch All Products
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allProducts = await _databaseService.getAllProducts();
    } catch (e) {
      debugPrint('Error fetching products: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Farmer Products
  Future<void> fetchFarmerProducts(String farmerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _farmerProducts = await _databaseService.getProductsByFarmerId(farmerId);
    } catch (e) {
      debugPrint('Error fetching farmer products: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Featured Products
  Future<void> fetchFeaturedProducts() async {
    try {
      _featuredProducts = await _databaseService.getFeaturedProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching featured products: ${e.toString()}');
    }
  }

  // Fetch Featured Farmers
  Future<void> fetchFeaturedFarmers() async {
    try {
      _featuredFarmers = await _authService.getFeaturedFarmers();
      // Sort by rating (highest first)
      _featuredFarmers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching featured farmers: ${e.toString()}');
    }
  }

  // Add Product
  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.addProduct(product);
      _farmerProducts.add(product);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Product
  Future<void> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateProduct(product);

      // Update in local lists
      final farmerIndex = _farmerProducts.indexWhere((p) => p.id == product.id);
      if (farmerIndex != -1) {
        _farmerProducts[farmerIndex] = product;
      }

      final allIndex = _allProducts.indexWhere((p) => p.id == product.id);
      if (allIndex != -1) {
        _allProducts[allIndex] = product;
      }

      final featuredIndex =
          _featuredProducts.indexWhere((p) => p.id == product.id);
      if (featuredIndex != -1) {
        _featuredProducts[featuredIndex] = product;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Product
  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteProduct(productId);

      // Remove from local lists
      _farmerProducts.removeWhere((p) => p.id == productId);
      _allProducts.removeWhere((p) => p.id == productId);
      _featuredProducts.removeWhere((p) => p.id == productId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Product By ID
  Future<Product?> getProductById(String productId) async {
    try {
      return await _databaseService.getProductById(productId);
    } catch (e) {
      debugPrint('Error getting product: ${e.toString()}');
      return null;
    }
  }

  // Get Farmer By ID
  Future<UserModel?> getFarmerById(String farmerId) async {
    try {
      return await _authService.getUserById(farmerId);
    } catch (e) {
      debugPrint('Error getting farmer: ${e.toString()}');
      return null;
    }
  }

  // Upload Product Images
  Future<List<String>> uploadProductImages(List<XFile> images) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _storageService.uploadProductImages(images);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search Products
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (_allProducts.isEmpty) {
        await fetchAllProducts();
      }

      if (query.isEmpty) {
        return _allProducts;
      }

      final lowercaseQuery = query.toLowerCase();
      return _allProducts.where((product) {
        return product.name.toLowerCase().contains(lowercaseQuery) ||
            product.description.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching products: ${e.toString()}');
      return [];
    }
  }
}
