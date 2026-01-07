import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../widgets/campaign_card.dart';
import '../widgets/ad_banner_widget.dart';

class CustomerCampaignsTab extends ConsumerWidget {
  const CustomerCampaignsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(currentCustomerProvider);
    final firmsAsync = ref.watch(approvedFirmsProvider);
    
    // Get customer's city for filtering
    final customerCity = customerAsync.when(
      data: (customer) => customer?.address.city,
      loading: () => null,
      error: (_, __) => null,
    );
    
    final campaignsAsync = ref.watch(activeCampaignsProvider(customerCity));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kampanyalar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: campaignsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aktif kampanya bulunamadı', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return firmsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
            data: (firms) {
              return CustomScrollView(
                slivers: [
                   SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16, 
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final campaign = campaigns[index];
                          final firm = firms.firstWhere(
                            (f) => f.id == campaign.firmId,
                            orElse: () => FirmModel(
                              id: 'unknown', uid: 'unknown', name: 'Bilinmiyor', phone: '', 
                              address: AddressModel(city: '', district: '', area: '', neighborhood: '', fullAddress: ''), 
                              createdAt: DateTime.now(), smsBalance: 0, rating: 0, reviewCount: 0, paymentMethods: []
                            ),
                          );
                          
                          if (firm.id == 'unknown') return const SizedBox();

                          return CampaignCard(campaign: campaign, firm: firm, index: index);
                        },
                        childCount: campaigns.length,
                      ),
                    ),
                  ),

                  // Ad Banner
                  const SliverToBoxAdapter(child: AdBannerWidget()),

                  // Bottom Spacer
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
