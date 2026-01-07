import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../../core/constants/app_constants.dart';

/// Seed Data Service - Populates initial data to Firebase
class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'haliyikamacimmbldatabase',
  );

  /// Initialize all seed data (call once on admin panel load)
  Future<void> initializeSeedData() async {
    await _seedServices();
    await _seedSmsPackages();
    await _seedVitrinPackages();
    await _seedCampaignPackages();
  }

  /// Seed Services if empty
  Future<void> _seedServices() async {
    final snapshot = await _firestore.collection(AppConstants.servicesCollection).limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // Already has data

    debugPrint('🌱 Seeding Services...');

    final services = [
      ServiceModel(id: '', name: 'Halı Yıkama', icon: 'carpet', units: ['m²', 'adet'], isActive: true, order: 1),
      ServiceModel(id: '', name: 'Koltuk Yıkama', icon: 'sofa', units: ['adet', 'takım'], isActive: true, order: 2),
      ServiceModel(id: '', name: 'Perde Yıkama', icon: 'curtain', units: ['m²', 'adet'], isActive: true, order: 3),
      ServiceModel(id: '', name: 'Yorgan Yıkama', icon: 'bed', units: ['adet'], isActive: true, order: 4),
      ServiceModel(id: '', name: 'Battaniye Yıkama', icon: 'blanket', units: ['adet'], isActive: true, order: 5),
    ];

    for (final service in services) {
      await _firestore.collection(AppConstants.servicesCollection).add(service.toMap());
    }
    debugPrint('✅ Services seeded!');
  }

  /// Seed SMS Packages if empty
  Future<void> _seedSmsPackages() async {
    final snapshot = await _firestore.collection(AppConstants.smsPackagesCollection).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    debugPrint('🌱 Seeding SMS Packages...');

    final packages = [
      SmsPackageModel(id: '', name: 'Deneme Paketi', smsCount: 50, price: 75.00, isActive: true, order: 1),
      SmsPackageModel(id: '', name: 'Başlangıç Paketi', smsCount: 100, price: 150.00, isActive: true, order: 2),
      SmsPackageModel(id: '', name: 'Standart Paket', smsCount: 250, price: 350.00, isActive: true, order: 3),
      SmsPackageModel(id: '', name: 'Profesyonel Paket', smsCount: 500, price: 650.00, isActive: true, order: 4),
      SmsPackageModel(id: '', name: 'Kurumsal Paket', smsCount: 1000, price: 1200.00, isActive: true, order: 5),
    ];

    for (final pkg in packages) {
      await _firestore.collection(AppConstants.smsPackagesCollection).add(pkg.toMap());
    }
    debugPrint('✅ SMS Packages seeded!');
  }

  /// Seed Vitrin Packages if empty
  Future<void> _seedVitrinPackages() async {
    final snapshot = await _firestore.collection(AppConstants.vitrinPackagesCollection).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    debugPrint('🌱 Seeding Vitrin Packages...');

    final packages = [
      VitrinPackageModel(
        id: '',
        name: 'Mini Vitrin',
        durationDays: 3,
        smsCost: 15,
        description: 'Ana sayfada 3 gün görünme',
        isActive: true,
        order: 1,
      ),
      VitrinPackageModel(
        id: '',
        name: 'Temel Vitrin',
        durationDays: 7,
        smsCost: 30,
        description: 'Ana sayfada 7 gün görünme',
        isActive: true,
        order: 2,
      ),
      VitrinPackageModel(
        id: '',
        name: 'Standart Vitrin',
        durationDays: 15,
        smsCost: 50,
        description: 'Ana sayfada 15 gün + öne çıkarma',
        isActive: true,
        order: 3,
      ),
      VitrinPackageModel(
        id: '',
        name: 'Premium Vitrin',
        durationDays: 30,
        smsCost: 80,
        description: 'Ana sayfada 30 gün + süper öne çıkarma',
        isActive: true,
        order: 4,
      ),
    ];

    for (final pkg in packages) {
      await _firestore.collection(AppConstants.vitrinPackagesCollection).add(pkg.toMap());
    }
    debugPrint('✅ Vitrin Packages seeded!');
  }

  /// Seed Campaign Packages if empty
  Future<void> _seedCampaignPackages() async {
    final snapshot = await _firestore.collection(AppConstants.campaignPackagesCollection).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    debugPrint('🌱 Seeding Campaign Packages...');

    final packages = [
      CampaignPackageModel(
        id: '',
        name: 'Mini Kampanya',
        durationDays: 3,
        smsCost: 10,
        description: 'Kampanyanız 3 gün yayında',
        isActive: true,
        order: 1,
      ),
      CampaignPackageModel(
        id: '',
        name: 'Temel Kampanya',
        durationDays: 7,
        smsCost: 20,
        description: 'Kampanyanız 7 gün yayında',
        isActive: true,
        order: 2,
      ),
      CampaignPackageModel(
        id: '',
        name: 'Standart Kampanya',
        durationDays: 15,
        smsCost: 35,
        description: 'Kampanyanız 15 gün + öne çıkarma',
        isActive: true,
        order: 3,
      ),
      CampaignPackageModel(
        id: '',
        name: 'Premium Kampanya',
        durationDays: 30,
        smsCost: 60,
        description: 'Kampanyanız 30 gün + süper öne çıkarma',
        isActive: true,
        order: 4,
      ),
    ];

    for (final pkg in packages) {
      await _firestore.collection(AppConstants.campaignPackagesCollection).add(pkg.toMap());
    }
    debugPrint('✅ Campaign Packages seeded!');
  }
}
