import 'package:cloud_firestore/cloud_firestore.dart';

/// Firma Muhasebe Giriş Modeli
class AccountingEntryModel {
  final String id;
  final String firmId;
  final String type; // 'income' veya 'expense'
  final String category; // Kategori
  final String title;
  final double amount;
  final String? description;
  final String? relatedOrderId; // İlgili sipariş ID (varsa)
  final String? relatedVitrinId; // İlgili vitrin ID (varsa)
  final String? relatedCampaignId; // İlgili kampanya ID (varsa)
  final bool isAutomatic; // Otomatik mı manuel mi?
  final DateTime date;
  final DateTime createdAt;

  // Gelir kategorileri
  static const String categoryOrder = 'order';
  static const String categoryManualIncome = 'manual_income';

  // Gider kategorileri
  static const String categoryVitrin = 'vitrin';
  static const String categoryCampaign = 'campaign';
  static const String categoryManualExpense = 'manual_expense';

  AccountingEntryModel({
    required this.id,
    required this.firmId,
    required this.type,
    required this.category,
    required this.title,
    required this.amount,
    this.description,
    this.relatedOrderId,
    this.relatedVitrinId,
    this.relatedCampaignId,
    this.isAutomatic = false,
    required this.date,
    required this.createdAt,
  });

  factory AccountingEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return AccountingEntryModel(
      id: id,
      firmId: map['firmId'] ?? '',
      type: map['type'] ?? 'expense',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'],
      relatedOrderId: map['relatedOrderId'],
      relatedVitrinId: map['relatedVitrinId'],
      relatedCampaignId: map['relatedCampaignId'],
      isAutomatic: map['isAutomatic'] ?? false,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'type': type,
      'category': category,
      'title': title,
      'amount': amount,
      'description': description,
      'relatedOrderId': relatedOrderId,
      'relatedVitrinId': relatedVitrinId,
      'relatedCampaignId': relatedCampaignId,
      'isAutomatic': isAutomatic,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Kategori etiketi
  String get categoryLabel {
    switch (category) {
      case categoryOrder:
        return 'Sipariş Geliri';
      case categoryManualIncome:
        return 'Manuel Gelir';
      case categoryVitrin:
        return 'Vitrin Gideri';
      case categoryCampaign:
        return 'Kampanya Gideri';
      case categoryManualExpense:
        return 'Manuel Gider';
      default:
        return category;
    }
  }

  // Tür etiketi
  String get typeLabel => type == 'income' ? 'Gelir' : 'Gider';

  // Gelir mi?
  bool get isIncome => type == 'income';

  // Gider mi?
  bool get isExpense => type == 'expense';

  // Copy with
  AccountingEntryModel copyWith({
    String? firmId,
    String? type,
    String? category,
    String? title,
    double? amount,
    String? description,
    String? relatedOrderId,
    String? relatedVitrinId,
    String? relatedCampaignId,
    bool? isAutomatic,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return AccountingEntryModel(
      id: id,
      firmId: firmId ?? this.firmId,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      relatedVitrinId: relatedVitrinId ?? this.relatedVitrinId,
      relatedCampaignId: relatedCampaignId ?? this.relatedCampaignId,
      isAutomatic: isAutomatic ?? this.isAutomatic,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
