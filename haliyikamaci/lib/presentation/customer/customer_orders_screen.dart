import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/customer_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../widgets/rating_dialog.dart';

/// Customer Orders Screen
/// Lists active and past orders with Chat functionality
class CustomerOrdersScreen extends ConsumerWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(currentCustomerProvider).value;
    if (customer == null) return const Center(child: CircularProgressIndicator());

    final ordersAsync = ref.watch(customerOrdersProvider(customer.id));

    return Scaffold(
      backgroundColor: CustomerTheme.background,
      appBar: AppBar(
        title: const Text('Siparişlerim'),
        backgroundColor: CustomerTheme.surface,
        foregroundColor: CustomerTheme.textDark,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Henüz siparişiniz bulunmuyor.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/customer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Hizmetleri Keşfet'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _OrderCard(order: orders[index], customerId: customer.id);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final String customerId;
  const _OrderCard({required this.order, required this.customerId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'onay bekliyor': return Colors.orange;
      case 'confirmed':
      case 'onaylandı': return Colors.blue;
      case 'picked_up':
      case 'teslim alındı': return Colors.purple;
      case 'measured':
      case 'ölçüm yapıldı': return Colors.teal;
      case 'washing':
      case 'yıkanıyor': return Colors.teal;
      case 'out_for_delivery':
      case 'dağıtıma çıkarıldı': return Colors.indigo;
      case 'delivering':
      case 'dağıtımda': return Colors.indigo;
      case 'delivered':
      case 'teslim edildi': return Colors.green;
      case 'completed':
      case 'tamamlandı': return Colors.green;
      case 'cancelled':
      case 'iptal': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    // Basic mapping, assuming backend sends raw strings
    switch (status.toLowerCase()) {
      case 'pending': return 'Onay Bekliyor';
      case 'confirmed': return 'Onaylandı';
      case 'picked_up': return 'Teslim Alındı';
      case 'measured': return 'Ölçüm Yapıldı';
      case 'washing': return 'Yıkanıyor';
      case 'out_for_delivery': return 'Dağıtıma Çıkarıldı';
      case 'delivering': return 'Dağıtımda';
      case 'delivered': return 'Teslim Edildi';
      case 'completed': return 'Tamamlandı';
      case 'cancelled': return 'İptal Edildi';
      default: return status;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Siparişi Listeden Kaldır'),
        content: const Text('Bu siparişi listeden kaldırmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(orderRepositoryProvider).softDeleteOrderForCustomer(order.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sipariş listeden kaldırıldı'),
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Kaldır', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Row(
              children: [
                const Icon(Icons.receipt_long, color: CustomerTheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.firmName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy, HH:mm', 'tr').format(order.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Services Section
            const Text(
              'Talep Edilen Hizmetler',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${item.quantity} Adet ${item.serviceName}')),
                  if (item.totalPrice != null)
                    Text('₺${item.totalPrice!.toStringAsFixed(0)}', 
                         style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Address Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20, color: CustomerTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Adres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        order.customerAddress.fullAddressDisplay,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment Method
            Row(
              children: [
                const Icon(Icons.payment, size: 20, color: CustomerTheme.primary),
                const SizedBox(width: 8),
                const Text('Ödeme: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  _getPaymentLabel(order.paymentMethod),
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
            
            // Total Price
            if (order.totalPrice != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomerTheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Toplam Tutar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '₺${order.totalPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: CustomerTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Notes
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notunuz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(order.notes!, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kapat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getPaymentLabel(String method) {
    switch (method) {
      case 'cash': return 'Nakit';
      case 'card': return 'Kredi Kartı';
      case 'transfer': return 'Havale/EFT';
      default: return method;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(order.status);
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt);
    
    // Check for unread messages
    final hasUnreadAsync = ref.watch(unreadOrderMessagesProvider((
      orderId: order.id,
      userId: customerId,
      userType: 'customer',
    )));
    final hasUnread = hasUnreadAsync.value ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Firm Name & Status & Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.firmName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withAlpha(100)),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Siparişi Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, ref);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date & Amount
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Spacer(),
                Text(
                  '₺${(order.totalPrice ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CustomerTheme.primary),
                ),
              ],
            ),
            const Divider(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrderDetails(context),
                    child: const Text('Detaylar'),
                  ),
                ),
                const SizedBox(width: 12),
                // [CHAT BUTTON with Badge]
                Expanded(
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/order-chat/${order.id}', extra: {
                              'firmId': order.firmId,
                              'firmName': order.firmName,
                            });
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Mesaj'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomerTheme.secondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Değerlendir butonu - sadece teslim edilmiş siparişlerde
            if (order.status == 'delivered')
              FutureBuilder<bool>(
                future: ref.read(firmRepositoryProvider).hasCustomerReviewedOrder(order.id),
                builder: (context, snapshot) {
                  final hasReviewed = snapshot.data ?? false;
                  if (hasReviewed) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => RatingDialog.show(context, order, null),
                        icon: const Icon(Icons.star, size: 18),
                        label: const Text('Değerlendir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
