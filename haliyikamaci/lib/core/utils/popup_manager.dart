import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../data/models/popup_ad_model.dart';
import '../../data/repositories/popup_ad_repository.dart';

class PopupManager {
  static Future<void> checkAndShowPopup(BuildContext context, WidgetRef ref, String userType) async {
    final repo = ref.read(popupAdRepositoryProvider);
    
    // 1. Get active candidates
    final ads = await repo.getActiveAds(userType);
    debugPrint('PopupManager: Active ads count for $userType: ${ads.length}');
    
    if (ads.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // 2. Filter locally
    final validAds = <PopupAdModel>[];

    for (var ad in ads) {
      // URL & Content Check - Geçersiz URL'leri tamamen engelle
      final imageUrl = ad.imageUrl.trim();
      if (imageUrl.isEmpty) {
        debugPrint('PopupManager: Skipping ad with empty imageUrl: ${ad.title}');
        continue;
      }

      // localhost/10.0.2.2 görsellerini engelle (hem debug hem release'de)
      if (imageUrl.contains('localhost') || imageUrl.contains('10.0.2.2') || imageUrl.contains('127.0.0.1')) {
        debugPrint('PopupManager: Skipping localhost ad: ${ad.title}');
        continue;
      }

      // Geçerli HTTP/HTTPS URL olmalı
      if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
        debugPrint('PopupManager: Skipping ad with invalid URL scheme: ${ad.title} - $imageUrl');
        continue;
      }

      if (ad.perUserDailyLimit > 0) {
        final dailyKey = 'popup_count_${ad.id}_$today';
        final userViewsToday = prefs.getInt(dailyKey) ?? 0;
        debugPrint('PopupManager: Ad ${ad.title} views today: $userViewsToday (Limit: ${ad.perUserDailyLimit})');
        
        if (userViewsToday >= ad.perUserDailyLimit) continue;
      }
      validAds.add(ad);
    }
    
    debugPrint('PopupManager: Valid ads to show: ${validAds.length}');
    if (validAds.isEmpty) return;

    // 3. Pick one
    final adToShow = validAds.first;

    // 4. Show Dialog
    if (!context.mounted) return;
    debugPrint('PopupManager: Showing dialog for ${adToShow.title}');

    await showDialog(
      context: context,
      barrierDismissible: false, // User must click close or action
      builder: (context) => _PopupDialog(ad: adToShow),
    );

    // 5. After Show (Increment counters)
    // Increment Server
    repo.incrementView(adToShow.id);
    
    // Increment Local
    if (adToShow.perUserDailyLimit > 0) {
       final dailyKey = 'popup_count_${adToShow.id}_$today';
       final current = prefs.getInt(dailyKey) ?? 0;
       await prefs.setInt(dailyKey, current + 1);
    }
  }
}

class _PopupDialog extends StatelessWidget {
  final PopupAdModel ad;

  const _PopupDialog({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Button (Outside or Top Right)
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 24, color: Colors.black),
              ),
            ),
          ),
          
          // Image
          GestureDetector(
            onTap: () {
               if(ad.actionUrl != null && ad.actionUrl!.isNotEmpty) {
                 _launchUrl(ad.actionUrl!);
                 Navigator.pop(context); 
               }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _fixUrl(ad.imageUrl),
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Popup Image Error: $error');
                  return Container(
                    height: 200,
                     width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                        const SizedBox(height: 8),
                        Text('Yüklenemedi\n${_fixUrl(ad.imageUrl)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fixUrl(String url) {
    if (Platform.isAndroid) {
      if (url.contains('localhost')) {
        return url.replaceFirst('localhost', '10.0.2.2');
      }
    }
    return url;
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
