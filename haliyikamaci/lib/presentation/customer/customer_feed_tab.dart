import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/theme/customer_theme.dart';
import '../../core/utils/image_utils.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/campaign_card.dart';
import '../widgets/firm_card_widget.dart';
import 'customer_notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Customer Feed Tab - Home page with Vitrin circles, Campaigns, and Nearby Firms
class CustomerFeedTab extends ConsumerWidget {
  final Function(int)? onTabChange;
  
  const CustomerFeedTab({super.key, this.onTabChange});

  // Gradient Colors
  static const Color _purpleStart = Color(0xFFE040FB);
  static const Color _purpleEnd = Color(0xFF7C4DFF);

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
    
    final vitrinsAsync = ref.watch(activeVitrinsProvider(customerCity));
    final campaignsAsync = ref.watch(activeCampaignsProvider(customerCity));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Purple Gradient Header with Search
          SliverAppBar(
            expandedHeight: 260, // Increased from 220 to prevent overlap
            floating: false,
            pinned: true,
            backgroundColor: _purpleEnd,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_purpleStart, _purpleEnd],
                ),
              ),
              child: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -30,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 60,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              customerAsync.when(
                                data: (customer) {
                                  if (customer == null) return const SizedBox();
                                  return GestureDetector(
                                    onTap: () => _showAddressSelectionSheet(context, ref, customer),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(50),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            customer.address.title.isNotEmpty
                                                ? '${customer.address.title} - ${customer.address.district}'
                                                : (customer.address.district.isNotEmpty 
                                                    ? '${customer.address.district}, ${customer.address.city}'
                                                    : 'Adres Seçin'),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                loading: () => Container(
                                  width: 100, height: 30,
                                  decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(20)),
                                ),
                                error: (_, __) => const SizedBox(),
                              ),
                              const Spacer(),
                              _buildNotificationButton(context, ref),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Tertemiz Halılar,\nMutlu Evler ✨',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GestureDetector(
                  onTap: () {
                    if (onTabChange != null) onTabChange!(2);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.purple),
                        const SizedBox(width: 12),
                        Text('Firma adı veya hizmet ara...', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Vitrin Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vitrindekiler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () { if (onTabChange != null) onTabChange!(2); },
                    child: Text(AppLocalizations.of(context)!.seeAll),
                  ),
                ],
              ),
            ),
          ),

          // 3. Vitrin Circles (Firms)
          vitrinsAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            data: (vitrins) {
              if (vitrins.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vitrins.length,
                    itemBuilder: (context, index) {
                      final vitrin = vitrins[index];
                      
                      return GestureDetector(
                        onTap: () {
                          // approvedFirmsProvider'dan tam firmayı bul
                          final allFirms = ref.read(approvedFirmsProvider).valueOrNull ?? [];
                          final fullFirm = allFirms.firstWhere(
                            (f) => f.id == vitrin.firmId,
                            orElse: () => FirmModel(
                              id: vitrin.firmId,
                              uid: '',
                              name: vitrin.firmName.isNotEmpty ? vitrin.firmName : vitrin.title,
                              logo: vitrin.firmLogo,
                              phone: '',
                              address: AddressModel(city: vitrin.firmCity, district: vitrin.firmDistrict, area: '', neighborhood: '', fullAddress: ''),
                              createdAt: DateTime.now(),
                            ),
                          );
                          _showFirmDetail(context, fullFirm);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.purple.withAlpha(100), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.purple.withAlpha(10),
                                  backgroundImage: ImageUtils.getSafeImageProvider(vitrin.firmLogo),
                                  child: ImageUtils.getSafeImageProvider(vitrin.firmLogo) == null ? const Icon(Icons.store, color: Colors.purple) : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 70,
                                child: Text(vitrin.firmName.isNotEmpty ? vitrin.firmName : vitrin.title, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // 4. Campaigns Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kampanyalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () { if (onTabChange != null) onTabChange!(1); },
                    child: Text(AppLocalizations.of(context)!.seeAll),
                  ),
                ],
              ),
            ),
          ),

          // 5. Campaigns List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: campaignsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
                data: (campaigns) {
                  if (campaigns.isEmpty) return _buildMockCampaignCards(context, ref);
                  return firmsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => const SizedBox(),
                    data: (firms) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: campaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = campaigns[index];
                          final firm = firms.firstWhere(
                            (f) => f.id == campaign.firmId,
                            orElse: () => FirmModel(
                              id: 'unknown', uid: 'unknown', name: 'Bilinmiyor', phone: '',
                              address: AddressModel(city: '', district: '', area: '', neighborhood: '', fullAddress: ''),
                              createdAt: DateTime.now(), smsBalance: 0, rating: 0, reviewCount: 0, paymentMethods: [],
                            ),
                          );
                          if (firm.id == 'unknown') return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 140,
                              child: CampaignCard(campaign: campaign, firm: firm, index: index),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // 6. Nearby Firms Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Yakındaki Firmalar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () { if (onTabChange != null) onTabChange!(2); },
                    child: Text(AppLocalizations.of(context)!.seeAll),
                  ),
                ],
              ),
            ),
          ),

          // 7. Nearby Firms List with Distance
          _buildNearbyFirmsList(context, ref, firmsAsync),

          // Bottom Padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
    );
  }

  // ==================== NEARBY FIRMS LIST WITH CITY-BASED MATCHING ====================
  Widget _buildNearbyFirmsList(BuildContext context, WidgetRef ref, AsyncValue<List<FirmModel>> firmsAsync) {
    return FutureBuilder<String?>(
      future: _getUserCity(),
      builder: (context, citySnapshot) {
        if (citySnapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
          );
        }

        final userCity = citySnapshot.data;

        return firmsAsync.when(
          loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))),
          error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Hata: $e'))),
          data: (firms) {
            List<FirmModel> displayFirms;
            if (userCity != null && userCity.isNotEmpty) {
              displayFirms = firms.where((f) => f.address.city.toLowerCase() == userCity.toLowerCase()).take(10).toList();
            } else {
              displayFirms = firms.take(10).toList();
            }

            if (displayFirms.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text(userCity != null ? '$userCity bölgesinde firma bulunamadı.' : 'Yakında firma bulunamadı.', style: const TextStyle(color: Colors.grey))),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final firm = displayFirms[index];
                  return Consumer(
                    builder: (context, ref, _) {
                      final favorites = ref.watch(localFavoritesProvider);
                      final isFavorite = favorites.contains(firm.id);
                      
                      return FirmCardMini(
                        firm: firm,
                        index: index,
                        isFavorite: isFavorite,
                        onFavorite: () => ref.read(localFavoritesProvider.notifier).toggleFavorite(firm.id),
                        onTap: () => _showFirmDetail(context, firm),
                      );
                    }
                  );
                },
                childCount: displayFirms.length,
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _getUserCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 5), onTimeout: () => throw 'Timeout');

      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isEmpty) return null;
      return placemarks.first.administrativeArea;
    } catch (e) {
      debugPrint('Error getting user city: $e');
      return null;
    }
  }

  // ==================== CAMPAIGN CARDS ====================
  static const List<Color> _campaignBgColors = [
    Color(0xFFFFE4EC),
    Color(0xFFF3E5F5),
    Color(0xFFFFF3E0),
    Color(0xFFE8F5E9),
  ];
  
  static const List<Color> _campaignAccentColors = [
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
  ];

  Widget _buildMockCampaignCards(BuildContext context, WidgetRef ref) {
    final mockCampaigns = [
      {'title': 'Yaza Özel %25', 'firm': 'Temiz Halı', 'discount': '%25'},
      {'title': 'Bahar Temizliği', 'firm': 'Pırıl Halı', 'discount': '%20'},
      {'title': 'İlk Sipariş %15', 'firm': 'Hızlı Yıkama', 'discount': '%15'},
      {'title': 'Kurumsal Fiyat', 'firm': 'Pro Clean', 'discount': '%30'},
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: mockCampaigns.length,
      itemBuilder: (context, index) {
        final camp = mockCampaigns[index];
        final colorIndex = index % 4;
        return AnimatedCampaignCard(
          title: camp['title'] as String,
          subtitle: camp['firm'] as String,
          discount: camp['discount'] as String,
          accentColor: _campaignAccentColors[colorIndex],
          bgColor: _campaignBgColors[colorIndex],
        );
      },
    );
  }

  void _showFirmDetail(BuildContext context, FirmModel firm) {
    FirmDetailSheet.show(
      context,
      firm,
      onAddToCart: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${firm.name} sepete eklendi!'),
            backgroundColor: CustomerTheme.success,
          ),
        );
      },
    );
  }

  /// Show address selection sheet
  void _showAddressSelectionSheet(BuildContext context, WidgetRef ref, CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Adres Seçimi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(customer.addresses.length, (index) {
              final addr = customer.addresses[index];
              final isSelected = customer.selectedAddressIndex == index;
              return ListTile(
                leading: Icon(Icons.home, color: isSelected ? Colors.purple : Colors.grey),
                title: Text(
                  addr.title.isNotEmpty 
                    ? addr.title 
                    : (addr.district.isNotEmpty ? '${addr.district}, ${addr.city}' : 'İsimsiz Adres'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(addr.fullAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.purple) : null,
                onTap: () async {
                  await ref.read(customerRepositoryProvider).setSelectedAddress(customer.id, index);
                  ref.invalidate(currentCustomerProvider);
                  if (context.mounted) Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.add_location, color: Colors.blue),
              title: const Text('Yeni Adres Ekle', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                // Redirect to profile tab or show add address dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profilim -> Adreslerim kısmından yeni adres ekleyebilirsiniz.')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build notification button with badge
  Widget _buildNotificationButton(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return IconButton(
        icon: const Icon(Icons.notifications, color: Colors.white),
        onPressed: () {},
      );
    }

    final notificationRepo = ref.watch(notificationRepositoryProvider);
    final unreadStream = notificationRepo.getUnreadCount(
      userId: user.uid,
      userType: 'customer',
    );

    return StreamBuilder<int>(
      stream: unreadStream,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerNotificationsScreen()),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
