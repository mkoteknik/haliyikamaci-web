import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/customer_theme.dart';
import '../../core/utils/profanity_helper.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';

/// Rating Dialog - Sipariş tamamlandığında değerlendirme popup
class RatingDialog extends ConsumerStatefulWidget {
  final OrderModel order;
  final FirmModel? firm;

  const RatingDialog({
    super.key,
    required this.order,
    this.firm,
  });

  static Future<void> show(BuildContext context, OrderModel order, FirmModel? firm) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(order: order, firm: firm),
    );
  }

  @override
  ConsumerState<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends ConsumerState<RatingDialog> {
  int _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    try {
      final customer = ref.read(currentCustomerProvider).value;
      final firmRepo = ref.read(firmRepositoryProvider);
      final customerRepo = ref.read(customerRepositoryProvider);
      final profanityHelper = ref.read(profanityHelperProvider);

      final comment = _commentController.text.trim();

      // Check for profanity
      if (comment.isNotEmpty && profanityHelper.hasProfanity(comment)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yorumunuz uygunsuz ifadeler içeriyor. Lütfen düzeltin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Create review
      final review = ReviewModel(
        id: '',
        orderId: widget.order.id,
        customerId: customer?.id ?? 'demo_customer',
        customerName: customer?.fullName ?? 'Demo Müşteri',
        firmId: widget.order.firmId,
        firmName: widget.order.firmName,
        rating: _rating,
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
        createdAt: DateTime.now(),
      );

      // Save review to Firestore
      await firmRepo.addReview(review);

      // Update firm rating
      await firmRepo.updateFirmRating(widget.order.firmId);

      // Add loyalty points if firm has loyalty enabled
      if (widget.firm?.loyaltyEnabled == true && customer != null) {
        final totalPrice = widget.order.totalPrice ?? 0;
        final percentage = widget.firm!.loyaltyPercentage;
        final pointsEarned = (totalPrice * percentage / 100).round();
        
        if (pointsEarned > 0) {
          await customerRepo.addLoyaltyPoints(customer.id, widget.order.firmId, pointsEarned);
        }

        // Bonus for review
        await customerRepo.addLoyaltyPoints(customer.id, widget.order.firmId, 10);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.firm?.loyaltyEnabled == true
                ? 'Değerlendirmeniz kaydedildi! +${((widget.order.totalPrice ?? 0) * (widget.firm!.loyaltyPercentage) / 100).round() + 10} puan kazandınız! 🎉'
                : 'Değerlendirmeniz kaydedildi! Teşekkür ederiz 💙'),
            backgroundColor: CustomerTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CustomerTheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 48, color: CustomerTheme.primary),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              'Hizmeti Değerlendirin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.firmName,
              style: const TextStyle(color: CustomerTheme.textMedium),
            ),
            const SizedBox(height: 24),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            Text(
              _getRatingText(),
              style: TextStyle(
                color: _getRatingColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Comment (Optional)
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Yorum yazın (opsiyonel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: CustomerTheme.background,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Loyalty info
            if (widget.firm?.loyaltyEnabled == true)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu değerlendirme ile ${((widget.order.totalPrice ?? 0) * (widget.firm!.loyaltyPercentage) / 100).round() + 10} puan kazanacaksınız!',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Sonra'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Değerlendir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1: return 'Çok Kötü 😞';
      case 2: return 'Kötü 😕';
      case 3: return 'Orta 😐';
      case 4: return 'İyi 😊';
      case 5: return 'Mükemmel 🤩';
      default: return '';
    }
  }

  Color _getRatingColor() {
    switch (_rating) {
      case 1:
      case 2: return Colors.red;
      case 3: return Colors.orange;
      case 4:
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }
}
