import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/customer_theme.dart';
import '../../core/utils/image_utils.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../customer/create_order_sheet.dart';

// ============================================================================
// FIRM CARD MINI - For List/Feed Views (Minimal)
// ============================================================================
/// Minimal Firm Card for listing (feed, nearby firms, search results)
/// Shows: Cover Image + Rating Badge + Firm Name + Avatar + Location
class FirmCardMini extends StatelessWidget {
  final FirmModel firm;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const FirmCardMini({
    super.key,
    required this.firm,
    this.index = 0,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    // Safe image loading using ImageUtils
    final coverProvider = ImageUtils.getSafeImageProvider(firm.coverImage);
    final avatarProvider = ImageUtils.getSafeImageProvider(firm.logo);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== COVER IMAGE ====================
            Stack(
              children: [
                // Cover Image
                Container(
                  height: 116, // Reduced by another 10% (128 -> 116)
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: coverProvider != null
                        ? DecorationImage(image: coverProvider, fit: BoxFit.cover)
                        : null,
                  ),
                  child: coverProvider == null
                      ? Center(
                          child: Icon(Icons.storefront, size: 48, color: Colors.grey[400]),
                        )
                      : null,
                ),
                
                // Rating Badge (Bottom-Left)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          firm.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Favorite Button (Top-Right)
                if (onFavorite != null)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: onFavorite,
                        iconSize: 22,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
              ],
            ),
            
            // ==================== FIRM INFO ====================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: CustomerTheme.primary.withAlpha(50),
                    backgroundImage: avatarProvider,
                    child: avatarProvider == null
                        ? Text(
                            firm.name.isNotEmpty ? firm.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: CustomerTheme.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Name and Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firm.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: CustomerTheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${firm.address.district}, ${firm.address.city}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FIRM DETAIL SHEET - Shared Detail Modal for All Tabs
// ============================================================================
/// Full Firm Detail Sheet - Use with showFirmDetailSheet() helper
class FirmDetailSheet extends ConsumerWidget {
  final FirmModel firm;
  final ScrollController scrollController;
  final VoidCallback? onAddToCart;

  const FirmDetailSheet({
    super.key,
    required this.firm,
    required this.scrollController,
    this.onAddToCart,
  });

  /// Show firm detail modal - use this method from any screen
  static void show(BuildContext context, FirmModel firm, {VoidCallback? onAddToCart}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => FirmDetailSheet(
          firm: firm,
          scrollController: scrollController,
          onAddToCart: onAddToCart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safe image loading using ImageUtils
    final coverProvider = ImageUtils.getSafeImageProvider(firm.coverImage);
    final avatarProvider = ImageUtils.getSafeImageProvider(firm.logo);

    final hasWhatsApp = firm.whatsapp != null && firm.whatsapp!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // ==================== COVER IMAGE WITH AVATAR ====================
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Cover Image
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: coverProvider != null
                            ? DecorationImage(image: coverProvider, fit: BoxFit.cover)
                            : null,
                      ),
                      child: coverProvider == null
                          ? Center(child: Icon(Icons.storefront, size: 64, color: Colors.grey[400]))
                          : null,
                    ),
                    
                    // Avatar (Overlapping)
                    Positioned(
                      left: 20,
                      bottom: -35,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: CustomerTheme.primary,
                          backgroundImage: avatarProvider,
                          child: avatarProvider == null
                              ? Text(
                                  firm.name.isNotEmpty ? firm.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 28,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // ==================== FIRM INFO ====================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        firm.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      // Rating and Location Row
                      Row(
                        children: [
                          // Rating
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${firm.rating.toStringAsFixed(1)} (${firm.reviewCount} yorum)',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Address
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: CustomerTheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                firm.address.fullAddress.isNotEmpty 
                                    ? firm.address.fullAddress 
                                    : '${firm.address.district}, ${firm.address.city}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // ==================== SERVICES ====================
                      if (firm.services.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text('Hizmetler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...firm.services.where((s) => s.enabled).map((service) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CustomerTheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: CustomerTheme.success, size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(service.serviceName)),
                              Text(
                                '₺${service.price.toStringAsFixed(0)}/${service.unit}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: CustomerTheme.primary),
                              ),
                            ],
                          ),
                        )),
                      ],
                      
                      // ==================== ACTION BUTTONS ====================
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Call Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _callPhone(firm.phone),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Ara'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: CustomerTheme.primary,
                                side: const BorderSide(color: CustomerTheme.primary),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          
                          // WhatsApp Button
                          if (hasWhatsApp) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openWhatsApp(firm.whatsapp!),
                                icon: const Icon(Icons.chat, size: 18),
                                label: const Text('WhatsApp'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      // ==================== START ORDER BUTTON ====================
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                             Navigator.pop(context); // Close sheet
                             // Open Order Wizard with this firm selected
                             showModalBottomSheet(
                               context: context,
                               isScrollControlled: true,
                               backgroundColor: Colors.transparent,
                               builder: (ctx) => DraggableScrollableSheet(
                                 initialChildSize: 0.85,
                                 minChildSize: 0.5,
                                 maxChildSize: 0.95,
                                 builder: (_, scrollController) => CreateOrderSheet(
                                   initialFirm: firm,
                                   onComplete: (firmId) {
                                     Navigator.pop(ctx);
                                     // Optional: Show success dialog/animation
                                   },
                                   onNavigateToFirms: () {
                                     Navigator.pop(ctx);
                                     // Already targeted, no need to nav
                                   },
                                 ),
                               ),
                             );
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text('+ Hizmet Al', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomerTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      
                      // ==================== REVIEWS SECTION ====================
                      const SizedBox(height: 24),
                      _buildReviewsSection(ref),
                      
                      // Bottom padding
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build reviews section with pagination
  Widget _buildReviewsSection(WidgetRef ref) {
    final reviewsStream = ref.watch(firmRepositoryProvider).getFirmReviews(firm.id, limit: 10);
    
    return StreamBuilder<List<ReviewModel>>(
      stream: reviewsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        
        final reviews = snapshot.data ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Yorumlar (${firm.reviewCount ?? reviews.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Reviews List
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_outlined, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text('Henüz yorum yok', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
            else ...[
              ...reviews.map((review) => _buildReviewCard(review)),
              // Show "Load More" button if there might be more reviews
              if ((firm.reviewCount ?? 0) > reviews.length)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => _showAllReviewsSheet(context, ref),
                      icon: const Icon(Icons.expand_more, size: 18),
                      label: Text('Tümünü Gör (${firm.reviewCount ?? 0})'),
                      style: TextButton.styleFrom(
                        foregroundColor: CustomerTheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  /// Show all reviews in a bottom sheet with pagination
  void _showAllReviewsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AllReviewsSheet(firm: firm),
    );
  }

  /// Build individual review card
  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Date, Stars
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: CustomerTheme.primary.withAlpha(30),
                child: Text(
                  review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CustomerTheme.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                )),
              ),
            ],
          ),
          
          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],

          // Firma yanıtı
          if (review.firmReply != null && review.firmReply!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CustomerTheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CustomerTheme.primary.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.reply, size: 14, color: CustomerTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Firma Yanıtı',
                        style: TextStyle(
                          color: CustomerTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.firmReply!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 30) {
      return '${date.day}.${date.month}.${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} gün önce';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} saat önce';
    } else {
      return 'Az önce';
    }
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ============================================================================
// ALL REVIEWS SHEET WITH PAGINATION
// ============================================================================
class _AllReviewsSheet extends ConsumerStatefulWidget {
  final FirmModel firm;
  
  const _AllReviewsSheet({required this.firm});

  @override
  ConsumerState<_AllReviewsSheet> createState() => _AllReviewsSheetState();
}

class _AllReviewsSheetState extends ConsumerState<_AllReviewsSheet> {
  final List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialReviews();
  }

  Future<void> _loadInitialReviews() async {
    final firmRepo = ref.read(firmRepositoryProvider);
    final stream = firmRepo.getFirmReviews(widget.firm.id, limit: 10);
    
    stream.first.then((reviews) {
      if (mounted) {
        setState(() {
          _reviews.clear();
          _reviews.addAll(reviews);
          _initialLoading = false;
          _hasMore = reviews.length >= 10;
        });
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || _reviews.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final firmRepo = ref.read(firmRepositoryProvider);
      final lastReview = _reviews.last;
      final moreReviews = await firmRepo.getMoreFirmReviews(
        widget.firm.id, 
        lastCreatedAt: lastReview.createdAt,
        limit: 10,
      );
      
      if (mounted) {
        setState(() {
          _reviews.addAll(moreReviews);
          _hasMore = moreReviews.length >= 10;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Tüm Yorumlar (${widget.firm.reviewCount ?? _reviews.length})',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Reviews list
          Expanded(
            child: _initialLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('Henüz yorum yok', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _reviews.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _reviews.length) {
                            // Load more button
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: _loadMore,
                                        icon: const Icon(Icons.expand_more, size: 18),
                                        label: const Text('Daha Fazla Yükle'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: CustomerTheme.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          }
                          
                          return _buildReviewCard(_reviews[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Date, Stars
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: CustomerTheme.primary.withAlpha(30),
                child: Text(
                  review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomerTheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                )),
              ),
            ],
          ),
          // Comment
          if (review.comment?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================================================
// LEGACY SUPPORT
// ============================================================================
/// @deprecated Use FirmCardMini instead
typedef FirmCardWidget = FirmCardMini;

