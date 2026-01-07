import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/customer_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';

/// Customer Notifications Screen - Müşteri Bildirimleri
class CustomerNotificationsScreen extends ConsumerWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirimler')),
        body: const Center(child: Text('Giriş yapmanız gerekiyor')),
      );
    }

    final notificationRepo = ref.watch(notificationRepositoryProvider);
    final notificationsStream = notificationRepo.getNotifications(
      userId: user.uid,
      userType: 'customer',
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: CustomerTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü okundu işaretle',
            onPressed: () async {
              await notificationRepo.markAllAsRead(
                userId: user.uid,
                userType: 'customer',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tüm bildirimler okundu işaretlendi'),
                    backgroundColor: CustomerTheme.success,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Okunanları sil',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Okunanları Sil'),
                  content: const Text('Okunmuş tüm bildirimler silinsin mi?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await notificationRepo.deleteAllReadNotifications(
                  userId: user.uid,
                  userType: 'customer',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Okunan bildirimler silindi')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Hata: ${snapshot.error}'),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sipariş durumları burada görünecek',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationCard(
                notification: notification,
                onDelete: () async {
                  await notificationRepo.deleteNotification(notification.id);
                },
                onTap: () async {
                  // Mark as read
                  if (!notification.isRead) {
                    await notificationRepo.markAsRead(notification.id);
                  }
                  // Navigate based on type
                  _handleNotificationTap(context, notification);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Navigate to relevant screen based on notification type
    switch (notification.type) {
      case NotificationModel.typeOrder:
        // Could navigate to order details
        final orderId = notification.data['orderId'];
        if (orderId != null) {
          // Navigate to orders tab or order detail
          Navigator.pop(context); // Go back and user can check orders
        }
        break;
      case NotificationModel.typeMessage:
        // Navigate to support/messages
        Navigator.pop(context);
        break;
      default:
        // Just mark as read
        break;
    }
  }
}

/// Individual Notification Card
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.white : CustomerTheme.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? Colors.grey[200]! : CustomerTheme.primary.withAlpha(50),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 40, top: 16, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getIconBackgroundColor(notification.type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(notification.type),
                      color: _getIconColor(notification.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: CustomerTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Delete Button (Top Right)
            Positioned(
              top: 0,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Sil',
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case NotificationModel.typeOrder:
        return Icons.shopping_bag;
      case NotificationModel.typeMessage:
        return Icons.chat_bubble;
      case NotificationModel.typeCampaign:
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case NotificationModel.typeOrder:
        return CustomerTheme.primary;
      case NotificationModel.typeMessage:
        return Colors.blue;
      case NotificationModel.typeCampaign:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case NotificationModel.typeOrder:
        return CustomerTheme.primary.withAlpha(30);
      case NotificationModel.typeMessage:
        return Colors.blue.withAlpha(30);
      case NotificationModel.typeCampaign:
        return Colors.orange.withAlpha(30);
      default:
        return Colors.grey.withAlpha(30);
    }
  }
}
