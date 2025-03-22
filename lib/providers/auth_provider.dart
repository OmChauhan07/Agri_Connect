import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Initialize
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUser();
    } catch (e) {
      debugPrint('Error initializing auth: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Up
  Future<void> signup(String email, String password, String name, String phone,
      UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(email, password, name, phone, role);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signIn(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First clear the current user
      _currentUser = null;

      // Then sign out from Supabase
      await _authService.signOut();

      // Additional cleanup can be added here if needed
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: ${e.toString()}');
      // Even if there's an error, we still want to clear the user data
      _currentUser = null;
      rethrow; // Rethrow to let the UI handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update User Profile
  Future<void> updateUserProfile(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUserProfile(user);
      _currentUser = user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload Profile Image
  Future<String> uploadProfileImage(XFile image) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      final imageUrl =
          await _storageService.uploadProfileImage(image, _currentUser!.id);
      return imageUrl;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Featured Farmers
  Future<List<UserModel>> getFeaturedFarmers() async {
    try {
      return await _authService.getFeaturedFarmers();
    } catch (e) {
      debugPrint('Error getting featured farmers: ${e.toString()}');
      return [];
    }
  }

  // Get User by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _authService.getUserById(userId);
    } catch (e) {
      debugPrint('Error getting user: ${e.toString()}');
      return null;
    }
  }
}
