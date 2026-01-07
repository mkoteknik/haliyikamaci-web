import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';

/// Firm Notifications Screen - Firma Bildirimleri
class FirmNotificationsScreen extends ConsumerWidget {
  const FirmNotificationsScreen({super.key});

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
      userType: 'firm',
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tümünü okundu işaretle',
            onPressed: () async {
              await notificationRepo.markAllAsRead(
                userId: user.uid,
                userType: 'firm',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tüm bildirimler okundu işaretlendi'),
                    backgroundColor: AppTheme.accentGreen,
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
                  userType: 'firm',
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
                    'Yeni siparişler burada görünecek',
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
              return _FirmNotificationCard(
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
    switch (notification.type) {
      case NotificationModel.typeOrder:
        // Navigate to orders tab
        Navigator.pop(context);
        break;
      case NotificationModel.typeMessage:
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }
}

/// Individual Notification Card for Firm
class _FirmNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FirmNotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Modern, clean design with light backgrounds
    final accentColor = _getAccentColor(notification.type);
    
    return Card(
      elevation: notification.isRead ? 0 : 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? Colors.grey[200]! : accentColor.withAlpha(80),
          width: notification.isRead ? 1 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // Subtle gradient for unread
                gradient: notification.isRead ? null : LinearGradient(
                  colors: [accentColor.withAlpha(15), Colors.white],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  // Left colored bar for unread
                  if (!notification.isRead)
                    Container(
                      width: 4,
                      height: 80,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: notification.isRead ? 16 : 12,
                        right: 40, // Space for delete button
                        top: 16, 
                        bottom: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getIcon(notification.type),
                              color: accentColor,
                              size: 22,
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
                                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.grey[850],
                                        ),
                                      ),
                                    ),
                                    if (!notification.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: accentColor,
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
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
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
                  ),
                ],
              ),
            ),
            // Delete Button (Top Right)
            Positioned(
              top: 0,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.blueAccent), // Blue for firm? Or Red?
                // User asked for "Left Top Red Trash Can" in prompt
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  foregroundColor: Colors.red, // Override with red
                ),
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

  Color _getAccentColor(String type) {
    switch (type) {
      case NotificationModel.typeOrder:
        return AppTheme.accentGreen;
      case NotificationModel.typeMessage:
        return const Color(0xFF5C6BC0); // Modern indigo
      case NotificationModel.typeCampaign:
        return const Color(0xFFFF8A65); // Warm coral
      default:
        return const Color(0xFF78909C); // Blue grey
    }
  }
}
