import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/models.dart';

/// Promo Code Repository - Kampanya kodları CRUD işlemleri
class PromoCodeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );
  
  static const String _collection = 'promoCodes';

  /// Create a new promo code
  Future<String> createPromoCode(PromoCodeModel code) async {
    final doc = await _firestore.collection(_collection).add(code.toMap());
    return doc.id;
  }

  /// Update promo code
  Future<void> updatePromoCode(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update(data);
  }

  /// Delete promo code
  Future<void> deletePromoCode(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  /// Get all admin promo codes (firmId == null)
  Stream<List<PromoCodeModel>> getAdminPromoCodes() {
    return _firestore
        .collection(_collection)
        .where('firmId', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromoCodeModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get firm's promo codes
  Stream<List<PromoCodeModel>> getFirmPromoCodes(String firmId) {
    return _firestore
        .collection(_collection)
        .where('firmId', isEqualTo: firmId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromoCodeModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Validate promo code
  /// 1. First check admin codes (firmId == null)
  /// 2. Then check firm codes (firmId == targetFirmId)
  /// Returns PromoCodeModel if valid, null if invalid
  Future<PromoCodeModel?> validatePromoCode(String code, String targetFirmId) async {
    final codeUpper = code.toUpperCase().trim();
    
    // 1. Check admin codes first
    final adminQuery = await _firestore
        .collection(_collection)
        .where('code', isEqualTo: codeUpper)
        .where('firmId', isNull: true)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (adminQuery.docs.isNotEmpty) {
      final promo = PromoCodeModel.fromMap(
        adminQuery.docs.first.data(),
        adminQuery.docs.first.id,
      );
      if (promo.isValid) return promo;
    }
    
    // 2. Check firm codes
    final firmQuery = await _firestore
        .collection(_collection)
        .where('code', isEqualTo: codeUpper)
        .where('firmId', isEqualTo: targetFirmId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (firmQuery.docs.isNotEmpty) {
      final promo = PromoCodeModel.fromMap(
        firmQuery.docs.first.data(),
        firmQuery.docs.first.id,
      );
      if (promo.isValid) return promo;
    }
    
    return null;
  }

  /// Increment usage count when code is used
  Future<void> usePromoCode(String codeId) async {
    await _firestore.collection(_collection).doc(codeId).update({
      'usageCount': FieldValue.increment(1),
    });
  }

  /// Check if code already exists
  Future<bool> codeExists(String code, {String? excludeId}) async {
    final codeUpper = code.toUpperCase().trim();
    final query = await _firestore
        .collection(_collection)
        .where('code', isEqualTo: codeUpper)
        .get();
    
    if (query.docs.isEmpty) return false;
    
    // If excludeId provided, check if found code is different
    if (excludeId != null) {
      return query.docs.any((doc) => doc.id != excludeId);
    }
    
    return true;
  }
}
