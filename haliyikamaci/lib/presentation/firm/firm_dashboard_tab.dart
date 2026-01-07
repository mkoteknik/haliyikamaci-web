import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import 'firm_reviews_screen.dart';

/// Firm Dashboard Tab
class FirmDashboardTab extends ConsumerWidget {
  final Function(int)? onTabChange;
  
  const FirmDashboardTab({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firmAsync = ref.watch(currentFirmProvider);

    return firmAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (firm) {
        // DEV MODE: Use mock firm if null
        final displayFirm = firm ?? _getMockFirm();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SMS UYARISI
              if (displayFirm.smsBalance <= 5)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kritik Seviye: KRD Bakiyeniz Azaldı!',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sipariş bildirimlerini kaçırmamak için lütfen KRD paketi satın alın.',
                                  style: TextStyle(color: Colors.red[800], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => onTabChange?.call(4), // Go to SMS Tab
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Hemen KRD Yükle'),
                        ),
                      ),
                    ],
                  ),
                ),

              // Hoşgeldin mesajı
              Text(
                'Hoş geldiniz, ${displayFirm.name}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayFirm.address.shortAddress,
                style: const TextStyle(color: AppTheme.mediumGray),
              ),
              const SizedBox(height: 24),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Görüntülenme',
                      value: '1,234',
                      icon: Icons.visibility,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Tıklama',
                      value: '89',
                      icon: Icons.touch_app,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Arama',
                      value: '23',
                      icon: Icons.phone,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to reviews screen
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const _FirmReviewsScreenWrapper(),
                          ),
                        );
                      },
                      child: _buildStatCard(
                        title: 'Değerlendirme',
                        value: displayFirm.rating.toStringAsFixed(1),
                        icon: Icons.star,
                        color: Colors.amber,
                        subtitle: '${displayFirm.reviewCount} yorum',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SMS Durumu
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: displayFirm.smsBalance > 50
                              ? AppTheme.accentGreen.withAlpha(50)
                              : AppTheme.accentRed.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.coins,
                          color: displayFirm.smsBalance > 50
                              ? AppTheme.accentGreen
                              : AppTheme.accentRed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KRD Bakiyeniz',
                              style: TextStyle(color: AppTheme.mediumGray),
                            ),
                            Text(
                              '${displayFirm.smsBalance} KRD',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to SMS tab (index 4)
                          onTabChange?.call(4);
                        },
                        child: const Text('KRD Al'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hızlı İşlemler
              const Text(
                'Hızlı İşlemler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      title: 'Vitrin Ekle',
                      icon: Icons.add_business,
                      color: AppTheme.primaryBlue,
                      onTap: () {
                        // Navigate to Marketing tab (index 2)
                        onTabChange?.call(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      title: 'Kampanya',
                      icon: Icons.local_offer,
                      color: AppTheme.accentGreen,
                      onTap: () {
                        // Navigate to Marketing tab (index 2)
                        onTabChange?.call(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      title: 'Hizmetler',
                      icon: Icons.settings,
                      color: AppTheme.accentOrange,
                      onTap: () {
                        // Navigate to Services tab (index 3)
                        onTabChange?.call(3);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: AppTheme.mediumGray),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(color: color, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FirmModel _getMockFirm() {
    return FirmModel(
      id: 'demo_firm',
      uid: 'demo_uid',
      name: 'Demo Firma',
      phone: '5551234567',
      address: AddressModel(
        city: 'İstanbul',
        district: 'Kadıköy',
        area: '',
        neighborhood: 'Caferağa',
        fullAddress: 'Demo Adres',
      ),
      createdAt: DateTime.now(),
      smsBalance: 100,
      rating: 4.5,
      reviewCount: 25,
      paymentMethods: [FirmModel.paymentCash],
    );
  }
}

/// Wrapper to provide ProviderScope for navigation
class _FirmReviewsScreenWrapper extends StatelessWidget {
  const _FirmReviewsScreenWrapper();

  @override
  Widget build(BuildContext context) {
    return const FirmReviewsScreen();
  }
}
