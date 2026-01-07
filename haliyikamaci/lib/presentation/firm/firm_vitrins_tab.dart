import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../data/repositories/accounting_repository.dart';

/// Firm Vitrins Tab - Purchase vitrin packages to appear in customer showcase
class FirmVitrinsTab extends ConsumerWidget {
  const FirmVitrinsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firmAsync = ref.watch(currentFirmProvider);
    final packagesAsync = ref.watch(vitrinPackagesProvider);

    return firmAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (firm) {
        // DEV MODE: Use mock firm if null
        final displayFirm = firm ?? _getMockFirm();

        // Handle packages - on error, show empty state
        final List<VitrinPackageModel> packages = packagesAsync.maybeWhen(
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
              // Current Status Card
              _buildStatusCard(displayFirm.id),
              const SizedBox(height: 24),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withAlpha(50)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vitrin paketi satın aldığınızda, firmanız müşteri uygulamasında ana sayfanın en üstünde yuvarlak profil olarak gösterilir.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Available Packages
              const Text(
                'Vitrin Paketleri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              if (packages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined, size: 48, color: AppTheme.mediumGray),
                        SizedBox(height: 8),
                        Text('Henüz vitrin paketi tanımlanmamış'),
                        Text('Admin tarafından eklenecek.', style: TextStyle(color: AppTheme.mediumGray)),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: packages.map((pkg) => _buildPackageCard(context, ref, pkg, displayFirm.smsBalance)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String firmId) {
    return StreamBuilder<QuerySnapshot>(
      // Fetch all vitrins for this firm, filter client-side to avoid composite index requirement
      stream: FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase')
          .collection('firm_vitrin_purchases')
          .where('firmId', isEqualTo: firmId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Vitrin query error: ${snapshot.error}');
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Client-side filter for active vitrins
        final now = DateTime.now();
        final activeDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final endDate = (data['endDate'] as Timestamp?)?.toDate();
          return endDate != null && endDate.isAfter(now);
        }).toList();
        
        // Sort by endDate descending to get the latest
        activeDocs.sort((a, b) {
          final aEnd = ((a.data() as Map<String, dynamic>)['endDate'] as Timestamp).toDate();
          final bEnd = ((b.data() as Map<String, dynamic>)['endDate'] as Timestamp).toDate();
          return bEnd.compareTo(aEnd);
        });
        
        if (activeDocs.isEmpty) {
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
                    child: const Icon(Icons.visibility_off, color: AppTheme.mediumGray),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vitrin Durumu',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Şu anda aktif vitrininiz bulunmuyor',
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

        final data = activeDocs.first.data() as Map<String, dynamic>;
        final packageName = data['packageName'] ?? 'Vitrin Paketi';
        final endDate = (data['endDate'] as Timestamp).toDate();
        final daysLeft = endDate.difference(DateTime.now()).inDays;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront, color: AppTheme.accentGreen),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktif: $packageName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accentGreen),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bitiş: ${endDate.day}.${endDate.month}.${endDate.year} (${daysLeft + 1} gün kaldı)',
                        style: const TextStyle(color: AppTheme.darkGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackageCard(BuildContext context, WidgetRef ref, VitrinPackageModel pkg, int smsBalance) {
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
                color: AppTheme.primaryBlue.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.visibility, color: AppTheme.primaryBlue, size: 28),
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
                      ? () => _confirmPurchase(context, ref, pkg, smsBalance)
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

  Future<void> _confirmPurchase(BuildContext context, WidgetRef ref, VitrinPackageModel pkg, int currentBalance) async {
    // 1. Show processing dialog
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

      // 3. Create or Update Vitrin Item
      final vitrinsRef = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase')
          .collection('firm_vitrin_purchases');
          
      // Check for existing active vitrin
      final existingSnapshot = await vitrinsRef
          .where('firmId', isEqualTo: firm.id)
          .where('endDate', isGreaterThan: Timestamp.now())
          .orderBy('endDate', descending: true)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        // UPDATE EXISTING: Extend duration
        final existingDoc = existingSnapshot.docs.first;
        final currentEndDate = (existingDoc['endDate'] as Timestamp).toDate();
        final newEndDate = currentEndDate.add(Duration(days: pkg.durationDays));
        
        await existingDoc.reference.update({
          'endDate': Timestamp.fromDate(newEndDate),
          'packageName': pkg.name, // Update package name to latest
          'smsCost': FieldValue.increment(pkg.smsCost), // Track total cost? Or just keep latest. Let's keep cost history in accounting, here just update display.
          // Refresh firm details in case they changed
          'firmName': firm.name,
          'firmLogo': firm.logo ?? '',
          'firmCity': firm.address.city,
          'firmDistrict': firm.address.district, 
          'rating': firm.rating,
          'reviewCount': firm.reviewCount,
        });
      } else {
        // CREATE NEW
        final startDate = DateTime.now();
        final endDate = startDate.add(Duration(days: pkg.durationDays));

        await vitrinsRef.add({
          'firmId': firm.id,
          'firmName': firm.name,
          'firmLogo': firm.logo ?? '', // Added Logo
          'firmCity': firm.address.city,
          'firmDistrict': firm.address.district,
          'rating': firm.rating,
          'reviewCount': firm.reviewCount,
          'packageId': pkg.id,
          'packageName': pkg.name,
          'smsCost': pkg.smsCost,
          'days': pkg.durationDays,
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          // Fields mapped for VitrinModel compatibility
          'title': firm.name,
          'description': pkg.name,
          'images': [if (firm.logo != null) firm.logo!],
        });
      }

        // MUHASEBE: Otomatik Gider Kaydı
        try {
          final accountingRepo = AccountingRepository();
          await accountingRepo.createVitrinExpenseEntry(
            firmId: firm.id,
            vitrinId: existingSnapshot.docs.isNotEmpty 
                ? existingSnapshot.docs.first.id 
                : 'vitrin_${DateTime.now().millisecondsSinceEpoch}',
            amount: pkg.smsCost.toDouble(),
            vitrinName: pkg.name,
          );
          debugPrint('✅ Muhasebe: Vitrin gider kaydı oluşturuldu');
        } catch (accError) {
          debugPrint('⚠️ Muhasebe kaydı oluşturulamadı: $accError');
        }

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pkg.name} satın alındı! Vitrinde görünmeye başladınız.'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        
        // Refresh firm data to update balance UI
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
      rating: 4.5,
      reviewCount: 25,
      paymentMethods: [FirmModel.paymentCash],
    );
  }
}
