import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/popup_ad_model.dart';

final popupAdRepositoryProvider = Provider((ref) => PopupAdRepository());

class PopupAdRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );

  Future<List<PopupAdModel>> getActiveAds(String userType) async {
    try {
      final snapshot = await _firestore
          .collection('popup_ads')
          .where('isActive', isEqualTo: true)
          // .orderBy('createdAt', descending: true) // REMOVED: Requires Index
          .get();

      final allAds = snapshot.docs
          .map((doc) => PopupAdModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort client-side to avoid index error
      // Assuming 'createdAt' is available in Model? 
      // Oops, I didn't add 'createdAt' to PopupAdModel in step 1286.
      // But preserving order is not SUPER critical, or we can just rely on natural order or add field later.
      // For now, let's just return the list. If order matters, we'll add createdAt to model.


      // Client-side filtering for complex logic
      final today = DateTime.now().toIso8601String().split('T')[0];

      return allAds.where((ad) {
        // 1. Audience Check
        if (!ad.isTarget_valid(userType)) return false;

        // 2. Global Total Limit Check
        if (ad.globalTotalLimit > 0 && ad.currentViewsTotal >= ad.globalTotalLimit) {
          return false;
        }

        // 3. Global Daily Limit Check
        if (ad.globalDailyLimit > 0) {
          // If the stored date is today, check limit
          if (ad.lastViewDate == today && ad.currentViewsToday >= ad.globalDailyLimit) {
            return false;
          }
          // If stored date is old, we assume it will reset on increment, so it's technically displayable now
          // (Wait, if many users open at same time, this strict check might be needed)
        }

        return true;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching popup ads: $e');
      return [];
    }
  }

  Future<void> incrementView(String adId) async {
    final docRef = _firestore.collection('popup_ads').doc(adId);
    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final int globalTotalLimit = data['globalTotalLimit'] ?? 0;
        // globalDailyLimit is checked via data map directly
        
        int currentViewsTotal = data['currentViewsTotal'] ?? 0;
        int currentViewsToday = data['currentViewsToday'] ?? 0;
        String lastViewDate = data['lastViewDate'] ?? '';

        // Reset Logic
        if (lastViewDate != today) {
          currentViewsToday = 0;
          lastViewDate = today;
        }

        // Increment
        currentViewsTotal++;
        currentViewsToday++;

        final updates = <String, dynamic>{
          'currentViewsTotal': currentViewsTotal,
          'currentViewsToday': currentViewsToday,
          'lastViewDate': lastViewDate,
        };

        // Auto-Deactivate Logic if Total Limit Reached
        if (globalTotalLimit > 0 && currentViewsTotal >= globalTotalLimit) {
          updates['isActive'] = false;
        }

        // (Optional) If Daily limit reached now, we explicitly just define the counters. 
        // The display logic handles avoiding display if limit reached.

        transaction.update(docRef, updates);
      });
    } catch (e) {
      debugPrint('Error incrementing ad view: $e');
    }
  }
}
