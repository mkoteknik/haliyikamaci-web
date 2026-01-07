import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../data/providers/ad_settings_provider.dart';

/// Reusable AdMob Banner Widget
/// Displays a banner ad at the bottom of the screen.
/// Fetches the ad unit ID dynamically from Firestore.
class AdBannerWidget extends ConsumerStatefulWidget {
  const AdBannerWidget({super.key});

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load ad when dependencies change (including when provider data is available)
    _loadAd();
  }

  void _loadAd() {
    final adSettingsAsync = ref.read(adSettingsProvider);
    
    adSettingsAsync.whenData((adSettings) {
      if (_bannerAd != null) return; // Already loaded

      _bannerAd = BannerAd(
        adUnitId: adSettings.bannerAdUnitId,
        size: AdSize.banner, // Standard 320x50 banner
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ AdMob Banner loaded successfully');
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ AdMob Banner failed to load: ${error.message}');
            ad.dispose();
            _bannerAd = null;
          },
        ),
      )..load();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes in ad settings
    ref.listen(adSettingsProvider, (previous, next) {
      if (previous?.value?.bannerAdUnitId != next.value?.bannerAdUnitId) {
        // Ad unit ID changed, reload the ad
        _bannerAd?.dispose();
        _bannerAd = null;
        _isAdLoaded = false;
        _loadAd();
      }
    });

    if (!_isAdLoaded || _bannerAd == null) {
      // Return an empty container with the same height to prevent layout jumps
      return const SizedBox(height: 50);
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
