import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Model - Bildirim veri yapısı
class NotificationModel {
  final String id;
  final String userId;
  final String userType; // 'customer' or 'firm'
  final String type; // 'order', 'message', 'campaign', 'system'
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  // Notification types
  static const String typeOrder = 'order';
  static const String typeMessage = 'message';
  static const String typeCampaign = 'campaign';
  static const String typeSystem = 'system';

  NotificationModel({
    required this.id,
    required this.userId,
    required this.userType,
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      userType: map['userType'] ?? 'customer',
      type: map['type'] ?? 'system',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userType': userType,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      userType: userType,
      type: type,
      title: title,
      body: body,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  /// Get icon for notification type
  String get iconName {
    switch (type) {
      case typeOrder:
        return 'shopping_bag';
      case typeMessage:
        return 'chat';
      case typeCampaign:
        return 'local_offer';
      default:
        return 'notifications';
    }
  }

  /// Get relative time string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Az önce';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} dk önce';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} saat önce';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
    }
  }
}
