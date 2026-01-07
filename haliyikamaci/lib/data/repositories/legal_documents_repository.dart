import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/models.dart';

/// Repository for managing legal documents (Privacy Policy, KVKK, User Agreement, etc.)
class LegalDocumentsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'haliyikamacimmbldatabase');
  
  CollectionReference get _collection => _firestore.collection('legalDocuments');

  /// Get all legal documents
  Stream<List<LegalDocumentModel>> getAllDocuments() {
    return _collection
        .orderBy('type')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LegalDocumentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Get active legal documents only
  Stream<List<LegalDocumentModel>> getActiveDocuments() {
    return _collection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LegalDocumentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Get a specific document by type
  Future<LegalDocumentModel?> getDocumentByType(String type) async {
    final snapshot = await _collection
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return null;
    
    final doc = snapshot.docs.first;
    return LegalDocumentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Get document by type as stream
  Stream<LegalDocumentModel?> watchDocumentByType(String type) {
    return _collection
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return LegalDocumentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        });
  }

  /// Create or update a legal document
  Future<void> saveDocument(LegalDocumentModel document) async {
    if (document.id.isEmpty) {
      // Create new
      await _collection.add(document.toMap());
    } else {
      // Update existing
      await _collection.doc(document.id).update(document.toMap());
    }
  }

  /// Create a new document
  Future<String> createDocument(LegalDocumentModel document) async {
    final docRef = await _collection.add(document.toMap());
    return docRef.id;
  }

  /// Update an existing document
  Future<void> updateDocument(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _collection.doc(id).update(data);
  }

  /// Delete a legal document
  Future<void> deleteDocument(String id) async {
    await _collection.doc(id).delete();
  }

  /// Initialize default documents if they don't exist
  Future<void> initializeDefaultDocuments() async {
    final snapshot = await _collection.get();
    
    if (snapshot.docs.isEmpty) {
      // Create default documents
      final defaultDocs = [
        LegalDocumentModel(
          id: '',
          type: LegalDocumentModel.typePrivacyPolicy,
          title: 'Gizlilik Politikası',
          content: _defaultPrivacyPolicy,
          version: '1.0',
          updatedAt: DateTime.now(),
        ),
        LegalDocumentModel(
          id: '',
          type: LegalDocumentModel.typeKvkk,
          title: 'KVKK Aydınlatma Metni',
          content: _defaultKvkk,
          version: '1.0',
          updatedAt: DateTime.now(),
        ),
        LegalDocumentModel(
          id: '',
          type: LegalDocumentModel.typeUserAgreement,
          title: 'Kullanıcı Sözleşmesi',
          content: _defaultUserAgreement,
          version: '1.0',
          updatedAt: DateTime.now(),
        ),
      ];

      for (final doc in defaultDocs) {
        await _collection.add(doc.toMap());
      }
    }
  }

  // Default document contents
  static const String _defaultPrivacyPolicy = '''
# Gizlilik Politikası

## 1. Veri Toplama

Halı Yıkamacı uygulaması, hizmet sunabilmek için aşağıdaki bilgilerinizi toplar:
- Ad ve soyad
- Telefon numarası
- Adres bilgileri

Bu bilgiler yalnızca hizmet sağlamak amacıyla kullanılır.

## 2. Veri Güvenliği

Verileriniz güvenli sunucularda şifrelenerek saklanır. Üçüncü taraflarla izniniz olmadan paylaşılmaz.

## 3. Çerezler

Uygulama deneyiminizi iyileştirmek için çerezler kullanılabilir.

## 4. Veri Silme

Hesabınızı sildiğinizde tüm kişisel verileriniz kalıcı olarak silinir.

## 5. İletişim

Gizlilik politikamız hakkında sorularınız için destek@haliyikamaci.com adresinden bize ulaşabilirsiniz.
''';

  static const String _defaultKvkk = '''
# KVKK Aydınlatma Metni

6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") kapsamında, veri sorumlusu sıfatıyla aşağıdaki bilgilendirmeyi yapmaktayız.

## 1. Kişisel Verilerin İşlenme Amacı

Toplanan kişisel verileriniz;
- Hizmet sunumu ve sözleşme yükümlülüklerinin yerine getirilmesi
- Müşteri ilişkileri yönetimi
- Yasal yükümlülüklerin yerine getirilmesi
amaçlarıyla işlenmektedir.

## 2. Kişisel Verilerin Aktarılması

Kişisel verileriniz, yukarıda belirtilen amaçların gerçekleştirilmesi doğrultusunda;
- İş ortaklarımıza
- Tedarikçilerimize
- Yasal zorunluluk halinde yetkili kurum ve kuruluşlara
aktarılabilir.

## 3. Kişisel Veri Toplamanın Yöntemi ve Hukuki Sebebi

Kişisel verileriniz, mobil uygulama üzerinden elektronik ortamda toplanmaktadır.

## 4. KVKK Kapsamındaki Haklarınız

KVKK'nın 11. maddesi uyarınca;
- Kişisel verilerinizin işlenip işlenmediğini öğrenme
- İşlenmişse buna ilişkin bilgi talep etme
- Kişisel verilerinizin silinmesini isteme
haklarına sahipsiniz.

İletişim: destek@haliyikamaci.com
''';

  static const String _defaultUserAgreement = '''
# Kullanıcı Sözleşmesi

Bu sözleşme, Halı Yıkamacı uygulamasını kullanımınıza ilişkin şartları düzenler.

## 1. Hizmet Tanımı

Halı Yıkamacı, halı yıkama firmaları ile müşterileri buluşturan bir platform hizmetidir.

## 2. Kullanıcı Yükümlülükleri

Kullanıcılar;
- Doğru ve güncel bilgi sağlamakla
- Uygulamayı yasal amaçlarla kullanmakla
- Diğer kullanıcıların haklarına saygı göstermekle
yükümlüdür.

## 3. Hizmet Şartları

Uygulama üzerinden verilen siparişler, firmalar tarafından yerine getirilir. Platform, aracı konumundadır.

## 4. Sorumluluk Sınırlaması

Platform, firmalar tarafından sağlanan hizmetlerin kalitesinden doğrudan sorumlu değildir.

## 5. Değişiklikler

Bu sözleşme şartları önceden bildirimle değiştirilebilir.

## 6. İletişim

Sorularınız için: destek@haliyikamaci.com
''';
}
