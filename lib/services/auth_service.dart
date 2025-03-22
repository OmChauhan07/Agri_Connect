import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/user.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get the current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;
  
  // Sign Up
  Future<void> signUp(String email, String password, String name, String phone, UserRole role) async {
    try {
      // Create user in Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Failed to create user');
      }
      
      // Create user profile in the database
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
        'phone_number': phone,
        'role': role == UserRole.farmer ? 'farmer' : 'consumer',
        'created_at': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }
  
  // Sign In
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Invalid credentials');
      }
      
      // Get user profile from database
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();
      
      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
  
  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
  
  // Get User
  Future<UserModel?> getUser() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;
      
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }
  
  // Get User by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }
  
  // Update User Profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
  
  // Upload Profile Image
  Future<String> uploadProfileImage(XFile image) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      
      final fileExt = image.path.split('.').last;
      final fileName = 'profile_$userId.$fileExt';
      final filePath = 'profiles/$fileName';
      
      // Upload the file
      await _supabase
          .storage
          .from('users')
          .upload(
            filePath,
            File(image.path),
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      
      // Get the public URL
      final imageUrl = _supabase
          .storage
          .from('users')
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }
  
  // Get Featured Farmers
  Future<List<UserModel>> getFeaturedFarmers() async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('role', 'farmer')
          .order('rating', ascending: false)
          .limit(5);
      
      return data.map<UserModel>((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to get featured farmers: ${e.toString()}');
    }
  }
}
