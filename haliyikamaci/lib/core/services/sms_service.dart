import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'secure_config_service.dart';

class SmsService {
  late final FirebaseFirestore _firestore;
  
  SmsService() {
    _firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'haliyikamacimmbldatabase',
    );
  }

  /// Check if a relationship exists between firm and customer
  /// Returns true if there's an order history between them
  Future<bool> checkRelationship({
    required String firmId,
    required String phoneNumber,
  }) async {
    try {
      // Clean phone number for comparison
      String cleanPhone = _cleanPhoneNumber(phoneNumber);
      
      // Check if there's any order between this firm and customer phone
      final query = await _firestore
          .collection('orders')
          .where('firmId', isEqualTo: firmId)
          .where('customerPhone', isEqualTo: cleanPhone)
          .limit(1)
          .get();

      final hasRelationship = query.docs.isNotEmpty;
      
      if (!hasRelationship) {
        debugPrint('SMS BLOCKED: No relationship found between firm $firmId and phone $cleanPhone');
      }
      
      return hasRelationship;
    } catch (e) {
      debugPrint('Relationship Check Error: $e');
      // On error, be cautious and block
      return false;
    }
  }

  /// Secure SMS - Only sends if relationship exists
  Future<bool> sendSecureSms({
    required String firmId,
    required String phoneNumber,
    required String message,
  }) async {
    // 1. Check relationship first
    final hasRelationship = await checkRelationship(
      firmId: firmId,
      phoneNumber: phoneNumber,
    );

    if (!hasRelationship) {
      debugPrint('SMS REJECTED: No relationship between firm and customer');
      return false;
    }

    // 2. Send SMS if relationship exists
    return await sendSms(phoneNumber: phoneNumber, message: message);
  }

  /// Clean phone number to standard format
  String _cleanPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('90') && cleanPhone.length > 10) {
      cleanPhone = cleanPhone.substring(2);
    } else if (cleanPhone.startsWith('0') && cleanPhone.length > 10) {
      cleanPhone = cleanPhone.substring(1);
    }
    return cleanPhone;
  }

  /// Sends a Single SMS via Tapsin GET API
  Future<bool> sendSms({required String phoneNumber, required String message}) async {
    try {
      // 1. Clean Phone Number (Remove +90 or leading 0 if needed)
      // Tapsin usually likes 532xxxxxxx (10 digits)
      String cleanPhone = _cleanPhoneNumber(phoneNumber);
      
      // Ensure 10 digits
      if (cleanPhone.length != 10) {
        debugPrint('SMS ERROR: Invalid phone number length: $cleanPhone');
        return false;
      }

      // 2. Construct URL
      // https://tapsin.tr/gonder.php?user=...&pass=...&mesaj=...&numara=...&origin=...
      final secureConfig = SecureConfigService();
      
      // Check if credentials are available
      if (!secureConfig.hasCredentials) {
        debugPrint('SMS ERROR: API credentials not loaded from Remote Config');
        return false;
      }
      
      final uri = Uri.parse(secureConfig.tapsinUrl).replace(queryParameters: {
        'user': secureConfig.tapsinUser,
        'pass': secureConfig.tapsinPass,
        'mesaj': message,
        'numara': cleanPhone,
        'origin': secureConfig.tapsinOrigin,
      });

      debugPrint('SMS Sending to $cleanPhone: $message');
      
      // 3. Send Request
      final response = await http.get(uri);

      debugPrint('Tapsin Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        // Tapsin returns "01", "02" etc on error, or an ID on success (numeric usually)
        final body = response.body.trim();
        
        // Known Error Codes
        if (['01', '02', '10', '20'].contains(body)) {
          debugPrint('SMS Failed with Error Code: $body');
          return false;
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('SMS Service Exception: $e');
      return false;
    }
  }
}
