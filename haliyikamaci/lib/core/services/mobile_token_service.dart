import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Mobile Token Service - Creates one-time auto-login tokens for web interface
/// Matches the PHP token structure in api/check_token.php
class MobileTokenService {
  // IMPORTANT: This must match the secret key in api/check_token.php
  static const String _secretKey = 'MY_MOBILE_APP_SECRET_KEY_123';

  /// Generate a one-time token for auto-login
  /// Token expires in 60 seconds (checked by PHP side)
  /// 
  /// Parameters:
  /// - [uid]: Firebase user ID
  /// - [packageId]: Optional SMS package ID to auto-select
  /// 
  /// Returns: Base64 encoded token string
  static String generateToken({
    required String uid,
    String? packageId,
  }) {
    // Create data payload
    final data = {
      'uid': uid,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unix timestamp (seconds)
      if (packageId != null) 'package_id': packageId,
    };

    // Encode data to JSON
    final dataJson = jsonEncode(data);

    // Generate HMAC-SHA256 signature
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(dataJson);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    final signature = digest.toString();

    // Create token structure (matches PHP: { data, sig })
    final tokenData = {
      'data': dataJson,
      'sig': signature,
    };

    // Base64 encode the final token
    final tokenJson = jsonEncode(tokenData);
    final token = base64Encode(utf8.encode(tokenJson));

    return token;
  }

  /// Build the full auto-login URL for web interface
  /// 
  /// Parameters:
  /// - [baseUrl]: The firm panel base URL from settings
  /// - [uid]: Firebase user ID
  /// - [page]: Target page (default: 'sms.php')
  /// - [packageId]: Optional package ID to auto-select
  /// 
  /// Returns: Complete URL with token
  static String buildAutoLoginUrl({
    required String baseUrl,
    required String uid,
    String page = 'sms.php',
    String? packageId,
  }) {
    final token = generateToken(uid: uid, packageId: packageId);
    
    // Ensure baseUrl doesn't end with /
    final cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    
    return '$cleanBaseUrl/$page?mobile_token=$token';
  }
}
