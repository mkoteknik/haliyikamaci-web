import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/accounting_entry_model.dart';

/// Firma Muhasebe Repository
class AccountingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );

  /// Firma muhasebe koleksiyonu referansı
  CollectionReference get _accountingRef =>
      _firestore.collection('firm_accounting');

  /// Firma için tüm muhasebe girişlerini stream olarak getir
  Stream<List<AccountingEntryModel>> getEntriesByFirm(String firmId) {
    return _accountingRef
        .where('firmId', isEqualTo: firmId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AccountingEntryModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Yeni muhasebe girişi ekle
  Future<String> addEntry(AccountingEntryModel entry) async {
    final doc = await _accountingRef.add(entry.toMap());
    return doc.id;
  }

  /// Muhasebe girişini güncelle
  Future<void> updateEntry(String id, Map<String, dynamic> data) async {
    await _accountingRef.doc(id).update(data);
  }

  /// Muhasebe girişini sil
  Future<void> deleteEntry(String id) async {
    await _accountingRef.doc(id).delete();
  }

  /// Sipariş tamamlandığında otomatik gelir kaydı oluştur
  Future<String> createOrderIncomeEntry({
    required String firmId,
    required String orderId,
    required double amount,
    required String orderDescription,
  }) async {
    final entry = AccountingEntryModel(
      id: '',
      firmId: firmId,
      type: 'income',
      category: AccountingEntryModel.categoryOrder,
      title: 'Sipariş Geliri',
      amount: amount,
      description: orderDescription,
      relatedOrderId: orderId,
      isAutomatic: true,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return await addEntry(entry);
  }

  /// Vitrin satın alındığında otomatik gider kaydı oluştur
  Future<String> createVitrinExpenseEntry({
    required String firmId,
    required String vitrinId,
    required double amount,
    required String vitrinName,
  }) async {
    final entry = AccountingEntryModel(
      id: '',
      firmId: firmId,
      type: 'expense',
      category: AccountingEntryModel.categoryVitrin,
      title: 'Vitrin Gideri',
      amount: amount,
      description: vitrinName,
      relatedVitrinId: vitrinId,
      isAutomatic: true,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return await addEntry(entry);
  }

  /// Kampanya satın alındığında otomatik gider kaydı oluştur
  Future<String> createCampaignExpenseEntry({
    required String firmId,
    required String campaignId,
    required double amount,
    required String campaignName,
  }) async {
    final entry = AccountingEntryModel(
      id: '',
      firmId: firmId,
      type: 'expense',
      category: AccountingEntryModel.categoryCampaign,
      title: 'Kampanya Gideri',
      amount: amount,
      description: campaignName,
      relatedCampaignId: campaignId,
      isAutomatic: true,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return await addEntry(entry);
  }

  /// Manuel gelir girişi ekle
  Future<String> createManualIncomeEntry({
    required String firmId,
    required String title,
    required double amount,
    String? description,
  }) async {
    final entry = AccountingEntryModel(
      id: '',
      firmId: firmId,
      type: 'income',
      category: AccountingEntryModel.categoryManualIncome,
      title: title,
      amount: amount,
      description: description,
      isAutomatic: false,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return await addEntry(entry);
  }

  /// Manuel gider girişi ekle
  Future<String> createManualExpenseEntry({
    required String firmId,
    required String title,
    required double amount,
    String? description,
  }) async {
    final entry = AccountingEntryModel(
      id: '',
      firmId: firmId,
      type: 'expense',
      category: AccountingEntryModel.categoryManualExpense,
      title: title,
      amount: amount,
      description: description,
      isAutomatic: false,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return await addEntry(entry);
  }

  /// Belirli bir siparişe ait muhasebe girişini kontrol et
  Future<bool> hasOrderEntry(String orderId) async {
    final query = await _accountingRef
        .where('relatedOrderId', isEqualTo: orderId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Belirli bir vitrine ait muhasebe girişini kontrol et
  Future<bool> hasVitrinEntry(String vitrinId) async {
    final query = await _accountingRef
        .where('relatedVitrinId', isEqualTo: vitrinId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Belirli bir kampanyaya ait muhasebe girişini kontrol et
  Future<bool> hasCampaignEntry(String campaignId) async {
    final query = await _accountingRef
        .where('relatedCampaignId', isEqualTo: campaignId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Firma istatistiklerini hesapla (toplam gelir, toplam gider, net)
  Future<Map<String, double>> getStats(String firmId) async {
    final entries = await _accountingRef
        .where('firmId', isEqualTo: firmId)
        .get();

    double totalIncome = 0;
    double totalExpense = 0;

    for (final doc in entries.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      final type = data['type'] as String?;

      if (type == 'income') {
        totalIncome += amount;
      } else if (type == 'expense') {
        totalExpense += amount;
      }
    }

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netBalance': totalIncome - totalExpense,
    };
  }
}
