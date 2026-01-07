import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Secure Config Service - Fetches sensitive API keys from Firebase Remote Config
/// This prevents API keys from being exposed in the APK
class SecureConfigService {
  static final SecureConfigService _instance = SecureConfigService._internal();
  factory SecureConfigService() => _instance;
  SecureConfigService._internal();

  late final FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;

  // Cached values
  String _tapsinUser = '';
  String _tapsinPass = '';
  String _tapsinOrigin = '';
  String _tapsinUrl = '';

  /// Initialize Remote Config
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values (fallback if Remote Config fails)
      await _remoteConfig.setDefaults({
        'tapsin_user': '',
        'tapsin_pass': '',
        'tapsin_origin': 'HALI SEPETI',
        'tapsin_url': 'https://tapsin.tr/gonder.php',
      });

      // Configure settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();

      // Cache values
      _tapsinUser = _remoteConfig.getString('tapsin_user');
      _tapsinPass = _remoteConfig.getString('tapsin_pass');
      _tapsinOrigin = _remoteConfig.getString('tapsin_origin');
      _tapsinUrl = _remoteConfig.getString('tapsin_url');

      _isInitialized = true;
      debugPrint('SecureConfig: Initialized successfully');
      debugPrint('SecureConfig: tapsin_user loaded: ${_tapsinUser.isNotEmpty}');
    } catch (e) {
      debugPrint('SecureConfig Error: $e');
      // Keep using default/empty values on error
    }
  }

  /// Get Tapsin User
  String get tapsinUser => _tapsinUser;

  /// Get Tapsin Password
  String get tapsinPass => _tapsinPass;

  /// Get Tapsin Origin (Sender Name)
  String get tapsinOrigin => _tapsinOrigin.isNotEmpty ? _tapsinOrigin : 'HALI SEPETI';

  /// Get Tapsin API URL
  String get tapsinUrl => _tapsinUrl.isNotEmpty ? _tapsinUrl : 'https://tapsin.tr/gonder.php';

  /// Check if credentials are loaded
  bool get hasCredentials => _tapsinUser.isNotEmpty && _tapsinPass.isNotEmpty;
}
