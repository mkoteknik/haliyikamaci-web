import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for Ad Settings from Firestore
class AdSettings {
  final String bannerAdUnitId;
  final bool testMode;

  AdSettings({
    required this.bannerAdUnitId,
    required this.testMode,
  });

  factory AdSettings.fromFirestore(Map<String, dynamic>? data) {
    // Default to Google's test ad unit ID if not set or in test mode
    const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

    if (data == null) {
      return AdSettings(bannerAdUnitId: testBannerAdUnitId, testMode: true);
    }

    final bool testMode = data['testMode'] ?? true;
    final String bannerAdUnitId = testMode 
        ? testBannerAdUnitId 
        : (data['bannerAdUnitId'] ?? testBannerAdUnitId);

    return AdSettings(
      bannerAdUnitId: bannerAdUnitId,
      testMode: testMode,
    );
  }
}

/// Provider to fetch Ad Settings from Firestore
final adSettingsProvider = StreamProvider<AdSettings>((ref) {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );
  return firestore
      .collection('system_settings')
      .doc('ad_settings')
      .snapshots()
      .map((doc) => AdSettings.fromFirestore(doc.data()));
});
