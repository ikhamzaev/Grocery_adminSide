import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../core/supabase_config.dart';

class StorageService {
  static final SupabaseClient _client = SupabaseConfig.client;
  static const String _productImagesBucket = 'product-images';
  static const String _categoryImagesBucket = 'category-images';
  static const _uuid = Uuid();

  /// Upload a single image file to Supabase storage
  static Future<String?> uploadImage({
    required File imageFile,
    required String bucket,
    String? customPath,
  }) async {
    try {
      print('DEBUG: Starting image upload to bucket: $bucket');
      
      // Generate unique filename
      final fileExtension = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$fileExtension';
      final filePath = customPath != null ? '$customPath/$fileName' : fileName;
      
      print('DEBUG: Uploading file: $filePath');
      
      // Read file bytes
      final fileBytes = await imageFile.readAsBytes();
      
      // Upload to Supabase storage
      final response = await _client.storage
          .from(bucket)
          .uploadBinary(filePath, fileBytes);
      
      print('DEBUG: Upload response: $response');
      
      // Get public URL
      final publicUrl = _client.storage
          .from(bucket)
          .getPublicUrl(filePath);
      
      print('DEBUG: Public URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      print('DEBUG: Error uploading image: $e');
      return null;
    }
  }

  /// Upload image bytes directly (for web compatibility)
  static Future<String?> uploadImageBytes({
    required Uint8List imageBytes,
    required String fileName,
    required String bucket,
    String? customPath,
  }) async {
    try {
      print('DEBUG: Starting image upload to bucket: $bucket');
      
      // Generate unique filename
      final fileExtension = path.extension(fileName);
      final uniqueFileName = '${_uuid.v4()}$fileExtension';
      final filePath = customPath != null ? '$customPath/$uniqueFileName' : uniqueFileName;
      
      print('DEBUG: Uploading file: $filePath');
      
      // Upload to Supabase storage
      final response = await _client.storage
          .from(bucket)
          .uploadBinary(filePath, imageBytes);
      
      print('DEBUG: Upload response: $response');
      
      // Get public URL
      final publicUrl = _client.storage
          .from(bucket)
          .getPublicUrl(filePath);
      
      print('DEBUG: Public URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      print('DEBUG: Error uploading image: $e');
      return null;
    }
  }

  /// Upload multiple image files to Supabase storage
  static Future<List<String>> uploadImages({
    required List<File> imageFiles,
    required String bucket,
    String? customPath,
  }) async {
    final uploadedUrls = <String>[];
    
    for (final imageFile in imageFiles) {
      final url = await uploadImage(
        imageFile: imageFile,
        bucket: bucket,
        customPath: customPath,
      );
      
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  /// Upload product images
  static Future<List<String>> uploadProductImages(List<File> imageFiles) async {
    return await uploadImages(
      imageFiles: imageFiles,
      bucket: _productImagesBucket,
      customPath: 'products',
    );
  }

  /// Upload category images
  static Future<List<String>> uploadCategoryImages(List<File> imageFiles) async {
    return await uploadImages(
      imageFiles: imageFiles,
      bucket: _categoryImagesBucket,
      customPath: 'categories',
    );
  }

  /// Delete an image from Supabase storage
  static Future<bool> deleteImage({
    required String imageUrl,
    required String bucket,
  }) async {
    try {
      print('DEBUG: Deleting image: $imageUrl');
      
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the bucket name in the path and get everything after it
      final bucketIndex = pathSegments.indexOf(bucket);
      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        print('DEBUG: Could not extract file path from URL');
        return false;
      }
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      print('DEBUG: File path to delete: $filePath');
      
      // Delete from storage
      await _client.storage.from(bucket).remove([filePath]);
      
      print('DEBUG: Image deleted successfully');
      return true;
    } catch (e) {
      print('DEBUG: Error deleting image: $e');
      return false;
    }
  }

  /// Delete multiple images from Supabase storage
  static Future<List<bool>> deleteImages({
    required List<String> imageUrls,
    required String bucket,
  }) async {
    final results = <bool>[];
    
    for (final imageUrl in imageUrls) {
      final result = await deleteImage(
        imageUrl: imageUrl,
        bucket: bucket,
      );
      results.add(result);
    }
    
    return results;
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    final bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validate image file
  static bool isValidImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    
    return allowedExtensions.contains(extension);
  }

  /// Validate file size (max 10MB)
  static bool isValidFileSize(File file, {double maxSizeMB = 10.0}) {
    return getFileSizeInMB(file) <= maxSizeMB;
  }
}
