import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Notification Service - FCM Push Notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  late final FirebaseFirestore _firestore;
  bool _initialized = false;

  /// Initialize FCM
  Future<void> initialize() async {
    if (_initialized) return;

    _firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'haliyikamacimmbldatabase',
    );

    // Request permission
    await _requestPermission();

    // Get FCM token
    final token = await getToken();
    debugPrint('FCM Token: $token');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      // Token will be saved when user logs in
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages (tap to open)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    _initialized = true;
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      // For web, need VAPID key - skip for now if web
      if (kIsWeb) {
        // Web requires VAPID key configuration
        return await _messaging.getToken();
      }
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to user document
  Future<void> saveTokenToUser({
    required String userId,
    required String userType, // 'customers' or 'firms'
  }) async {
    final token = await getToken();
    if (token == null) return;

    try {
      await _firestore.collection(userType).doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM token saved for $userType/$userId');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');
    
    // In foreground, show a local notification or snackbar
    // For now just log it - can add flutter_local_notifications later
  }

  /// Handle message when app opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.data}');
    
    // Navigate to relevant screen based on message data
    // Can be implemented with navigation service
  }

  /// Send notification to a user (via Cloud Function or server)
  /// Note: Direct device-to-device messaging is not supported
  /// This method saves notification to Firestore, and a Cloud Function
  /// can be set up to send the actual push notification
  Future<void> queueNotification({
    required String targetUserId,
    required String targetUserType,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      await _firestore.collection('notification_queue').add({
        'targetUserId': targetUserId,
        'targetUserType': targetUserType,
        'title': title,
        'body': body,
        'data': data ?? {},
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Notification queued for $targetUserType/$targetUserId');
    } catch (e) {
      debugPrint('Error queuing notification: $e');
    }
  }

  /// Send order status notification
  Future<void> sendOrderStatusNotification({
    required String customerId,
    required String customerName,
    required String orderId,
    required String status,
    String? firmName,
    double? totalPrice,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'confirmed':
        title = 'Sipariş Onaylandı ✅';
        body = '$firmName siparişinizi onayladı.';
        break;
      case 'picked_up':
        title = 'Teslim Alındı 📦';
        body = 'Ürünleriniz $firmName tarafından teslim alındı.';
        break;
      case 'measured':
        title = 'Ölçüm Tamamlandı 📏';
        body = totalPrice != null
            ? 'Toplam tutar: ₺${totalPrice.toStringAsFixed(0)}'
            : 'Ölçüm yapıldı, fiyat belirlendi.';
        break;
      case 'out_for_delivery':
        title = 'Dağıtıma Çıktı 🚚';
        body = 'Siparişiniz yola çıktı! Hazır olun.';
        break;
      case 'delivered':
        title = 'Teslim Edildi ✨';
        body = 'Siparişiniz teslim edildi. İyi günlerde kullanın!';
        break;
      default:
        title = 'Sipariş Güncellendi';
        body = 'Siparişinizin durumu güncellendi.';
    }

    await queueNotification(
      targetUserId: customerId,
      targetUserType: 'customers',
      title: title,
      body: body,
      data: {'type': 'order', 'orderId': orderId, 'status': status},
    );
  }

  /// Send new order notification to firm
  Future<void> sendNewOrderNotificationToFirm({
    required String firmId,
    required String customerName,
    required String orderSummary,
    required String orderId,
  }) async {
    await queueNotification(
      targetUserId: firmId,
      targetUserType: 'firms',
      title: 'Yeni Sipariş 🎉',
      body: '$customerName: $orderSummary',
      data: {'type': 'new_order', 'orderId': orderId},
    );
  }

  /// Send support message notification
  Future<void> sendSupportMessageNotification({
    required String targetUserId,
    required String targetUserType,
    required String senderName,
    required String ticketId,
  }) async {
    await queueNotification(
      targetUserId: targetUserId,
      targetUserType: targetUserType,
      title: 'Yeni Destek Mesajı 💬',
      body: '$senderName size mesaj gönderdi.',
      data: {'type': 'support', 'ticketId': ticketId},
    );
  }
}
