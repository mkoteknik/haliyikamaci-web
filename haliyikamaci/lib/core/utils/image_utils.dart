import 'package:flutter/material.dart';

/// Utility functions for safely loading images from various sources
class ImageUtils {
  /// Safely get an ImageProvider from a path string.
  /// 
  /// Returns null for:
  /// - null or empty strings
  /// - Invalid/test data that is neither an asset path nor a valid URL
  /// 
  /// Returns AssetImage for paths starting with 'assets/'
  /// Returns NetworkImage for paths starting with 'http://' or 'https://'
  static ImageProvider? getSafeImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    // Valid asset path
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }
    
    // Valid URL (http or https)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    
    // Invalid value (test data, random strings, etc.) - return null to show fallback
    return null;
  }
}
