import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../data/repositories/accounting_repository.dart';

/// Firm Campaigns Tab - Purchase campaign packages and enter campaign details
class FirmCampaignsTab extends ConsumerStatefulWidget {
  const FirmCampaignsTab({super.key});

  @override
  ConsumerState<FirmCampaignsTab> createState() => _FirmCampaignsTabState();
}

class _FirmCampaignsTabState extends ConsumerState<FirmCampaignsTab> {
  @override
  Widget build(BuildContext context) {
    final firmAsync = ref.watch(currentFirmProvider);
    final packagesAsync = ref.watch(campaignPackagesProvider);

    return firmAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (firm) {
        // DEV MODE: Use mock firm if null
        final displayFirm = firm ?? _getMockFirm();

        // Handle packages - on error, show empty state
        final List<CampaignPackageModel> packages = packagesAsync.maybeWhen(
          data: (data) => data,
          orElse: () => [],
        );
        final isLoading = packagesAsync.isLoading;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Campaigns Section
              _buildActiveCampaigns(displayFirm.id),
              const SizedBox(height: 24),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentGreen.withAlpha(50)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.campaign, color: AppTheme.accentGreen),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kampanya paketi satın aldığınızda, kampanya başlığı ve açıklaması girerek müşteri uygulamasında yayınlayabilirsiniz.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Available Packages
              const Text(
                'Kampanya Paketleri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              if (packages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.campaign_outlined, size: 48, color: AppTheme.mediumGray),
                        SizedBox(height: 8),
                        Text('Henüz kampanya paketi tanımlanmamış'),
                        Text('Admin tarafından eklenecek.', style: TextStyle(color: AppTheme.mediumGray)),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: packages.map((pkg) => _buildPackageCard(pkg, displayFirm.smsBalance)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveCampaigns(String firmId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase')
          .collection('campaigns')
          .where('firmId', isEqualTo: firmId)
          .where('endDate', isGreaterThan: Timestamp.now())
          .orderBy('endDate', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.mediumGray.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign_outlined, color: AppTheme.mediumGray),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktif Kampanyalar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Şu anda aktif kampanyanız bulunmuyor',
                          style: TextStyle(color: AppTheme.mediumGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final endDate = (data['endDate'] as Timestamp).toDate();
            final daysLeft = endDate.difference(DateTime.now()).inDays;
            final isActive = data['isActive'] ?? true;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.accentGreen.withAlpha(30) : Colors.grey.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.campaign, color: isActive ? AppTheme.accentGreen : Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['title'] ?? 'Kampanya',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bitiş: ${endDate.day}.${endDate.month}.${endDate.year} (${daysLeft + 1} gün kaldı)',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (!isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Pasif', style: TextStyle(color: Colors.red, fontSize: 12)),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.accentGreen),
                            onPressed: () => _showEditCampaignDialog(context, doc.id, data),
                            tooltip: 'Düzenle',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCampaign(context, doc.id, data['title'] ?? 'Kampanya'),
                            tooltip: 'Sil',
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showEditCampaignDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final titleController = TextEditingController(text: data['title']);
    final descController = TextEditingController(text: data['description']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kampanyayı Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Kampanya Başlığı', hintText: 'Örn: %20 İndirim'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Açıklama', hintText: 'Kampanya detayları...'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || descController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase')
                    .collection('campaigns')
                    .doc(docId)
                    .update({
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kampanya güncellendi', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCampaign(BuildContext context, String docId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kampanyayı Sil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"$title" kampanyasını silmek istediğinize emin misiniz?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withAlpha(100)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Silinen kampanyalarda KRD iadesi yapılmaz.',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Onayla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase')
          .collection('campaigns')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kampanya silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildPackageCard(CampaignPackageModel pkg, int smsBalance) {
    final canAfford = smsBalance >= pkg.smsCost;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Package Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.campaign, color: AppTheme.accentGreen, size: 28),
            ),
            const SizedBox(width: 16),
            
            // Package Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pkg.description,
                    style: const TextStyle(color: AppTheme.mediumGray, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${pkg.durationDays} gün',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Price & Buy Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.coins, size: 14, color: AppTheme.accentGreen),
                    const SizedBox(width: 4),
                    Text(
                      '${pkg.smsCost} KRD',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: canAfford
                      ? () => _showCampaignDetailsForm(pkg, smsBalance)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? AppTheme.primaryBlue : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: Text(canAfford ? 'Satın Al' : 'Yetersiz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCampaignDetailsForm(CampaignPackageModel pkg, int currentBalance) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final discountController = TextEditingController(); // New controller for discount

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${pkg.name} Oluştur',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // Cost Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.coins, color: AppTheme.accentOrange, size: 20),
                    const SizedBox(width: 8),
                    Text('${pkg.smsCost} KRD düşülecek (Bakiye: $currentBalance KRD)'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Campaign Title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Kampanya Başlığı',
                  hintText: 'Örn: Yaz Fırsatı, 3 Al 2 Öde',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Discount Percentage (Optional)
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'İndirim Oranı (%) (Opsiyonel)',
                  hintText: 'Sadece indirimliyse girin (Örn: 20)',
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                  helperText: 'Boş bırakırsanız "Fırsat" olarak görünür.',
                ),
              ),
              const SizedBox(height: 16),
              
              // Campaign Description
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Kampanya Koşulları ve Detayları',
                  hintText: 'Müşterileriniz için kampanya detaylarını açıklayın.\nÖrn:\n- 12m² üzeri halılarda geçerlidir.\n- 30 Haziran\'a kadar geçerlidir.',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lütfen başlık girin')),
                            );
                            return;
                          }
                          
                          // Parse discount
                          final discount = int.tryParse(discountController.text.trim()) ?? 0;

                          // 1. Show Loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(child: CircularProgressIndicator()),
                          );

                          try {
                            final firmRepo = ref.read(firmRepositoryProvider);
                            final firm = await ref.read(currentFirmProvider.future);
                            
                            if (firm == null) throw Exception('Firma oturumu bulunamadı');

                            // 2. Deduct Balance
                            final success = await firmRepo.deductSmsBalance(firm.id, pkg.smsCost);
                            
                            if (!success) {
                              if (context.mounted) Navigator.pop(context); // Close loading
                              throw Exception('Bakiye yetersiz veya işlem başarısız');
                            }

                            // 3. Create Campaign
                            final startDate = DateTime.now();
                            final endDate = startDate.add(Duration(days: pkg.durationDays));

                            final campaignDoc = await FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase')
                                .collection('campaigns')
                                .add({
                              'firmId': firm.id,
                              'firmName': firm.name,
                              'firmLogo': firm.logo ?? '',
                              'firmCity': firm.address.city,
                              'firmDistrict': firm.address.district,
                              'packageId': pkg.id,
                              'packageName': pkg.name,
                              'title': titleController.text.trim(),
                              'description': descriptionController.text.trim(),
                              'discount': discount,
                              'smsCost': pkg.smsCost,
                              'days': pkg.durationDays,
                              'startDate': Timestamp.fromDate(startDate),
                              'endDate': Timestamp.fromDate(endDate),
                              'isActive': true,
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            // MUHASEBE: Otomatik Gider Kaydı
                            try {
                              final accountingRepo = AccountingRepository();
                              await accountingRepo.createCampaignExpenseEntry(
                                firmId: firm.id,
                                campaignId: campaignDoc.id,
                                amount: pkg.smsCost.toDouble(),
                                campaignName: titleController.text.trim(),
                              );
                              debugPrint('✅ Muhasebe: Kampanya gider kaydı oluşturuldu');
                            } catch (accError) {
                              debugPrint('⚠️ Muhasebe kaydı oluşturulamadı: $accError');
                            }

                            if (context.mounted) {
                              Navigator.pop(context); // Close loading
                              Navigator.pop(ctx); // Close BottomSheet
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kampanya "${titleController.text}" yayınlandı!'),
                                  backgroundColor: AppTheme.accentGreen,
                                ),
                              );
                              
                              ref.invalidate(currentFirmProvider);
                            }

                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Close loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Hata: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Yayınla'),
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // DEV MODE: Mock firm for testing
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
      taxNumber: '1234567890', 
      rating: 4.5,
      reviewCount: 25,
      paymentMethods: [FirmModel.paymentCash],
    );
  }
}
