import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Service for interacting with Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile photo
  Future<String?> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId/profile.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('[StorageService] Error uploading profile photo: $e');
      return null;
    }
  }

  /// Upload portfolio image
  Future<String?> uploadPortfolioImage({
    required String userId,
    required String portfolioId,
    required File imageFile,
  }) async {
    try {
      final ref = _storage.ref().child(
        'portfolio_images/$userId/$portfolioId/image.jpg',
      );
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('[StorageService] Error uploading portfolio image: $e');
      return null;
    }
  }

  /// Delete profile photo
  Future<bool> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId/profile.jpg');
      await ref.delete();
      return true;
    } catch (e) {
      print('[StorageService] Error deleting profile photo: $e');
      return false;
    }
  }

  /// Delete portfolio image
  Future<bool> deletePortfolioImage({
    required String userId,
    required String portfolioId,
  }) async {
    try {
      final ref = _storage.ref().child(
        'portfolio_images/$userId/$portfolioId/image.jpg',
      );
      await ref.delete();
      return true;
    } catch (e) {
      print('[StorageService] Error deleting portfolio image: $e');
      return false;
    }
  }
}

/// Helper class for image picking
class ImagePickerHelper {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('[ImagePickerHelper] Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('[ImagePickerHelper] Error picking image from camera: $e');
      return null;
    }
  }

  /// Show image source selection dialog and return selected image
  Future<File?> pickImage(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.gallery) {
      return await pickImageFromGallery();
    } else {
      return await pickImageFromCamera();
    }
  }
}
