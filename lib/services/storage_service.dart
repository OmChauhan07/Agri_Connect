import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Upload product images
  Future<List<String>> uploadProductImages(List<XFile> images) async {
    try {
      List<String> imageUrls = [];
      
      for (var image in images) {
        final uuid = const Uuid().v4();
        final fileExt = image.path.split('.').last;
        final fileName = 'product_$uuid.$fileExt';
        final filePath = 'products/$fileName';
        
        // Upload the file
        await _supabase
            .storage
            .from('products')
            .upload(
              filePath,
              File(image.path),
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );
        
        // Get the public URL
        final imageUrl = _supabase
            .storage
            .from('products')
            .getPublicUrl(filePath);
        
        imageUrls.add(imageUrl);
      }
      
      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }
  
  // Delete a product image
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // The file path format is typically: /storage/v1/object/public/bucket/path
      // We need the path after the bucket name
      final bucketIndex = pathSegments.indexOf('products');
      if (bucketIndex >= 0 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        
        await _supabase
            .storage
            .from('products')
            .remove([filePath]);
      } else {
        throw Exception('Invalid image URL format');
      }
    } catch (e) {
      throw Exception('Failed to delete image: ${e.toString()}');
    }
  }
  
  // Upload profile image (single image)
  Future<String> uploadProfileImage(XFile image, String userId) async {
    try {
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
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }
}
