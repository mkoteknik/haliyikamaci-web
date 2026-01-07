import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/sms_service.dart';
import 'accounting_repository.dart';

export 'legal_documents_repository.dart';
export 'support_repository.dart';
export 'chat_repository.dart'; // [NEW] Chat Repository
export 'system_settings_repository.dart'; // [NEW] System Settings
export 'accounting_repository.dart'; // [NEW] Accounting Repository

/// Auth Repository - Firebase Authentication operations
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  /// Verify phone number - Sends OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(PhoneAuthCredential credential) onAutoVerify,
    required Function(FirebaseAuthException e) onError,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onAutoVerify,
      verificationFailed: onError,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Sign in with OTP code
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Check if user exists and get type
  Future<UserModel?> getUserByUid(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  /// Check if phone is registered
  Future<UserModel?> getUserByPhone(String phone) async {
    final query = await _firestore
        .collection(AppConstants.usersCollection)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return UserModel.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  /// Create user record
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  /// Sign Out
  Future<void> signOut() async {
    // Only clear OTP bypass (verification time), NOT the OTP code limit
    // So 12-hour SMS limit still applies after logout
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_otp_verification_time');
    
    // Note: Removed terminate() and clearPersistence() as it was causing
    // Firestore connection issues on subsequent logins
    
    await _auth.signOut();
  }

  /// Change user password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturumu bulunamadı');
    }

    // Re-authenticate with current password first
    final email = user.email;
    if (email == null) {
      throw Exception('Email adresi bulunamadı');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mevcut şifre yanlış');
      } else if (e.code == 'weak-password') {
        throw Exception('Yeni şifre çok zayıf');
      } else {
        throw Exception('Şifre değiştirme hatası: ${e.message}');
      }
    }
  }

  /// Delete user account completely
  /// This deletes:
  /// 1. User document from users collection
  /// 2. Customer/Firm document from respective collection
  /// 3. Firebase Auth account
  Future<void> deleteAccount({
    required String uid,
    required String userType,
  }) async {
    try {
      // 1. Delete user document from users collection
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .delete();

      // 2. Delete from customer or firm collection based on type
      if (userType == 'customer') {
        // Find and delete customer document
        final customerQuery = await _firestore
            .collection(AppConstants.customersCollection)
            .where('uid', isEqualTo: uid)
            .get();
        
        for (final doc in customerQuery.docs) {
          await doc.reference.delete();
        }
      } else if (userType == 'firm') {
        // Find and delete firm document
        final firmQuery = await _firestore
            .collection(AppConstants.firmsCollection)
            .where('uid', isEqualTo: uid)
            .get();
        
        for (final doc in firmQuery.docs) {
          // Optionally: Delete or anonymize related data (orders, reviews, etc.)
          // For now, just delete the firm document
          await doc.reference.delete();
        }
      }

      // 3. Delete Firebase Auth account
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.delete();
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  /// Sign in with Phone and Password
  Future<UserCredential> signInWithPassword(String phone, String password) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final email = '$cleanPhone@haliyikamaci.app';
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Register with Phone and Password
  Future<UserCredential> registerWithPassword(String phone, String password) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final email = '$cleanPhone@haliyikamaci.app';
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Check if Google user exists and get email
  Future<UserModel?> getUserByEmail(String email) async {
    final query = await _firestore
        .collection(AppConstants.usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return UserModel.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  // ==================== PASSWORD RESET METHODS ====================

  /// Generate 6-digit OTP code
  String _generateOtp() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Request password reset - sends OTP via SMS
  /// Returns: {success: bool, message: String}
  Future<Map<String, dynamic>> requestPasswordReset(String phone) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      
      // 1. Check if user exists
      final user = await getUserByPhone(cleanPhone);
      if (user == null) {
        return {'success': false, 'message': 'Bu numara ile kayıtlı hesap bulunamadı.'};
      }

      // 2. Check rate limiting
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      final existingDoc = await _firestore
          .collection('password_reset_requests')
          .doc(cleanPhone)
          .get();

      if (existingDoc.exists) {
        final data = existingDoc.data()!;
        final lastRequest = (data['createdAt'] as Timestamp?)?.toDate();
        final dailyResetDate = data['dailyResetDate'] as String?;
        final dailyCount = data['dailyCount'] as int? ?? 0;

        // Check 20-minute limit
        if (lastRequest != null && now.difference(lastRequest).inMinutes < 20) {
          final remaining = 20 - now.difference(lastRequest).inMinutes;
          return {'success': false, 'message': 'Çok sık deneme. $remaining dakika sonra tekrar deneyin.'};
        }

        // Check daily limit (5 per day)
        if (dailyResetDate == todayStr && dailyCount >= 5) {
          return {'success': false, 'message': 'Günlük limit aşıldı. Yarın tekrar deneyin.'};
        }
      }

      // 3. Generate OTP
      final otp = _generateOtp();
      final expiresAt = now.add(const Duration(minutes: 10));

      // 4. Save to Firestore
      final dailyCount = existingDoc.exists && 
          existingDoc.data()?['dailyResetDate'] == todayStr
          ? (existingDoc.data()?['dailyCount'] as int? ?? 0) + 1
          : 1;

      await _firestore.collection('password_reset_requests').doc(cleanPhone).set({
        'phone': cleanPhone,
        'otp': otp,
        'createdAt': Timestamp.now(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'verified': false,
        'attempts': 0,
        'dailyCount': dailyCount,
        'dailyResetDate': todayStr,
      });

      // 5. Send SMS
      final smsService = SmsService();
      final message = 'Halı Yıkamacı - Şifre sıfırlama kodunuz: $otp\nBu kod 10 dakika geçerlidir.';
      final smsSent = await smsService.sendSms(phoneNumber: cleanPhone, message: message);

      if (!smsSent) {
        return {'success': false, 'message': 'SMS gönderilemedi. Lütfen tekrar deneyin.'};
      }

      return {'success': true, 'message': 'Doğrulama kodu telefonunuza gönderildi.'};
    } catch (e) {
      debugPrint('Password Reset Request Error: $e');
      return {'success': false, 'message': 'Bir hata oluştu. Lütfen tekrar deneyin.'};
    }
  }

  /// Verify OTP code for password reset
  /// Returns: {success: bool, message: String}
  Future<Map<String, dynamic>> verifyPasswordResetOtp(String phone, String otp) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      
      final doc = await _firestore
          .collection('password_reset_requests')
          .doc(cleanPhone)
          .get();

      if (!doc.exists) {
        return {'success': false, 'message': 'Şifre sıfırlama isteği bulunamadı.'};
      }

      final data = doc.data()!;
      final storedOtp = data['otp'] as String?;
      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
      final verified = data['verified'] as bool? ?? false;
      final attempts = data['attempts'] as int? ?? 0;

      // Already verified
      if (verified) {
        return {'success': true, 'message': 'Kod zaten doğrulandı.'};
      }

      // Max 3 wrong attempts
      if (attempts >= 3) {
        return {'success': false, 'message': 'Çok fazla yanlış deneme. Yeniden kod isteyin.'};
      }

      // Check expiration
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        return {'success': false, 'message': 'Kodun süresi dolmuş. Yeniden kod isteyin.'};
      }

      // Verify OTP
      if (storedOtp != otp) {
        await _firestore.collection('password_reset_requests').doc(cleanPhone).update({
          'attempts': FieldValue.increment(1),
        });
        return {'success': false, 'message': 'Yanlış kod. ${2 - attempts} deneme hakkınız kaldı.'};
      }

      // Mark as verified
      await _firestore.collection('password_reset_requests').doc(cleanPhone).update({
        'verified': true,
      });

      return {'success': true, 'message': 'Kod doğrulandı.'};
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      return {'success': false, 'message': 'Bir hata oluştu.'};
    }
  }

  /// Reset password after OTP verification
  /// Returns: {success: bool, message: String}
  Future<Map<String, dynamic>> resetPasswordWithOtp(String phone, String newPassword) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      
      // Call PHP backend API to update password using Firebase Admin SDK
      final url = Uri.parse('https://www.haliyikamacibul.com/api/update-password.php');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': cleanPhone,
          'newPassword': newPassword,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Bilinmeyen hata',
        };
      } else {
        debugPrint('Password update API error: ${response.statusCode}');
        return {'success': false, 'message': 'Sunucu hatası. Lütfen tekrar deneyin.'};
      }
    } catch (e) {
      debugPrint('Reset Password Error: $e');
      return {'success': false, 'message': 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.'};
    }
  }
}

/// Firm Repository
class FirmRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Create firm
  Future<String> createFirm(FirmModel firm) async {
    final doc = await _firestore
        .collection(AppConstants.firmsCollection)
        .add(firm.toMap());
    return doc.id;
  }

  /// Get firm by UID
  Future<FirmModel?> getFirmByUid(String uid) async {
    final query = await _firestore
        .collection(AppConstants.firmsCollection)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return FirmModel.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  /// Get firm by ID
  Future<FirmModel?> getFirmById(String id) async {
    final doc = await _firestore
        .collection(AppConstants.firmsCollection)
        .doc(id)
        .get();
    
    if (doc.exists) {
      return FirmModel.fromMap(doc.data()!, id);
    }
    return null;
  }

  /// Get firm by Phone (for unique check)
  Future<FirmModel?> getFirmByPhone(String phone) async {
    final query = await _firestore
        .collection(AppConstants.firmsCollection)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return FirmModel.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  /// Update firm
  Future<void> updateFirm(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.firmsCollection)
        .doc(id)
        .update(data);
  }

  /// Get all approved firms
  Stream<List<FirmModel>> getApprovedFirms() {
    return _firestore
        .collection(AppConstants.firmsCollection)
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirmModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get firms by city/district
  Stream<List<FirmModel>> getFirmsByLocation(String city, String district) {
    return _firestore
        .collection(AppConstants.firmsCollection)
        .where('isApproved', isEqualTo: true)
        .where('address.city', isEqualTo: city)
        .where('address.district', isEqualTo: district)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirmModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Deduct SMS balance
  Future<bool> deductSmsBalance(String firmId, int amount) async {
    final firm = await getFirmById(firmId);
    if (firm == null || firm.smsBalance < amount) {
      return false;
    }
    
    await updateFirm(firmId, {
      'smsBalance': FieldValue.increment(-amount),
    });
    return true;
  }

  /// Add SMS balance
  Future<void> addSmsBalance(String firmId, int amount) async {
    await updateFirm(firmId, {
      'smsBalance': FieldValue.increment(amount),
    });
  }

  /// Add review for firm
  Future<String> addReview(ReviewModel review) async {
    final doc = await _firestore
        .collection('reviews')
        .add(review.toMap());
    return doc.id;
  }

  /// Update firm rating based on all reviews
  Future<void> updateFirmRating(String firmId) async {
    final reviewsSnapshot = await _firestore
        .collection('reviews')
        .where('firmId', isEqualTo: firmId)
        .where('isVisible', isEqualTo: true)
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    int totalRating = 0;
    for (final doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] as int?) ?? 5;
    }

    final avgRating = totalRating / reviewsSnapshot.docs.length;
    
    await updateFirm(firmId, {
      'rating': avgRating,
      'reviewCount': reviewsSnapshot.docs.length,
    });
  }

  /// Get reviews for firm (limited for initial load)
  Stream<List<ReviewModel>> getFirmReviews(String firmId, {int limit = 10}) {
    return _firestore
        .collection('reviews')
        .where('firmId', isEqualTo: firmId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get paginated reviews for firm (for "Load More" functionality)
  Future<List<ReviewModel>> getMoreFirmReviews(String firmId, {required DateTime lastCreatedAt, int limit = 10}) async {
    final query = await _firestore
        .collection('reviews')
        .where('firmId', isEqualTo: firmId)
        .where('isVisible', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(lastCreatedAt)])
        .limit(limit)
        .get();
    
    return query.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Get total review count for firm
  Future<int> getFirmReviewCount(String firmId) async {
    final query = await _firestore
        .collection('reviews')
        .where('firmId', isEqualTo: firmId)
        .where('isVisible', isEqualTo: true)
        .count()
        .get();
    return query.count ?? 0;
  }

  /// Get reviews by customer (for "Değerlendirmelerim" section)
  Stream<List<ReviewModel>> getCustomerReviews(String customerId) {
    return _firestore
        .collection('reviews')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Update a review
  Future<void> updateReview(String reviewId, Map<String, dynamic> data) async {
    await _firestore.collection('reviews').doc(reviewId).update(data);
    
    // Recalculate firm rating if rating changed
    if (data.containsKey('rating')) {
      final doc = await _firestore.collection('reviews').doc(reviewId).get();
      if (doc.exists) {
        final firmId = doc.data()?['firmId'] as String?;
        if (firmId != null) {
          await _recalculateFirmRating(firmId);
        }
      }
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    // Get firmId before deleting
    final doc = await _firestore.collection('reviews').doc(reviewId).get();
    final firmId = doc.data()?['firmId'] as String?;
    
    await _firestore.collection('reviews').doc(reviewId).delete();
    
    // Recalculate firm rating after deletion
    if (firmId != null) {
      await _recalculateFirmRating(firmId);
    }
  }

  /// Recalculate firm rating after review update/delete
  Future<void> _recalculateFirmRating(String firmId) async {
    final reviewsSnapshot = await _firestore
        .collection('reviews')
        .where('firmId', isEqualTo: firmId)
        .where('isVisible', isEqualTo: true)
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      await updateFirm(firmId, {'rating': 0.0, 'reviewCount': 0});
      return;
    }

    double totalRating = 0;
    for (final doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] ?? 0).toDouble();
    }
    final avgRating = totalRating / reviewsSnapshot.docs.length;

    await updateFirm(firmId, {
      'rating': avgRating,
      'reviewCount': reviewsSnapshot.docs.length,
    });
  }

  /// Check if customer has already reviewed an order
  Future<bool> hasCustomerReviewedOrder(String orderId) async {
    final query = await _firestore
        .collection('reviews')
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Add firm reply to a review
  Future<void> addReplyToReview(String reviewId, String reply) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'firmReply': reply,
      'firmReplyAt': Timestamp.now(),
    });
  }

  /// Remove firm reply from a review
  Future<void> removeReplyFromReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).update({
      'firmReply': FieldValue.delete(),
      'firmReplyAt': FieldValue.delete(),
    });
  }
}

/// Customer Repository
class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Create customer
  Future<String> createCustomer(CustomerModel customer) async {
    final doc = await _firestore
        .collection(AppConstants.customersCollection)
        .add(customer.toMap());
    return doc.id;
  }

  /// Get customer by UID
  Future<CustomerModel?> getCustomerByUid(String uid) async {
    final query = await _firestore
        .collection(AppConstants.customersCollection)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get(const GetOptions(source: Source.server));
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return CustomerModel.fromMap(doc.data(), doc.id);
    }
    return null;
  }

  /// Update customer
  Future<void> updateCustomer(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.customersCollection)
        .doc(id)
        .update(data);
  }

  /// Update customer profile (name, surname)
  Future<void> updateProfile(String id, {required String name, required String surname}) async {
    await updateCustomer(id, {
      'name': name,
      'surname': surname,
    });
  }

  /// Add loyalty points to customer (firm-specific)
  Future<void> addLoyaltyPoints(String customerId, String firmId, int points) async {
    await _firestore
        .collection(AppConstants.customersCollection)
        .doc(customerId)
        .update({
          'loyaltyPoints': FieldValue.increment(points),
          'firmLoyaltyPoints.$firmId': FieldValue.increment(points)
        });
  }

  /// Deduct loyalty points (firm-specific)
  Future<bool> deductLoyaltyPoints(String customerId, String firmId, int points) async {
    final doc = await _firestore
        .collection(AppConstants.customersCollection)
        .doc(customerId)
        .get();
    
    if (doc.exists) {
      final firmPoints = (doc.data()?['firmLoyaltyPoints'] as Map<String, dynamic>?)?[firmId] ?? 0;
      if (firmPoints >= points) {
        await _firestore
            .collection(AppConstants.customersCollection)
            .doc(customerId)
            .update({
              'loyaltyPoints': FieldValue.increment(-points),
              'firmLoyaltyPoints.$firmId': FieldValue.increment(-points)
            });
        return true;
      }
    }
    return false;
  }

  /// Add new address to customer (using Read-Modify-Write to avoid arrayUnion limitations)
  Future<void> addAddress(String customerId, AddressModel address) async {
    debugPrint('CustomerRepository: adding address for $customerId');
    final docRef = _firestore.collection(AppConstants.customersCollection).doc(customerId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        // Use List.from to ensure mutable copy
        List<dynamic> currentAddresses = List.from(data['addresses'] ?? []);
        
        // Add new address to list
        currentAddresses.add(address.toMap());
        
        transaction.update(docRef, {'addresses': currentAddresses});
        debugPrint('CustomerRepository: address added. New count: ${currentAddresses.length}');
      }
    });
  }

  /// Remove address by index
  Future<void> deleteAddress(String customerId, int index) async {
    debugPrint('CustomerRepository: deleting address at index $index for $customerId');
    final docRef = _firestore.collection(AppConstants.customersCollection).doc(customerId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        final data = snapshot.data()!;
        List<dynamic> currentAddresses = List.from(data['addresses'] ?? []);
        
        if (index >= 0 && index < currentAddresses.length) {
          currentAddresses.removeAt(index);
          transaction.update(docRef, {'addresses': currentAddresses});
          debugPrint('CustomerRepository: address deleted. New count: ${currentAddresses.length}');
        } else {
             debugPrint('CustomerRepository: invalid index $index. Length: ${currentAddresses.length}');
        }
      }
    });
  }

  // Deprecated: removeAddress(AddressModel) - Keeping for ABI compatibility if needed but safer to remove/replace usage
  // Future<void> removeAddress(String customerId, AddressModel address) ...

  /// Update entire address list (used for editing addresses)
  Future<void> updateAddressList(String customerId, List<AddressModel> addresses) async {
    await _firestore
        .collection(AppConstants.customersCollection)
        .doc(customerId)
        .update({
          'addresses': addresses.map((a) => a.toMap()).toList()
        });
  }

  /// Set selected address index
  Future<void> setSelectedAddress(String customerId, int index) async {
    await _firestore
        .collection(AppConstants.customersCollection)
        .doc(customerId)
        .update({'selectedAddressIndex': index});
  }

  /// Toggle favorite firm for customer
  Future<void> toggleFavoriteFirm(String customerId, String firmId, bool isAdd) async {
    await _firestore
        .collection(AppConstants.customersCollection)
        .doc(customerId)
        .update({
      'favoriteFirmIds': isAdd 
          ? FieldValue.arrayUnion([firmId]) 
          : FieldValue.arrayRemove([firmId])
    });
  }
}

/// Services Repository (Admin defined services)
class ServicesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Get all active services
  Stream<List<ServiceModel>> getActiveServices() {
    return _firestore
        .collection(AppConstants.servicesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get ALL services (for admin)
  Stream<List<ServiceModel>> getAllServices() {
    return _firestore
        .collection(AppConstants.servicesCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create new service
  Future<String> createService(ServiceModel service) async {
    final doc = await _firestore
        .collection(AppConstants.servicesCollection)
        .add(service.toMap());
    return doc.id;
  }

  /// Update service
  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.servicesCollection)
        .doc(id)
        .update(data);
  }

  /// Delete service
  Future<void> deleteService(String id) async {
    await _firestore
        .collection(AppConstants.servicesCollection)
        .doc(id)
        .delete();
  }

  /// Toggle service active status
  Future<void> toggleServiceActive(String id, bool isActive) async {
    await updateService(id, {'isActive': isActive});
  }
}

/// Vitrin Repository
class VitrinRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Create vitrin
  /// [packagePrice] Eğer paket satın alınarak oluşturuluyorsa, gider kaydı için ücret
  Future<String> createVitrin(VitrinModel vitrin, {double? packagePrice}) async {
    final doc = await _firestore
        .collection(AppConstants.vitrinsCollection)
        .add(vitrin.toMap());
    
    // Muhasebe: Otomatik Gider Kaydı (paket fiyatı varsa)
    if (packagePrice != null && packagePrice > 0) {
      try {
        final accountingRepo = AccountingRepository();
        final hasEntry = await accountingRepo.hasVitrinEntry(doc.id);
        if (!hasEntry) {
          await accountingRepo.createVitrinExpenseEntry(
            firmId: vitrin.firmId,
            vitrinId: doc.id,
            amount: packagePrice,
            vitrinName: vitrin.title ?? 'Vitrin Paketi',
          );
        }
      } catch (e) {
        // Muhasebe hatası vitrin oluşturmayı engellemez
        debugPrint('⚠️ Vitrin muhasebe kaydı oluşturulamadı: $e');
      }
    }
    
    return doc.id;
  }

  /// Get firm's vitrins
  Stream<List<VitrinModel>> getFirmVitrins(String firmId) {
    return _firestore
        .collection(AppConstants.vitrinsCollection)
        .where('firmId', isEqualTo: firmId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VitrinModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get active vitrins for feed
  /// Get active vitrins for feed
  Stream<List<VitrinModel>> getActiveVitrins({String? city}) {
    final now = Timestamp.now();
    Query query = _firestore
        .collection(AppConstants.vitrinsCollection)
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: now);
        
    if (city != null && city.isNotEmpty) {
      query = query.where('firmCity', isEqualTo: city);
    }
        
    return query
        .orderBy('endDate')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VitrinModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}

/// Campaign Repository
class CampaignRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Create campaign
  /// [packagePrice] Eğer paket satın alınarak oluşturuluyorsa, gider kaydı için ücret
  Future<String> createCampaign(CampaignModel campaign, {double? packagePrice}) async {
    final doc = await _firestore
        .collection(AppConstants.campaignsCollection)
        .add(campaign.toMap());
    
    // Muhasebe: Otomatik Gider Kaydı (paket fiyatı varsa)
    if (packagePrice != null && packagePrice > 0) {
      try {
        final accountingRepo = AccountingRepository();
        final hasCampaignEntry = await accountingRepo.hasCampaignEntry(doc.id);
        if (!hasCampaignEntry) {
          await accountingRepo.createCampaignExpenseEntry(
            firmId: campaign.firmId,
            campaignId: doc.id,
            amount: packagePrice,
            campaignName: campaign.title ?? 'Kampanya Paketi',
          );
        }
      } catch (e) {
        // Muhasebe hatası kampanya oluşturmayı engellemez
        debugPrint('⚠️ Kampanya muhasebe kaydı oluşturulamadı: $e');
      }
    }
    
    return doc.id;
  }

  /// Get firm's campaigns
  Stream<List<CampaignModel>> getFirmCampaigns(String firmId) {
    return _firestore
        .collection(AppConstants.campaignsCollection)
        .where('firmId', isEqualTo: firmId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CampaignModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get active campaigns
  Stream<List<CampaignModel>> getActiveCampaigns({String? city}) {
    final now = Timestamp.now();
    Query query = _firestore
        .collection(AppConstants.campaignsCollection)
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: now);

    if (city != null && city.isNotEmpty) {
      query = query.where('firmCity', isEqualTo: city);
    }

    return query
        .orderBy('endDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CampaignModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}

/// SMS Packages Repository
class SmsPackagesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Get active SMS packages (for firms)
  Stream<List<SmsPackageModel>> getActivePackages() {
    return _firestore
        .collection(AppConstants.smsPackagesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SmsPackageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get ALL SMS packages (for admin)
  Stream<List<SmsPackageModel>> getAllPackages() {
    return _firestore
        .collection(AppConstants.smsPackagesCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SmsPackageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create new SMS package
  Future<String> createPackage(SmsPackageModel package) async {
    final doc = await _firestore
        .collection(AppConstants.smsPackagesCollection)
        .add(package.toMap());
    return doc.id;
  }

  /// Update SMS package
  Future<void> updatePackage(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.smsPackagesCollection)
        .doc(id)
        .update(data);
  }

  /// Delete SMS package
  Future<void> deletePackage(String id) async {
    await _firestore
        .collection(AppConstants.smsPackagesCollection)
        .doc(id)
        .delete();
  }

  /// Toggle package active status
  Future<void> togglePackageActive(String id, bool isActive) async {
    await updatePackage(id, {'isActive': isActive});
  }
}

/// Vitrin Packages Repository (Admin tanımlı paketler)
class VitrinPackagesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Get active vitrin packages (for firms)
  Stream<List<VitrinPackageModel>> getActivePackages() {
    return _firestore
        .collection(AppConstants.vitrinPackagesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VitrinPackageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get ALL vitrin packages (for admin)
  Stream<List<VitrinPackageModel>> getAllPackages() {
    return _firestore
        .collection(AppConstants.vitrinPackagesCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VitrinPackageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create new vitrin package
  Future<String> createPackage(VitrinPackageModel package) async {
    final doc = await _firestore
        .collection(AppConstants.vitrinPackagesCollection)
        .add(package.toMap());
    return doc.id;
  }

  /// Update vitrin package
  Future<void> updatePackage(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.vitrinPackagesCollection)
        .doc(id)
        .update(data);
  }

  /// Delete vitrin package
  Future<void> deletePackage(String id) async {
    await _firestore
        .collection(AppConstants.vitrinPackagesCollection)
        .doc(id)
        .delete();
  }

  /// Toggle package active status
  Future<void> togglePackageActive(String id, bool isActive) async {
    await updatePackage(id, {'isActive': isActive});
  }
}

/// Campaign Packages Repository (Admin tanımlı paketler)
class CampaignPackagesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');

  /// Get active campaign packages (for firms)
  Stream<List<CampaignPackageModel>> getActivePackages() {
    return _firestore
        .collection(AppConstants.campaignPackagesCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CampaignPackageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get ALL campaign packages (for admin)
  Stream<List<CampaignPackageModel>> getAllPackages() {
    return _firestore
        .collection(AppConstants.campaignPackagesCollection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CampaignPackageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create new campaign package
  Future<String> createPackage(CampaignPackageModel package) async {
    final doc = await _firestore
        .collection(AppConstants.campaignPackagesCollection)
        .add(package.toMap());
    return doc.id;
  }

  /// Update campaign package
  Future<void> updatePackage(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.campaignPackagesCollection)
        .doc(id)
        .update(data);
  }

  /// Delete campaign package
  Future<void> deletePackage(String id) async {
    await _firestore
        .collection(AppConstants.campaignPackagesCollection)
        .doc(id)
        .delete();
  }

  /// Toggle package active status
  Future<void> togglePackageActive(String id, bool isActive) async {
    await updatePackage(id, {'isActive': isActive});
  }
}

/// Order Repository - Sipariş CRUD işlemleri
class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');
  final SmsService _smsService = SmsService();

  static const String _collection = 'orders';

  /// Create new order
  Future<String> createOrder(OrderModel order) async {
    final doc = await _firestore
        .collection(_collection)
        .add(order.toMap());
    return doc.id;
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String id) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(id)
        .get();
    
    if (doc.exists) {
      return OrderModel.fromMap(doc.data()!, id);
    }
    return null;
  }

  /// Get orders by firm (excludes soft-deleted orders)
  Stream<List<OrderModel>> getOrdersByFirm(String firmId) {
    return _firestore
        .collection(_collection)
        .where('firmId', isEqualTo: firmId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .where((order) => order.deletedByFirm != true) // Filter out soft-deleted
            .toList());
  }

  /// Get orders by customer (excludes soft-deleted orders)
  Stream<List<OrderModel>> getOrdersByCustomer(String customerId) {
    return _firestore
        .collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .where((order) => order.deletedByCustomer != true) // Filter out soft-deleted
            .toList());
  }

  /// Update order
  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .update(data);
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    final Map<String, dynamic> data = {'status': status};
    
    // Add timestamp based on status
    switch (status) {
      case OrderModel.statusConfirmed:
        data['confirmedAt'] = Timestamp.now();
        break;
      case OrderModel.statusPickedUp:
        data['pickedUpAt'] = Timestamp.now();
        break;
      case OrderModel.statusMeasured:
        data['measuredAt'] = Timestamp.now();
        break;
      case OrderModel.statusDelivered:
        data['deliveredAt'] = Timestamp.now();
        break;
    }
    
    await updateOrder(orderId, data);
  }

  /// Update order with measurement data (Returns final price and discount)
  Future<({double finalPrice, double discountAmount})> updateOrderMeasurement({
    required String orderId,
    required List<OrderItemModel> measuredItems,
    required double totalPrice,
  }) async {
    // Check promo code and calculate discount
    final order = await getOrderById(orderId);
    double finalPrice = totalPrice;
    double discountAmount = 0;

    if (order != null && order.promoCode != null) {
      if (order.promoCodeType == 'percent') {
        discountAmount = totalPrice * (order.promoCodeValue! / 100);
      } else {
        // Fixed
        discountAmount = order.promoCodeValue ?? 0;
      }
      // Ensure positive price
      finalPrice = (totalPrice - discountAmount).clamp(0, double.infinity);
    }

    await updateOrder(orderId, {
      'status': OrderModel.statusMeasured,
      'measuredAt': Timestamp.now(),
      'measuredItems': measuredItems.map((i) => i.toMap()).toList(),
      'totalPrice': finalPrice,
      if (discountAmount > 0) 'discountAmount': discountAmount,
    });
    
    return (finalPrice: finalPrice, discountAmount: discountAmount);
  }

  /// Send new order SMS to firm
  Future<bool> sendNewOrderSmsToFirm({
    required String firmPhone,
    required String customerName,
    required String customerAddress,
    required List<OrderItemModel> items,
  }) async {
    final servicesList = items.map((i) => '${i.quantity} Adet ${i.serviceName}').join(', ');
    final message = 'Yeni Siparis! $customerName - $servicesList. Adres: $customerAddress. Haliyikamaci';
    
    return await _smsService.sendSms(
      phoneNumber: firmPhone,
      message: message,
    );
  }

  /// Send measurement notification SMS to customer
  Future<bool> sendMeasurementSmsToCustomer({
    required String customerPhone,
    required String firmName,
    required List<OrderItemModel> measuredItems,
    required double totalPrice,
    double? discountAmount,
  }) async {
    // Compact SMS formatting
    final itemsList = measuredItems.map((i) {
      final value = i.measuredValue ?? i.quantity;
      final total = i.totalPrice?.toStringAsFixed(0) ?? '0';
      
      // 1. Truncate service name to 12 chars
      String name = i.serviceName;
      if (name.length > 12) {
        name = name.substring(0, 12);
      }
      
      // 2. Compact Units
      String unit = i.unit;
      if (unit.toLowerCase() == 'adet') unit = 'Ad';
      if (unit.toLowerCase() == 'takim') unit = 'Tk';
      
      return '$name:$value$unit=${total}t';
    }).join('\n');
    
    String priceText = 'Top:${totalPrice.toStringAsFixed(0)}t';
    if (discountAmount != null && discountAmount > 0) {
      priceText = 'T:${(totalPrice + discountAmount).toStringAsFixed(0)} İnd:-${discountAmount.toStringAsFixed(0)} Net:${totalPrice.toStringAsFixed(0)}t';
    }
    
    final message = '$firmName:\n$itemsList\n$priceText B001';
    
    return await _smsService.sendSms(
      phoneNumber: customerPhone,
      message: message,
    );
  }

  /// Delete order (hard delete - for admin use)
  Future<void> deleteOrder(String id) async {
    await _firestore
        .collection(_collection)
        .doc(id)
        .delete();
  }

  /// Soft delete order for firm (hides from firm's view)
  Future<void> softDeleteOrderForFirm(String orderId) async {
    await _firestore
        .collection(_collection)
        .doc(orderId)
        .update({'deletedByFirm': true});
  }

  /// Soft delete order for customer (hides from customer's view)
  Future<void> softDeleteOrderForCustomer(String orderId) async {
    await _firestore
        .collection(_collection)
        .doc(orderId)
        .update({'deletedByCustomer': true});
  }
}

// =============================================================================
// NOTIFICATION REPOSITORY
// =============================================================================

/// Notification Repository - Bildirim işlemleri
class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );

  static const String _collection = 'notifications';

  /// Get notifications stream for a user
  Stream<List<NotificationModel>> getNotifications({
    required String userId,
    required String userType,
    int limit = 50,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('userType', isEqualTo: userType)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get unread count stream
  Stream<int> getUnreadCount({
    required String userId,
    required String userType,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('userType', isEqualTo: userType)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get unread order message count for a specific order
  /// Uses client-side filtering for orderId and notificationType to avoid composite index requirements
  Stream<int> getUnreadOrderMessageCount({
    required String orderId,
    required String userId,
    required String userType,
  }) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('userType', isEqualTo: userType)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          // Client-side filter for orderId and notificationType to avoid complex index
          return snapshot.docs.where((doc) {
            final data = doc.data();
            return data['orderId'] == orderId && 
                   data['notificationType'] == 'order_message';
          }).length;
        });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection(_collection).doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead({
    required String userId,
    required String userType,
  }) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('userType', isEqualTo: userType)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Create notification for new order (to firm)
  Future<void> notifyFirmNewOrder({
    required String firmId,
    required String customerName,
    required String orderId,
    required String orderSummary,
  }) async {
    await _firestore.collection(_collection).add({
      'userId': firmId,
      'userType': 'firm',
      'type': NotificationModel.typeOrder,
      'title': 'Yeni Sipariş 🎉',
      'body': '$customerName: $orderSummary',
      'data': {'orderId': orderId},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create notification for order status change (to customer)
  Future<void> notifyCustomerOrderStatus({
    required String customerId,
    required String orderId,
    required String status,
    String? firmName,
    double? totalPrice,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'confirmed':
        title = 'Sipariş Onaylandı ✅';
        body = '$firmName siparişinizi onayladı.';
        break;
      case 'picked_up':
        title = 'Teslim Alındı 📦';
        body = 'Ürünleriniz $firmName tarafından teslim alındı.';
        break;
      case 'measured':
        title = 'Ölçüm Tamamlandı 📏';
        body = totalPrice != null
            ? 'Toplam tutar: ₺${totalPrice.toStringAsFixed(0)}'
            : 'Ölçüm yapıldı, fiyat belirlendi.';
        break;
      case 'washing':
        title = 'Yıkama Başladı 🧼';
        body = 'Ürünleriniz yıkanmaya başladı.';
        break;
      case 'drying':
        title = 'Kurutma Aşamasında ☀️';
        body = 'Ürünleriniz kurutuluyor.';
        break;
      case 'ready':
        title = 'Hazır! 🎊';
        body = 'Ürünleriniz teslim için hazır.';
        break;
      case 'out_for_delivery':
        title = 'Dağıtıma Çıktı 🚚';
        body = 'Siparişiniz yola çıktı! Hazır olun.';
        break;
      case 'delivered':
        title = 'Teslim Edildi ✨';
        body = 'Siparişiniz teslim edildi. İyi günlerde kullanın!';
        break;
      default:
        title = 'Sipariş Güncellendi';
        body = 'Siparişinizin durumu güncellendi.';
    }

    await _firestore.collection(_collection).add({
      'userId': customerId,
      'userType': 'customer',
      'type': NotificationModel.typeOrder,
      'title': title,
      'body': body,
      'data': {'orderId': orderId, 'status': status},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create notification for new message
  Future<void> notifyNewMessage({
    required String targetUserId,
    required String targetUserType,
    required String senderName,
    required String ticketId,
  }) async {
    await _firestore.collection(_collection).add({
      'userId': targetUserId,
      'userType': targetUserType,
      'type': NotificationModel.typeMessage,
      'title': 'Yeni Mesaj 💬',
      'body': '$senderName size mesaj gönderdi.',
      'data': {'ticketId': ticketId},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create notification for new order chat message
  Future<void> notifyNewOrderMessage({
    required String targetUserId,
    required String targetUserType, // 'customer' or 'firm'
    required String orderId,
    required String senderName,
  }) async {
    await _firestore.collection(_collection).add({
      'userId': targetUserId,
      'userType': targetUserType,
      'type': NotificationModel.typeMessage,
      'title': 'Yeni Mesaj 💬',
      'body': '$senderName size mesaj gönderdi',
      'orderId': orderId, // Top-level for easy querying
      'notificationType': 'order_message', // Top-level to avoid nested field query
      'data': {'orderId': orderId, 'type': 'order_message'}, // Keep for backward compat
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete old notifications (cleanup)
  Future<void> deleteOldNotifications({
    required String userId,
    required String userType,
    int keepDays = 30,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('userType', isEqualTo: userType)
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Delete specific notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection(_collection).doc(notificationId).delete();
  }

  /// Delete all read notifications
  Future<void> deleteAllReadNotifications({
    required String userId,
    required String userType,
  }) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('userType', isEqualTo: userType)
        .where('isRead', isEqualTo: true)
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
