import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/mobile_token_service.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../../data/repositories/system_settings_repository.dart';
import '../support/support_chat_screen.dart';

/// Firm SMS Tab - View balance and purchase packages (Google Policy Compliant)
class FirmSmsTab extends ConsumerStatefulWidget {
  const FirmSmsTab({super.key});

  @override
  ConsumerState<FirmSmsTab> createState() => _FirmSmsTabState();
}

class _FirmSmsTabState extends ConsumerState<FirmSmsTab> {

  @override
  Widget build(BuildContext context) {
    final firmAsync = ref.watch(currentFirmProvider);
    final packagesAsync = ref.watch(smsPackagesProvider);

    return firmAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (firm) {
        final displayFirm = firm ?? FirmModel(
          id: 'demo', uid: 'demo', name: 'Demo Firma', phone: '',
          address: AddressModel(city: '', district: '', area: '', neighborhood: '', fullAddress: ''),
          createdAt: DateTime.now(), smsBalance: 100,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance Card
              Card(
                color: AppTheme.primaryBlue,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(FontAwesomeIcons.coins, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mevcut Bakiyeniz', style: TextStyle(color: Colors.white70)),
                          Text(
                            '${displayFirm.smsBalance} KRD',
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),


              // Packages Header
              const Text('KRD Paketleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Packages List (No prices, no buy buttons on mobile)
              packagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _buildMockPackages(context),
                data: (packages) {
                  if (packages.isEmpty) return _buildMockPackages(context);
                  return Column(
                    children: packages.map((pkg) => _buildPackageCard(
                      context: context,
                      name: pkg.name,
                      smsCount: pkg.smsCount,
                      price: pkg.price,
                    )).toList(),
                  );
                },
              ),

              // ========================================
              // SINGLE GREEN WEB BUTTON (MOBILE ONLY)
              // ========================================
              if (!kIsWeb) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWebInterface(context),
                    icon: const Icon(Icons.language, color: Colors.white),
                    label: const Text('Web Arayüzü', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],

              // ========================================
              // HOW TO PURCHASE INFO (MOBILE ONLY)
              // ========================================
              if (!kIsWeb) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'KRD Nasıl Alınır?',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildHowToStep('1', 'Web tarayıcınızdan haliyikamacibul.com adresine gidin'),
                        _buildHowToStep('2', 'Firma panelinize giriş yapın'),
                        _buildHowToStep('3', 'KRD Paketleri sayfasından istediğiniz paketi seçin'),
                        _buildHowToStep('4', 'Havale/EFT veya Kredi Kartı ile ödeme yapın'),
                        const SizedBox(height: 16),
                        // Support Button - Opens WhatsApp with admin number
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _contactSupport(context),
                            icon: const Icon(Icons.support_agent),
                            label: const Text('Canlı Destek'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Open Web Interface with One-Time Token Auto-Login
  Future<void> _openWebInterface(BuildContext context) async {
    // 1. Get current firm UID
    final firm = ref.read(currentFirmProvider).value;
    if (firm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firma bilgileri yüklenemedi')),
      );
      return;
    }

    // 2. Get dynamic URL from settings
    String baseUrl;
    try {
      final settings = await ref.read(systemSettingsProvider.future);
      baseUrl = settings.firmPanelUrl;
      if (baseUrl.isEmpty) {
        baseUrl = 'https://haliyikamacibul.com/firm'; // Fallback
      }
    } catch (e) {
      baseUrl = 'https://haliyikamacibul.com/firm'; // Fallback on error
    }

    // 3. Generate one-time token with HMAC-SHA256 signature
    // Not: baseUrl zaten krd.php'yi içeriyorsa page eklemeye gerek yok
    final token = MobileTokenService.generateToken(uid: firm.uid);
    
    // URL'in sonunda .php varsa direkt token ekle, yoksa krd.php ekle
    String finalUrl;
    if (baseUrl.endsWith('.php')) {
      finalUrl = '$baseUrl?mobile_token=$token';
    } else {
      // baseUrl sonundaki / kaldır
      final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      finalUrl = '$cleanUrl/krd.php?mobile_token=$token';
    }

    // Open in external browser (Google Policy: must be external, not WebView!)
    final uri = Uri.parse(finalUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link açılamadı')),
        );
      }
    }
  }

  /// Contact Support - Opens admin support chat (same as firm profile)
  void _contactSupport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SupportChatScreen(
          isCustomerToFirm: false,
          firmName: 'Yönetici Desteği',
        ),
      ),
    );
  }

  Widget _buildMockPackages(BuildContext context) {
    return Column(
      children: [
        _buildPackageCard(context: context, name: 'Başlangıç Paketi', smsCount: 100, price: 150),
        _buildPackageCard(context: context, name: 'Standart Paket', smsCount: 250, price: 350, isPopular: true),
        _buildPackageCard(context: context, name: 'Profesyonel Paket', smsCount: 500, price: 650),
        _buildPackageCard(context: context, name: 'Kurumsal Paket', smsCount: 1000, price: 1200),
      ],
    );
  }

  Widget _buildHowToStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.blue.shade700, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildUsageRow(IconData icon, String title, String cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(cost, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required BuildContext context,
    required String name,
    required int smsCount,
    required double price,
    bool isPopular = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('$smsCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentGreen)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('$smsCount KRD', style: const TextStyle(color: AppTheme.mediumGray)),
                    ],
                  ),
                ),
                // WEB: Show price and purchase button
                // MOBILE: Show nothing (no price, no button)
                if (kIsWeb)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₺${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                      const SizedBox(height: 4),
                      Text('KRD başına ₺${(price / smsCount).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppTheme.mediumGray)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _purchasePackage(context, name, smsCount),
                        child: const Text('Satın Al'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 0, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.accentOrange,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                ),
                child: const Text('En Popüler', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  void _purchasePackage(BuildContext context, String name, int smsCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paket Satın Al'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$name paketi satın almak üzeresiniz.'),
            const SizedBox(height: 8),
            Text('$smsCount KRD bakiyenize eklenecektir.', style: const TextStyle(color: AppTheme.mediumGray)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$smsCount KRD bakiyenize eklendi!')));
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}
