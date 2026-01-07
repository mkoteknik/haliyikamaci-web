import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  ));
});

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  // Genel Mesajlaşma (Sipariş veya Destek)
  
  /// Belirtilen koleksiyondaki mesajları dinle (Realtime)
  /// NOTE: Uses 'timestamp' field for Admin Panel compatibility
  Stream<List<ChatMessageModel>> getMessages(String collectionPath) {
    return _firestore
        .collection(collectionPath)
        .orderBy('timestamp', descending: true) // Admin Panel uses 'timestamp'
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Mesaj gönder
  Future<void> sendMessage(String collectionPath, ChatMessageModel message) async {
    await _firestore.collection(collectionPath).add(message.toMap());
  }

  /// Mesajı okundu olarak işaretle
  Future<void> markAsRead(String collectionPath, String messageId) async {
    await _firestore
        .collection(collectionPath)
        .doc(messageId)
        .update({'isRead': true});
  }
}
