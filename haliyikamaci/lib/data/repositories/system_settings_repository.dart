import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// System Settings Model
class SystemSettings {
  final String firmPanelUrl;
  final AdMobSettings admob;
  final List<String> blockedWords;

  const SystemSettings({
    this.firmPanelUrl = '',
    this.admob = const AdMobSettings(),
    this.blockedWords = const [],
  });

  factory SystemSettings.fromMap(Map<String, dynamic> map) {
    return SystemSettings(
      firmPanelUrl: map['firmPanelUrl'] as String? ?? '',
      admob: AdMobSettings.fromMap(map['admob'] as Map<String, dynamic>? ?? {}),
      blockedWords: List<String>.from(map['blockedWords'] as List? ?? []),
    );
  }
}

class AdMobSettings {
  final String appId;
  final String bannerUnitId;
  final bool isTestMode;

  const AdMobSettings({
    this.appId = '',
    this.bannerUnitId = '',
    this.isTestMode = true,
  });

  factory AdMobSettings.fromMap(Map<String, dynamic> map) {
    return AdMobSettings(
      appId: map['appId'] as String? ?? '',
      bannerUnitId: map['bannerUnitId'] as String? ?? '',
      isTestMode: map['isTestMode'] as bool? ?? true,
    );
  }
}

/// System Settings Repository
class SystemSettingsRepository {
  final FirebaseFirestore _firestore;

  SystemSettingsRepository(this._firestore);

  /// Get system settings from Firestore
  Future<SystemSettings> getSettings() async {
    try {
      final doc = await _firestore
          .collection('system_settings')
          .doc('config')
          .get();

      if (doc.exists && doc.data() != null) {
        return SystemSettings.fromMap(doc.data()!);
      }
      return const SystemSettings();
    } catch (e) {
      return const SystemSettings();
    }
  }

  /// Stream system settings for real-time updates
  Stream<SystemSettings> watchSettings() {
    return _firestore
        .collection('system_settings')
        .doc('config')
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return SystemSettings.fromMap(doc.data()!);
      }
      return const SystemSettings();
    });
  }
}

/// Provider for System Settings Repository
final systemSettingsRepositoryProvider = Provider<SystemSettingsRepository>((ref) {
  final firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );
  return SystemSettingsRepository(firestore);
});

/// Provider for System Settings (async)
final systemSettingsProvider = FutureProvider<SystemSettings>((ref) async {
  final repo = ref.watch(systemSettingsRepositoryProvider);
  return repo.getSettings();
});

/// Provider for Firm Panel URL (convenience)
final firmPanelUrlProvider = FutureProvider<String>((ref) async {
  final settings = await ref.watch(systemSettingsProvider.future);
  return settings.firmPanelUrl;
});
