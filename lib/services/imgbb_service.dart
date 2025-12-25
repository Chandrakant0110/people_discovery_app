import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:people_discovery_app/config/imgbb_config.dart';

/// Service for uploading images to ImgBB API
/// 
/// This service handles image uploads using the ImgBB API.
/// API Documentation: https://api.imgbb.com/
class ImgBBService {
  String get _apiKey => ImgBBConfig.apiKey;
  String get _uploadEndpoint => ImgBBConfig.uploadEndpoint;

  /// Upload image to ImgBB
  /// 
  /// [imageFile] - The image file to upload
  /// [name] - Optional name for the file
  /// 
  /// Returns the image URL if successful, null otherwise
  Future<String?> uploadImage({
    required File imageFile,
    String? name,
  }) async {
    try {
      // Read image file and convert to base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Validate API key
      if (_apiKey == 'YOUR_IMGBB_API_KEY' || _apiKey.isEmpty) {
        throw Exception(
          'ImgBB API key not configured. Please update lib/config/imgbb_config.dart with your API key.',
        );
      }

      // Prepare request parameters
      final uri = Uri.parse(_uploadEndpoint);
      final requestBody = <String, String>{
        'key': _apiKey,
        'image': base64Image,
      };

      if (name != null && name.isNotEmpty) {
        requestBody['name'] = name;
      }

      // Make POST request
      final response = await http.post(
        uri,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Return the image URL
          final imageUrl = jsonResponse['data']['url'] as String?;
          if (imageUrl != null) {
            print('[ImgBBService] Image uploaded successfully: $imageUrl');
            return imageUrl;
          }
        }
        
        // Handle API error response
        final errorMessage = jsonResponse['error']?['message'] ?? 'Unknown error';
        print('[ImgBBService] API error: $errorMessage');
        return null;
      } else {
        print('[ImgBBService] HTTP error: ${response.statusCode}');
        print('[ImgBBService] Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[ImgBBService] Error uploading image: $e');
      return null;
    }
  }

  /// Upload profile photo
  /// 
  /// Convenience method for uploading profile photos
  Future<String?> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    return uploadImage(
      imageFile: imageFile,
      name: 'profile_$userId',
    );
  }

  /// Upload portfolio image
  /// 
  /// Convenience method for uploading portfolio images
  Future<String?> uploadPortfolioImage({
    required String userId,
    required String portfolioId,
    required File imageFile,
  }) async {
    return uploadImage(
      imageFile: imageFile,
      name: 'portfolio_${userId}_$portfolioId',
    );
  }
}

