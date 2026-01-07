import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../core/theme/customer_theme.dart';
import '../../core/utils/image_utils.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../widgets/firm_card_widget.dart';
import 'nearby_firms_map_screen.dart';
import '../widgets/ad_banner_widget.dart';

/// Customer Firms Tab - Nearby firms listing with colorful cards
class CustomerFirmsTab extends ConsumerStatefulWidget {
  const CustomerFirmsTab({super.key});

  @override
  ConsumerState<CustomerFirmsTab> createState() => _CustomerFirmsTabState();
}

class _CustomerFirmsTabState extends ConsumerState<CustomerFirmsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Alternating feminine color palette for firm cards (1-2-3 repeating pattern)
  static const List<Color> _cardColors = [
    Color(0xFFFFE4EC), // Soft Pink
    Color(0xFFF3E5F5), // Soft Purple
    Color(0xFFFFF3E0), // Soft Peach
  ];

  static const List<Color> _accentColors = [
    Color(0xFFE91E63), // Rose Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
  ];

  @override
  Widget build(BuildContext context) {
    final firmsAsync = ref.watch(approvedFirmsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: CustomerTheme.surface,
          foregroundColor: CustomerTheme.textDark,
          title: Text(AppLocalizations.of(context)!.nearbyFirms),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchHint,
                        prefixIcon: const Icon(Icons.search, color: CustomerTheme.primary),
                        suffixIcon: _searchQuery.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                        filled: true,
                        fillColor: CustomerTheme.softPink,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Map icon button
                  Container(
                    decoration: BoxDecoration(
                      color: CustomerTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.map, color: Colors.white),
                      onPressed: () => _openNearbyFirmsMap(context, ref),
                      tooltip: AppLocalizations.of(context)!.showOnMap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        firmsAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: CustomerTheme.primary),
            )),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
          ),
          data: (firms) {
            // FILTERING LOGIC
            final filteredFirms = firms.where((firm) {
              final nameMatch = firm.name.toLowerCase().contains(_searchQuery);
              final addressMatch = firm.address.fullAddress.toLowerCase().contains(_searchQuery);
              // Could add service filtering too
              return nameMatch || addressMatch;
            }).toList();

            if (filteredFirms.isEmpty) {
              if (_searchQuery.isNotEmpty) {
                 return const SliverToBoxAdapter(
                   child: Padding(
                     padding: EdgeInsets.all(32),
                     child: Center(child: Text('Aradığınız kriterlere uygun firma bulunamadı.', style: TextStyle(color: Colors.grey))),
                   ),
                 );
              }
              // Mock data with colorful cards if no firms at all (demo mode mostly)
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMockFirmListItem(context, index),
                  childCount: 10,
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final firm = filteredFirms[index];
                  return Consumer(
                    builder: (context, ref, _) {
                      final favorites = ref.watch(localFavoritesProvider);
                      final isFavorite = favorites.contains(firm.id);
                      
                      return FirmCardMini(
                        firm: firm,
                        index: index,
                        isFavorite: isFavorite,
                        onFavorite: () => ref.read(localFavoritesProvider.notifier).toggleFavorite(firm.id),
                        onTap: () => _openFirmDetail(context, firm),
                      );
                    },
                  );
                },
                childCount: filteredFirms.length,
              ),
            );
          },
        ),

          // Ad Banner
          const SliverToBoxAdapter(child: AdBannerWidget()),

          // Bottom Spacer
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildMockFirmListItem(BuildContext context, int index) {
    final colorIndex = index % 3;
    final bgColor = _cardColors[colorIndex];
    final accentColor = _accentColors[colorIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(12),
            // Mock image or initial
          ),
          child: Center(
            child: Text(
              'F${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        title: Text(
          '${AppLocalizations.of(context)!.carpetCleaning} ${index + 1}', // "Halı Yıkama X"
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.orange),
              Text(' ${4 + (index % 10) / 10}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.location_on, size: 14, color: CustomerTheme.textMedium),
              const Text(' 1.2 km', style: TextStyle(fontSize: 12, color: CustomerTheme.textMedium)),
            ],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: accentColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
          child: const Text('İncele'), // Buna da ihtiyaç var: inspect/view
        ),
      ),
    );
  }

  Widget _buildFirmListItem(BuildContext context, FirmModel firm, int index) {
    final colorIndex = index % 3;
    final bgColor = _cardColors[colorIndex];
    final accentColor = _accentColors[colorIndex];

    // Safe image loading
    final logoProvider = ImageUtils.getSafeImageProvider(firm.logo);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openFirmDetail(context, firm),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                  image: logoProvider != null
                      ? DecorationImage(image: logoProvider, fit: BoxFit.cover)
                      : null,
                ),
                child: logoProvider == null
                    ? Center(
                        child: Text(
                          firm.name.isNotEmpty ? firm.name.substring(0, 1).toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firm.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        Text(' ${firm.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text('(${firm.reviewCount} yorum)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: accentColor),
                        Expanded(
                          child: Text(
                            ' ${firm.address.shortAddress}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite & View Button Column
              Consumer(
                builder: (context, ref, _) {
                  final favorites = ref.watch(localFavoritesProvider);
                  final isFavorite = favorites.contains(firm.id);
                  
                  return Column(
                    children: [
                      // Favorite Button
                      GestureDetector(
                        onTap: () {
                          ref.read(localFavoritesProvider.notifier).toggleFavorite(firm.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isFavorite
                                  ? '${firm.name} favorilerden kaldırıldı'
                                  : '${firm.name} favorilere eklendi ❤️'),
                              backgroundColor: isFavorite ? Colors.grey : accentColor,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4)],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : accentColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // View Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text('İncele', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNearbyFirmsMap(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NearbyFirmsMapScreen()),
    );
  }

  void _openFirmDetail(BuildContext context, FirmModel firm) {
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
}

