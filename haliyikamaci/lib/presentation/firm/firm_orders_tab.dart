import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/sms_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/pdf_label_generator.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/accounting_repository.dart';
import '../../data/providers/providers.dart';
import 'dialogs/label_count_dialog.dart';
import 'dialogs/print_options_model.dart';

class FirmOrdersTab extends ConsumerStatefulWidget {
  const FirmOrdersTab({super.key});

  @override
  ConsumerState<FirmOrdersTab> createState() => _FirmOrdersTabState();
}

class _FirmOrdersTabState extends ConsumerState<FirmOrdersTab> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final firmAsync = ref.watch(currentFirmProvider);

    return firmAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        debugPrint('❌ FirmOrdersTab ERROR: $e');
        return Center(child: Text('Hata: $e'));
      },
      data: (firm) {
        debugPrint('📦 FirmOrdersTab: firm = ${firm?.id ?? "NULL"}, name = ${firm?.name ?? "NULL"}');
        
        // If firm is null, show error instead of demo mode
        if (firm == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Siparişler'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: AppTheme.darkGray,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text('Firma bilgisi yüklenemedi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Lütfen çıkış yapıp tekrar giriş yapın', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(currentFirmProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            ),
          );
        }

        final ordersAsync = ref.watch(firmOrdersProvider(firm.id));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Siparişler'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: AppTheme.darkGray,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) => setState(() => _filterStatus = value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('Tümü')),
                  PopupMenuItem(value: OrderModel.statusPending, child: const Text('Bekleyen')),
                  PopupMenuItem(value: OrderModel.statusConfirmed, child: const Text('Onaylanan')),
                  PopupMenuItem(value: OrderModel.statusPickedUp, child: const Text('Teslim Alınan')),
                  PopupMenuItem(value: OrderModel.statusMeasured, child: const Text('Ölçüm Yapılan')),
                  PopupMenuItem(value: OrderModel.statusOutForDelivery, child: const Text('Dağıtıma Çıkan')),
                  PopupMenuItem(value: OrderModel.statusDelivered, child: const Text('Teslim Edilen')),
                  PopupMenuItem(value: OrderModel.statusCancelled, child: const Text('İptal')),
                ],
              ),
            ],
          ),
          body: ordersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
            data: (orders) {
              // Filter orders
              final filteredOrders = _filterStatus == 'all'
                  ? orders
                  : orders.where((o) => o.status == _filterStatus).toList();

              if (filteredOrders.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(filteredOrders[index], firm);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDemoOrdersView(FirmModel firm) {
    final demoOrders = _getMockOrders();
    final filteredOrders = _filterStatus == 'all'
        ? demoOrders
        : demoOrders.where((o) => o.status == _filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Siparişler'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('DEMO', style: TextStyle(fontSize: 10, color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.darkGray,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterStatus = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tümü')),
              PopupMenuItem(value: OrderModel.statusPending, child: const Text('Bekleyen')),
              PopupMenuItem(value: OrderModel.statusConfirmed, child: const Text('Onaylanan')),
              PopupMenuItem(value: OrderModel.statusPickedUp, child: const Text('Teslim Alınan')),
              PopupMenuItem(value: OrderModel.statusMeasured, child: const Text('Ölçüm Yapılan')),
              PopupMenuItem(value: OrderModel.statusOutForDelivery, child: const Text('Dağıtıma Çıkan')),
              PopupMenuItem(value: OrderModel.statusDelivered, child: const Text('Teslim Edilen')),
              PopupMenuItem(value: OrderModel.statusCancelled, child: const Text('İptal')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(filteredOrders[index], firm);
        },
      ),
    );
  }

  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: 'demo_order_1',
        firmId: 'demo_firm',
        firmName: 'Demo Halı Yıkama',
        firmPhone: '5551234567',
        customerId: 'demo_customer_1',
        customerName: 'Ahmet Yılmaz',
        customerPhone: '5559876543',
        customerAddress: AddressModel(
          city: 'İstanbul',
          district: 'Kadıköy',
          area: '',
          neighborhood: 'Caferağa',
          fullAddress: 'Moda Cad. No:45 D:3',
        ),
        paymentMethod: FirmModel.paymentCash,
        status: OrderModel.statusPending,
        items: [
          OrderItemModel(serviceId: 'hali', serviceName: 'Halı Yıkama', unit: 'm²', quantity: 3, unitPrice: 25.0),
          OrderItemModel(serviceId: 'yorgan', serviceName: 'Yorgan Yıkama', unit: 'adet', quantity: 2, unitPrice: 80.0),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      OrderModel(
        id: 'demo_order_2',
        firmId: 'demo_firm',
        firmName: 'Demo Halı Yıkama',
        firmPhone: '5551234567',
        customerId: 'demo_customer_2',
        customerName: 'Fatma Demir',
        customerPhone: '5557778899',
        customerAddress: AddressModel(
          city: 'İstanbul',
          district: 'Ataşehir',
          area: '',
          neighborhood: 'Küçükbakkalköy',
          fullAddress: 'Atatürk Mah. Yıldız Sok. No:12',
        ),
        paymentMethod: FirmModel.paymentCard,
        status: OrderModel.statusConfirmed,
        items: [
          OrderItemModel(serviceId: 'koltuk', serviceName: 'Koltuk Yıkama', unit: 'takım', quantity: 1, unitPrice: 350.0),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        confirmedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      OrderModel(
        id: 'demo_order_3',
        firmId: 'demo_firm',
        firmName: 'Demo Halı Yıkama',
        firmPhone: '5551234567',
        customerId: 'demo_customer_3',
        customerName: 'Mehmet Kaya',
        customerPhone: '5553334455',
        customerAddress: AddressModel(
          city: 'İstanbul',
          district: 'Üsküdar',
          area: '',
          neighborhood: 'Çengelköy',
          fullAddress: 'Çınaraltı Mah. Sahil Yolu No:78',
        ),
        paymentMethod: FirmModel.paymentTransfer,
        status: OrderModel.statusPickedUp,
        items: [
          OrderItemModel(serviceId: 'hali', serviceName: 'Halı Yıkama', unit: 'm²', quantity: 5, unitPrice: 25.0),
          OrderItemModel(serviceId: 'perde', serviceName: 'Perde Yıkama', unit: 'adet', quantity: 4, unitPrice: 40.0),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        confirmedAt: DateTime.now().subtract(const Duration(days: 2)),
        pickedUpAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  FirmModel _getMockFirm() {
    return FirmModel(
      id: 'demo_firm',
      uid: 'demo_uid',
      name: 'Demo Halı Yıkama',
      phone: '5551234567',
      address: AddressModel(
        city: 'İstanbul',
        district: 'Kadıköy',
        area: '',
        neighborhood: 'Caferağa',
        fullAddress: 'Demo Adres',
      ),
      smsBalance: 100,
      services: [
        ServicePriceModel(serviceId: 'hali', serviceName: 'Halı Yıkama', unit: 'm²', price: 25.0, enabled: true),
        ServicePriceModel(serviceId: 'yorgan', serviceName: 'Yorgan Yıkama', unit: 'adet', price: 80.0, enabled: true),
        ServicePriceModel(serviceId: 'koltuk', serviceName: 'Koltuk Yıkama', unit: 'takım', price: 350.0, enabled: true),
        ServicePriceModel(serviceId: 'perde', serviceName: 'Perde Yıkama', unit: 'adet', price: 40.0, enabled: true),
      ],
      paymentMethods: [FirmModel.paymentCash, FirmModel.paymentCard, FirmModel.paymentTransfer],
      createdAt: DateTime.now(),
    );
  }


  void _confirmDeleteOrder(BuildContext context, String orderId) {
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
                await ref.read(orderRepositoryProvider).softDeleteOrderForFirm(orderId);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Henüz sipariş yok',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni siparişler burada görünecek',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, FirmModel firm) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerAddress.shortAddress,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status, statusColor),
                const SizedBox(width: 4),
                // Delete menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[700], size: 20),
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
                      _confirmDeleteOrder(context, order.id);
                    }
                  },
                ),
              ],
            ),
          ),

          // Order details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Services
                const Text('Talep Edilen Hizmetler:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text('${item.quantity} Adet ${item.serviceName}'),
                    ],
                  ),
                )),

                const SizedBox(height: 12),

                // Payment method
                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Ödeme: ${FirmModel.getPaymentMethodLabel(order.paymentMethod)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Order date
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                // Total price if measured
                if (order.totalPrice != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toplam Tutar:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          '₺${order.totalPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Route button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openRoute(order),
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Rota'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Print Label button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPrintLabelDialog(order, firm),
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Etiket'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // MESSAGE BUTTON [NEW] with Badge
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Navigate to Order Chat
                                context.push('/order-chat/${order.id}', extra: {
                                  'firmId': firm.id,
                                  'firmName': firm.name,
                                });
                              },
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: const Text('Mesaj'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          // Unread badge
                          Builder(
                            builder: (context) {
                              final hasUnreadAsync = ref.watch(unreadOrderMessagesProvider((
                                orderId: order.id,
                                userId: firm.id,
                                userType: 'firm',
                              )));
                              final hasUnread = hasUnreadAsync.value ?? false;
                              if (!hasUnread) return const SizedBox.shrink();
                              return Positioned(
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status update button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showStatusUpdateDialog(order, firm),
                        icon: const Icon(Icons.update, size: 18),
                        label: const Text('Güncelle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderModel.getStatusLabel(status),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case OrderModel.statusPending:
        return Colors.orange;
      case OrderModel.statusConfirmed:
        return Colors.blue;
      case OrderModel.statusPickedUp:
        return Colors.purple;
      case OrderModel.statusMeasured:
        return Colors.teal;
      case OrderModel.statusOutForDelivery:
        return Colors.green;
      case OrderModel.statusDelivered:
        return Colors.grey;
      case OrderModel.statusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openRoute(OrderModel order) async {
    final addr = order.customerAddress;
    Uri uri;

    if (addr.latitude != null && addr.longitude != null) {
      // Use coordinates for precision
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${addr.latitude},${addr.longitude}');
    } else {
      // Use text address as fallback
      final encodedAddress = Uri.encodeComponent(addr.fullAddress);
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    }
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback or generic intent content
        debugPrint('Could not launch maps url: $uri');
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  void _showStatusUpdateDialog(OrderModel order, FirmModel firm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StatusUpdateSheet(
        order: order,
        firm: firm,
        onStatusChanged: () {
          Navigator.pop(ctx);
          ref.invalidate(firmOrdersProvider(firm.id));
        },
      ),
    );
  }

  Future<void> _showPrintLabelDialog(OrderModel order, FirmModel firm) async {
    final options = await showDialog<PrintOptions>(
      context: context,
      builder: (_) => const LabelCountDialog(),
    );
    
    if (options != null && mounted) {
      try {
        await PdfLabelGenerator.printLabels(
          count: options.count,
          order: order,
          firmName: firm.name,
          format: options.format,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Yazdırma hatası: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// ==================== STATUS UPDATE SHEET ====================
class _StatusUpdateSheet extends ConsumerStatefulWidget {
  final OrderModel order;
  final FirmModel firm;
  final VoidCallback onStatusChanged;

  const _StatusUpdateSheet({
    required this.order,
    required this.firm,
    required this.onStatusChanged,
  });

  @override
  ConsumerState<_StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends ConsumerState<_StatusUpdateSheet> {
  late String _selectedStatus;
  bool _showMeasurementForm = false;
  final Map<String, TextEditingController> _measurementControllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    
    // Initialize controllers for each item
    for (final item in widget.order.items) {
      _measurementControllers[item.serviceId] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _measurementControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
                Text(
                  _showMeasurementForm ? 'Ölçüm Bilgisi Gir' : 'Durumu Güncelle',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _showMeasurementForm
                  ? _buildMeasurementForm()
                  : _buildStatusSelection(),
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showMeasurementForm ? Colors.teal : AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _showMeasurementForm ? 'Ölçümü Onayla ve Müşteriye Bildir' : 'Durumu Kaydet',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelection() {
    final statuses = [
      OrderModel.statusPending,
      OrderModel.statusConfirmed,
      OrderModel.statusPickedUp,
      OrderModel.statusMeasured,
      OrderModel.statusOutForDelivery,
      OrderModel.statusDelivered,
      OrderModel.statusCancelled,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Yeni Durum Seçin:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ...statuses.map((status) {
          final isSelected = _selectedStatus == status;
          final color = _getStatusColor(status);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = status;
                    // Show measurement form if "Ölçüm Yapıldı" selected
                    if (status == OrderModel.statusMeasured) {
                      _showMeasurementForm = true;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(30) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? color : Colors.transparent,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          OrderModel.getStatusLabel(status),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                      ),
                      if (status == OrderModel.statusMeasured)
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      // SMS icon for statuses that send SMS
                      if (status == OrderModel.statusOutForDelivery)
                        const Icon(Icons.sms, size: 16, color: Colors.red),
                    ],
                  ),
                ),
              ),
              // SMS deduction warning
              if ((status == OrderModel.statusMeasured || status == OrderModel.statusOutForDelivery) && isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 36, bottom: 8),
                  child: Text(
                    '⚠️ 1 SMS bakiyenizden düşer',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
            ],
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMeasurementForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        TextButton.icon(
          onPressed: () => setState(() => _showMeasurementForm = false),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Duruma Dön'),
        ),
        const SizedBox(height: 16),

        // Customer info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.order.customerPhone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Items measurement form
        const Text('Hizmet Ölçümleri:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        ...widget.order.items.map((item) {
          final firmService = widget.firm.services.firstWhere(
            (s) => s.serviceName == item.serviceName,
            orElse: () => ServicePriceModel(
              serviceId: item.serviceId,
              serviceName: item.serviceName,
              price: item.unitPrice ?? 50.0,
              unit: item.unit,
              enabled: true,
            ),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${item.quantity} Adet', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _measurementControllers[item.serviceId],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}), // Trigger rebuild to update total
                        decoration: InputDecoration(
                          labelText: 'Ölçüm (${item.unit})',
                          hintText: 'Örn: 25',
                          border: const OutlineInputBorder(),
                          suffixText: item.unit,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Birim Fiyat', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(
                          '₺${firmService.price.toStringAsFixed(0)}/${item.unit}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        // Total calculation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tahmini Toplam:', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (widget.order.promoCode != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'İndirim Kodu: ${widget.order.promoCode}',
                        style: TextStyle(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_calculateDiscount(_calculateTotal()) > 0)
                    Text(
                      '₺${_calculateTotal().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.teal.withAlpha(150),
                      ),
                    ),
                  Text(
                    '₺${(_calculateTotal() - _calculateDiscount(_calculateTotal())).clamp(0, double.infinity).toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (final item in widget.order.items) {
      final controller = _measurementControllers[item.serviceId];
      final measured = double.tryParse(controller?.text ?? '') ?? 0;
      
      final firmService = widget.firm.services.firstWhere(
        (s) => s.serviceName == item.serviceName,
        orElse: () => ServicePriceModel(
          serviceId: item.serviceId,
          serviceName: item.serviceName,
          price: item.unitPrice ?? 50.0,
          unit: item.unit,
          enabled: true,
        ),
      );
      
      total += measured * firmService.price;
    }
    return total;
  }

  double _calculateDiscount(double total) {
    if (widget.order.promoCode == null) return 0;
    
    if (widget.order.promoCodeType == 'percent') {
      return total * ((widget.order.promoCodeValue ?? 0) / 100);
    } else {
      return widget.order.promoCodeValue ?? 0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case OrderModel.statusPending:
        return Colors.orange;
      case OrderModel.statusConfirmed:
        return Colors.blue;
      case OrderModel.statusPickedUp:
        return Colors.purple;
      case OrderModel.statusMeasured:
        return Colors.teal;
      case OrderModel.statusOutForDelivery:
        return Colors.green;
      case OrderModel.statusDelivered:
        return Colors.grey;
      case OrderModel.statusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);

    // Check if it's a demo order
    final isDemo = widget.order.id.startsWith('demo_');

    try {
      if (isDemo) {
        // Demo mode - just show success message without Firebase
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_showMeasurementForm 
                  ? 'DEMO: Ölçüm kaydedildi! (Gerçek modda SMS gönderilir)'
                  : 'DEMO: Sipariş durumu güncellendi: ${OrderModel.getStatusLabel(_selectedStatus)}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        widget.onStatusChanged();
        return;
      }

      final orderRepo = ref.read(orderRepositoryProvider);
      final firmRepo = ref.read(firmRepositoryProvider);

      if (_showMeasurementForm) {
        // Build measured items
        final List<OrderItemModel> measuredItems = [];
        for (final item in widget.order.items) {
          final controller = _measurementControllers[item.serviceId];
          final measured = double.tryParse(controller?.text ?? '') ?? 0;
          
          final firmService = widget.firm.services.firstWhere(
            (s) => s.serviceName == item.serviceName,
            orElse: () => ServicePriceModel(
              serviceId: item.serviceId,
              serviceName: item.serviceName,
              price: item.unitPrice ?? 50.0,
              unit: item.unit,
              enabled: true,
            ),
          );
          
          final itemTotal = measured * firmService.price;
          
          measuredItems.add(item.copyWith(
            measuredValue: measured,
            unitPrice: firmService.price,
            totalPrice: itemTotal,
          ));
        }

        final totalPrice = _calculateTotal();

        // Update order with measurement
        final result = await orderRepo.updateOrderMeasurement(
          orderId: widget.order.id,
          measuredItems: measuredItems,
          totalPrice: totalPrice,
        );

        // Send SMS to customer
        bool smsSent = false;
        final deducted = await firmRepo.deductSmsBalance(widget.firm.id, 1);
        if (deducted) {
          smsSent = await orderRepo.sendMeasurementSmsToCustomer(
            customerPhone: widget.order.customerPhone,
            firmName: widget.firm.name,
            measuredItems: measuredItems,
            totalPrice: result.finalPrice,
            discountAmount: result.discountAmount,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(smsSent
                  ? 'Ölçüm kaydedildi ve müşteriye SMS gönderildi!'
                  : 'Ölçüm kaydedildi! (SMS bakiyesi yetersiz)'),
              backgroundColor: smsSent ? Colors.green : Colors.orange,
            ),
          );
        }
      } else {
        // Just update status
        await orderRepo.updateOrderStatus(widget.order.id, _selectedStatus);
        
        // Send SMS for "Out for Delivery" status
        bool smsSent = false;
        if (_selectedStatus == OrderModel.statusOutForDelivery) {
          final deducted = await firmRepo.deductSmsBalance(widget.firm.id, 1);
          if (deducted) {
            final smsService = SmsService();
            // Use sendSecureSms for relationship check before sending
            smsSent = await smsService.sendSecureSms(
              firmId: widget.firm.id,
              phoneNumber: widget.order.customerPhone,
              message: '${widget.firm.name}: Siparisleriniz dagitima cikti. Teslimat icin hazir olun. Haliyikamaci',
            );
          }
        }
        
        // Send Push Notification to customer
        await NotificationService().sendOrderStatusNotification(
          customerId: widget.order.customerId,
          customerName: widget.order.customerName,
          orderId: widget.order.id,
          status: _selectedStatus,
          firmName: widget.firm.name,
        );
        
        // Also save notification to Firestore for in-app display
        final notificationRepo = NotificationRepository();
        await notificationRepo.notifyCustomerOrderStatus(
          customerId: widget.order.customerId,
          orderId: widget.order.id,
          status: _selectedStatus,
          firmName: widget.firm.name,
        );
        
        // ==============================
        // MUHASEBE: Sipariş Teslim Edildi ise Otomatik Gelir Kaydı
        // ==============================
        if (_selectedStatus == OrderModel.statusDelivered) {
          try {
            final accountingRepo = AccountingRepository();
            // Mükerrer kayıt kontrolü
            final hasEntry = await accountingRepo.hasOrderEntry(widget.order.id);
            if (!hasEntry && widget.order.totalPrice != null && widget.order.totalPrice! > 0) {
              await accountingRepo.createOrderIncomeEntry(
                firmId: widget.firm.id,
                orderId: widget.order.id,
                amount: widget.order.totalPrice!,
                orderDescription: 'Sipariş #${widget.order.id.substring(0, 6).toUpperCase()} - ${widget.order.customerName}',
              );
              debugPrint('✅ Muhasebe: Sipariş gelir kaydı oluşturuldu');
            }
          } catch (e) {
            debugPrint('⚠️ Muhasebe kaydı oluşturulamadı: $e');
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_selectedStatus == OrderModel.statusOutForDelivery && smsSent
                  ? 'Dağıtıma çıktı! Müşteriye SMS ve bildirim gönderildi.'
                  : 'Sipariş durumu güncellendi: ${OrderModel.getStatusLabel(_selectedStatus)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      widget.onStatusChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  void _openRoute(OrderModel order) async {
    final addr = order.customerAddress;

    final lat = addr.latitude;
    final lng = addr.longitude;

    try {
      if (lat != null && lng != null) {
        // Koordinat varsa
        final googleUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
        final googleWebUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
        
        // iOS support
        final appleUrl = Uri.parse('http://maps.apple.com/?daddr=$lat,$lng');

        if (await canLaunchUrl(googleUrl)) {
          await launchUrl(googleUrl);
        } else if (await canLaunchUrl(appleUrl)) {
          await launchUrl(appleUrl);
        } else {
          // Force external browser to avoid in-app webview
          await launchUrl(googleWebUrl, mode: LaunchMode.externalApplication);
        }
      } else {
        // Koordinat yoksa, adres metni
        final query = Uri.encodeComponent('${addr.fullAddress}, ${addr.district}, ${addr.city}');
        final googleUrl = Uri.parse('google.navigation:q=$query&mode=d');
        final googleWebUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

        if (await canLaunchUrl(googleUrl)) {
          await launchUrl(googleUrl);
        } else {
          await launchUrl(googleWebUrl, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harita açılamadı: $e')),
        );
      }
    }
  }
}
