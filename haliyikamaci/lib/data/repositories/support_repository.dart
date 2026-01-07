import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/models.dart';

/// Support Repository - FAQ ve Ticket işlemleri
class SupportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );

  // Collections
  static const String _faqCollection = 'faq';
  static const String _ticketsCollection = 'tickets';

  // ==================== FAQ Operations ====================

  /// Get active FAQs
  Stream<List<FaqModel>> getActiveFaqs() {
    return _firestore
        .collection(_faqCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FaqModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Find FAQ by keywords
  Future<FaqModel?> findFaqByKeywords(String query) async {
    final queryLower = query.toLowerCase();
    final words = queryLower.split(' ');

    final snapshot = await _firestore
        .collection(_faqCollection)
        .where('isActive', isEqualTo: true)
        .get();

    FaqModel? bestMatch;
    int bestScore = 0;

    for (final doc in snapshot.docs) {
      final faq = FaqModel.fromMap(doc.data(), doc.id);
      int score = 0;

      // Check keywords match
      for (final keyword in faq.keywords) {
        if (queryLower.contains(keyword.toLowerCase())) {
          score += 2;
        }
        for (final word in words) {
          if (keyword.toLowerCase().contains(word) && word.length > 2) {
            score += 1;
          }
        }
      }

      // Check question contains words
      for (final word in words) {
        if (faq.question.toLowerCase().contains(word) && word.length > 2) {
          score += 1;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = faq;
      }
    }

    // Return only if score is meaningful
    return bestScore >= 2 ? bestMatch : null;
  }

  /// Create FAQ (Admin)
  Future<String> createFaq(FaqModel faq) async {
    final doc = await _firestore.collection(_faqCollection).add(faq.toMap());
    return doc.id;
  }

  /// Update FAQ (Admin)
  Future<void> updateFaq(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_faqCollection).doc(id).update(data);
  }

  /// Delete FAQ (Admin)
  Future<void> deleteFaq(String id) async {
    await _firestore.collection(_faqCollection).doc(id).delete();
  }

  // ==================== Ticket Operations ====================

  /// Create new ticket
  Future<String> createTicket(TicketModel ticket) async {
    final doc = await _firestore.collection(_ticketsCollection).add(ticket.toMap());
    return doc.id;
  }

  /// Get ticket by ID
  Future<TicketModel?> getTicketById(String id) async {
    final doc = await _firestore.collection(_ticketsCollection).doc(id).get();
    if (doc.exists) {
      return TicketModel.fromMap(doc.data()!, id);
    }
    return null;
  }

  /// Get tickets for firm (from customers)
  Stream<List<TicketModel>> getTicketsForFirm(String firmId) {
    return _firestore
        .collection(_ticketsCollection)
        .where('receiverId', isEqualTo: firmId)
        .where('channel', isEqualTo: TicketModel.channelCustomerFirm)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get tickets for admin (from firms)
  Stream<List<TicketModel>> getTicketsForAdmin() {
    return _firestore
        .collection(_ticketsCollection)
        .where('channel', isEqualTo: TicketModel.channelFirmAdmin)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get user's tickets (sent)
  Stream<List<TicketModel>> getUserTickets(String userId) {
    return _firestore
        .collection(_ticketsCollection)
        .where('senderId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Update ticket
  Future<void> updateTicket(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _firestore.collection(_ticketsCollection).doc(id).update(data);
  }

  /// Close ticket
  Future<void> closeTicket(String id) async {
    await updateTicket(id, {'status': TicketModel.statusClosed});
  }

  // ==================== Message Operations ====================

  /// Get messages for ticket
  Stream<List<TicketMessageModel>> getTicketMessages(String ticketId) {
    return _firestore
        .collection(_ticketsCollection)
        .doc(ticketId)
        .collection('messages')
        .orderBy('createdAt', descending: true) // Chat screen usually expects reverse:true or needs descending
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TicketMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Send message
  Future<String> sendMessage(TicketMessageModel message) async {
    // Add message to subcollection
    final doc = await _firestore
        .collection(_ticketsCollection)
        .doc(message.ticketId)
        .collection('messages')
        .add(message.toMap());

    // Update ticket's last message, status, and updated time
    await updateTicket(message.ticketId, {
      'lastMessage': message.message,
      'status': message.senderType == 'customer' || message.senderType == 'firm'
          ? TicketModel.statusOpen
          : TicketModel.statusAnswered,
      'unreadCount': FieldValue.increment(1), // Optional: increment unread count for receiver
    });

    return doc.id;
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String ticketId, String readerId) async {
    final snapshot = await _firestore
        .collection(_ticketsCollection)
        .doc(ticketId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    bool needsCommit = false;

    for (final doc in snapshot.docs) {
      // Only mark as read if it's not the sender's own message
      if (doc.data()['senderId'] != readerId) {
        batch.update(doc.reference, {'isRead': true});
        needsCommit = true;
      }
    }

    if (needsCommit) {
      await batch.commit();
      // Reset unread count on the ticket itself if needed
      // Note: This logic depends on who is viewing. 
      // Typically, we check if the LAST message was from providing side.
      // For simplicity, we just reset or decrement. 
      // admin resets unreadCount when opening. Customer might not need this counter as much.
    }
  }

  // ==================== Demo Data ====================

  /// Get demo FAQs for testing
  List<FaqModel> getDemoFaqs() {
    return [
      FaqModel(
        id: 'faq_1',
        category: 'teslimat',
        question: 'Teslimat süresi ne kadar?',
        answer: 'Halılarınız teslim alındıktan sonra ortalama 3-5 iş günü içinde temizlenip teslim edilir.',
        keywords: ['teslimat', 'süre', 'kaç gün', 'ne zaman', 'teslim'],
        order: 1,
      ),
      FaqModel(
        id: 'faq_2',
        category: 'fiyat',
        question: 'Fiyatlar nasıl belirleniyor?',
        answer: 'Fiyatlar halınızın m² ölçüsüne göre hesaplanır. Kesin fiyat, teslim aldıktan sonra ölçüm yapılarak belirlenir.',
        keywords: ['fiyat', 'ücret', 'ne kadar', 'maliyet', 'para'],
        order: 2,
      ),
      FaqModel(
        id: 'faq_3',
        category: 'odeme',
        question: 'Hangi ödeme yöntemlerini kabul ediyorsunuz?',
        answer: 'Nakit, kredi kartı ve havale/EFT ile ödeme yapabilirsiniz. Ödeme teslimat sırasında alınır.',
        keywords: ['ödeme', 'nakit', 'kart', 'havale', 'eft', 'kredi'],
        order: 3,
      ),
      FaqModel(
        id: 'faq_4',
        category: 'siparis',
        question: 'Sipariş nasıl verilir?',
        answer: 'Uygulama üzerinden hizmet ve firma seçerek kolayca sipariş verebilirsiniz. Firma sizinle iletişime geçecektir.',
        keywords: ['sipariş', 'nasıl', 'vermek', 'siparis'],
        order: 4,
      ),
      FaqModel(
        id: 'faq_5',
        category: 'iptal',
        question: 'Siparişimi iptal edebilir miyim?',
        answer: 'Halılarınız teslim alınmadan önce siparişinizi iptal edebilirsiniz. Teslim alındıktan sonra iptal mümkün değildir.',
        keywords: ['iptal', 'vazgeç', 'istemiyorum', 'cancel'],
        order: 5,
      ),
    ];
  }
}
