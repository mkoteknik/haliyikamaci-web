import 'package:flutter/material.dart';
import '../../core/utils/image_utils.dart';
import '../../data/models/models.dart';
import '../../core/theme/customer_theme.dart';
import 'firm_card_widget.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final FirmModel firm;
  final int index;
  final VoidCallback? onTap;

  // Pastel Colors Palette (Pink, Purple, Orange/Yellow, Green, Blue)
  static const List<Color> _bgColors = [
    Color(0xFFFFF0F5), // Lavender Blush (Pinkish)
    Color(0xFFF3E5F5), // Purple 50
    Color(0xFFFFF8E1), // Amber 50
    Color(0xFFE8F5E9), // Green 50
    Color(0xFFE3F2FD), // Blue 50
  ];
  static const List<Color> _accentColors = [
    Color(0xFFD81B60), // Pink 600
    Color(0xFF8E24AA), // Purple 600
    Color(0xFFF57F17), // Yellow/Orange 
    Color(0xFF43A047), // Green 600
    Color(0xFF1E88E5), // Blue 600
  ];

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.firm,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Cycle through colors
    final colorIndex = index % _bgColors.length;
    final bgColor = _bgColors[colorIndex];
    final accentColor = _accentColors[colorIndex];
    
    final discount = campaign.discountPercent;
    final discountText = discount > 0 ? '%$discount' : 'FIRSAT';
    final isPercent = discount > 0;

    return GestureDetector(
      onTap: () => _showCampaignDetail(context, campaign, firm),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias, // Clip for the bottom container
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - Discount Pill (Transparent/Colored BG)
            Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    discountText,
                    style: TextStyle(
                      fontSize: isPercent ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom Section - Info with Off-White Background
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFDFBF7), // Warm Off-White / Broken White
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Campaign Title (Prominent & Colored)
                    Expanded(
                      child: Text(
                        campaign.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor, 
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Firm Name (Discreet with Icon)
                    Row(
                      children: [
                        Icon(Icons.store, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            firm.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCampaignDetail(BuildContext context, CampaignModel campaign, FirmModel firm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet( 
        initialChildSize: 0.5, // Reduced size since button is gone
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Drag Handle
                 Center(
                   child: Container(
                     width: 40, height: 4, 
                     decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                   ),
                 ),
                 const SizedBox(height: 24),

                 // Header: Badge & Title
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: CustomerTheme.primary.withAlpha(20),
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: CustomerTheme.primary.withAlpha(50)),
                       ),
                       child: Text(
                          campaign.discountPercent > 0 ? '%${campaign.discountPercent} İNDİRİM' : 'ÖZEL FIRSAT',
                          style: const TextStyle(color: CustomerTheme.primary, fontWeight: FontWeight.bold),
                       ),
                     ),
                     const Spacer(),
                     // Dates
                     Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                     const SizedBox(width: 4),
                     Text(
                       '${campaign.endDate.day}.${campaign.endDate.month}.${campaign.endDate.year}''e kadar',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                     ),
                   ],
                 ),
                 const SizedBox(height: 16),
                 
                 // Title
                 Text(
                   campaign.title,
                   style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                 ),
                 const SizedBox(height: 24),
                 
                 // Conditions / Description
                 const Text(
                   'KAMPANYA KOŞULLARI',
                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                 ),
                 const SizedBox(height: 8),
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.grey[50],
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.grey[200]!),
                   ),
                   child: Text(
                     campaign.description.isNotEmpty ? campaign.description : 'Detay belirtilmemiş.',
                     style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                   ),
                 ),
                 const SizedBox(height: 24),

                 // Firm Info Small
                 const Divider(),
                 const SizedBox(height: 16),
                 ListTile(
                   contentPadding: EdgeInsets.zero,
                   leading: CircleAvatar(
                      backgroundColor: CustomerTheme.primary,
                      backgroundImage: ImageUtils.getSafeImageProvider(firm.logo),
                      child: ImageUtils.getSafeImageProvider(firm.logo) == null ? Text(firm.name[0]) : null,
                   ),
                   title: Text(firm.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Row(
                     children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(' ${firm.rating}'),
                     ],
                   ),
                   trailing: OutlinedButton(
                     onPressed: () {
                        Navigator.pop(context); // Close sheet
                        // Use the shared FirmDetailSheet
                        FirmDetailSheet.show(context, firm);
                     },
                     child: const Text('Profili Gör'),
                   ),
                 ),
                 SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
