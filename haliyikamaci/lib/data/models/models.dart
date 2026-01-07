import 'package:cloud_firestore/cloud_firestore.dart';

export 'notification_model.dart';
export 'accounting_entry_model.dart';

/// User Model - Tüm kullanıcılar (firma + müşteri)
class UserModel {
  final String uid;
  final String phone;
  final String userType; // 'firm', 'customer', 'admin'
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      phone: map['phone'] ?? '',
      userType: map['userType'] ?? 'customer',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'userType': userType,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}

/// Address Model
/// Address Model
class AddressModel {
  final String title; // 'Ev', 'İş' vb.
  final String city;
  final String district;
  final String area;
  final String neighborhood;
  final String fullAddress;
  final double? latitude;
  final double? longitude;

  AddressModel({
    this.title = 'Ev',
    required this.city,
    required this.district,
    required this.area,
    required this.neighborhood,
    required this.fullAddress,
    this.latitude,
    this.longitude,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      title: map['title'] ?? 'Ev',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      area: map['area'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'city': city,
      'district': district,
      'area': area,
      'neighborhood': neighborhood,
      'fullAddress': fullAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  String get shortAddress => '$title ($district)';
  String get fullAddressDisplay => '$title: $fullAddress, $neighborhood, $district, $city';
}

/// Service Price Model
class ServicePriceModel {
  final String serviceId;
  final String serviceName;
  final bool enabled;
  final String unit; // 'm2', 'adet', 'takım'
  final double price;

  ServicePriceModel({
    required this.serviceId,
    required this.serviceName,
    required this.enabled,
    required this.unit,
    required this.price,
  });

  factory ServicePriceModel.fromMap(Map<String, dynamic> map) {
    return ServicePriceModel(
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      enabled: map['enabled'] ?? false,
      unit: map['unit'] ?? 'adet',
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'enabled': enabled,
      'unit': unit,
      'price': price,
    };
  }
}

/// Firm Model
class FirmModel {
  final String id;
  final String uid;
  final String name;
  final String? logo;
  final String? coverImage;
  final String phone;
  final String? whatsapp;
  final String? taxNumber;
  final AddressModel address;
  final int smsBalance;
  final List<ServicePriceModel> services;
  final List<String> paymentMethods; // 'cash', 'card', 'transfer'
  final double rating;
  final int reviewCount;
  final bool isApproved;
  final DateTime createdAt;
  
  // Sadakat sistemi
  final bool loyaltyEnabled; // Sadakat programı aktif mi?
  final double loyaltyPercentage; // Sipariş tutarının yüzde kaçı puan olarak verilecek (örn: 10.0 = %10)

  // Payment method constants
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentTransfer = 'transfer';

  static String getPaymentMethodLabel(String method) {
    switch (method) {
      case paymentCash: return 'Nakit';
      case paymentCard: return 'Kapıda Kredi Kartı';
      case paymentTransfer: return 'Havale/EFT';
      default: return method;
    }
  }

  FirmModel({
    required this.id,
    required this.uid,
    required this.name,
    this.logo,
    this.coverImage,
    required this.phone,
    this.whatsapp,
    this.taxNumber,
    required this.address,
    this.smsBalance = 0,
    this.services = const [],
    this.paymentMethods = const [paymentCash], // Default: Nakit
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isApproved = false,
    required this.createdAt,
    this.loyaltyEnabled = false,
    this.loyaltyPercentage = 10.0, // Default %10
  });

  factory FirmModel.fromMap(Map<String, dynamic> map, String id) {
    return FirmModel(
      id: id,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      logo: map['logo'],
      coverImage: map['coverImage'],
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'],
      taxNumber: map['taxNumber'],
      address: AddressModel.fromMap(map['address'] ?? {}),
      smsBalance: map['smsBalance'] ?? 0,
      services: (map['services'] as List<dynamic>?)
              ?.map((s) => ServicePriceModel.fromMap(s))
              .toList() ??
          [],
      paymentMethods: (map['paymentMethods'] as List<dynamic>?)?.cast<String>() ?? [paymentCash],
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isApproved: map['isApproved'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      loyaltyEnabled: map['loyaltyEnabled'] ?? false,
      loyaltyPercentage: (map['loyaltyPercentage'] ?? 10.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'logo': logo,
      'coverImage': coverImage,
      'phone': phone,
      'whatsapp': whatsapp,
      'taxNumber': taxNumber,
      'address': address.toMap(),
      'smsBalance': smsBalance,
      'services': services.map((s) => s.toMap()).toList(),
      'paymentMethods': paymentMethods,
      'rating': rating,
      'reviewCount': reviewCount,
      'isApproved': isApproved,
      'createdAt': Timestamp.fromDate(createdAt),
      'loyaltyEnabled': loyaltyEnabled,
      'loyaltyPercentage': loyaltyPercentage,
    };
  }

  FirmModel copyWith({
    String? name,
    String? logo,
    String? coverImage,
    String? phone,
    String? whatsapp,
    String? taxNumber,
    AddressModel? address,
    int? smsBalance,
    List<ServicePriceModel>? services,
    List<String>? paymentMethods,
    double? rating,
    int? reviewCount,
    bool? isApproved,
    bool? loyaltyEnabled,
    double? loyaltyPercentage,
  }) {
    return FirmModel(
      id: id,
      uid: uid,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      coverImage: coverImage ?? this.coverImage,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      taxNumber: taxNumber ?? this.taxNumber,
      address: address ?? this.address,
      smsBalance: smsBalance ?? this.smsBalance,
      services: services ?? this.services,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt,
      loyaltyEnabled: loyaltyEnabled ?? this.loyaltyEnabled,
      loyaltyPercentage: loyaltyPercentage ?? this.loyaltyPercentage,
    );
  }
}

/// Customer Model
class CustomerModel {
  final String id;
  final String uid;
  final String name;
  final String surname;
  final String phone;
  final List<AddressModel> addresses; // Kayıtlı adresler
  final int selectedAddressIndex; // Seçili adresin indeksi
  final DateTime createdAt;
  final int loyaltyPoints; // Toplam sadakat puanı
  final Map<String, int> firmLoyaltyPoints; // Firma bazlı sadakat puanları {firmId: puan}
  final String? profileImage; // Profil resmi
  final List<String> favoriteFirmIds; // Favori firma ID'leri

  CustomerModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.surname,
    required this.phone,
    List<AddressModel>? addresses,
    this.selectedAddressIndex = 0,
    required this.createdAt,
    this.loyaltyPoints = 0,
    Map<String, int>? firmLoyaltyPoints,
    this.profileImage,
    this.favoriteFirmIds = const [],
    AddressModel? address, // Legacy support
  })  : addresses = addresses ?? (address != null ? [address] : []),
        firmLoyaltyPoints = firmLoyaltyPoints ?? {};

  // Get current active address
  AddressModel get address => addresses.isNotEmpty 
      ? (selectedAddressIndex < addresses.length ? addresses[selectedAddressIndex] : addresses.first)
      : AddressModel(city: '', district: '', area: '', neighborhood: '', fullAddress: '');

  String get fullName => '$name $surname';

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle migration from single address to list
    List<AddressModel> addressList = [];
    if (map['addresses'] != null) {
      addressList = (map['addresses'] as List<dynamic>)
          .map((a) => AddressModel.fromMap(a))
          .toList();
    } else if (map['address'] != null) {
      addressList = [AddressModel.fromMap(map['address'])];
    }

    return CustomerModel(
      id: id,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      phone: map['phone'] ?? '',
      addresses: addressList,
      selectedAddressIndex: map['selectedAddressIndex'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      firmLoyaltyPoints: Map<String, int>.from(map['firmLoyaltyPoints'] ?? {}),
      profileImage: map['profileImage'],
      favoriteFirmIds: List<String>.from(map['favoriteFirmIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'phone': phone,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'selectedAddressIndex': selectedAddressIndex,
      'createdAt': Timestamp.fromDate(createdAt),
      'loyaltyPoints': loyaltyPoints,
      'firmLoyaltyPoints': firmLoyaltyPoints,
      'profileImage': profileImage,
      'favoriteFirmIds': favoriteFirmIds,
    };
  }

  CustomerModel copyWith({
    String? name,
    String? surname,
    String? phone,
    List<AddressModel>? addresses,
    int? selectedAddressIndex,
    int? loyaltyPoints,
    Map<String, int>? firmLoyaltyPoints,
    String? profileImage,
    List<String>? favoriteFirmIds,
  }) {
    return CustomerModel(
      id: id,
      uid: uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phone: phone ?? this.phone,
      addresses: addresses ?? this.addresses,
      selectedAddressIndex: selectedAddressIndex ?? this.selectedAddressIndex,
      createdAt: createdAt,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      firmLoyaltyPoints: firmLoyaltyPoints ?? this.firmLoyaltyPoints,
      profileImage: profileImage ?? this.profileImage,
      favoriteFirmIds: favoriteFirmIds ?? this.favoriteFirmIds,
    );
  }
}



/// Service Category Model (Admin tanımlı)
class ServiceModel {
  final String id;
  final String name;
  final String icon;
  final List<String> units;
  final bool isActive;
  final int order;

  ServiceModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.units,
    this.isActive = true,
    this.order = 0,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      units: List<String>.from(map['units'] ?? ['adet']),
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'units': units,
      'isActive': isActive,
      'order': order,
    };
  }
}

/// SMS Package Model
class SmsPackageModel {
  final String id;
  final String name;
  final int smsCount;
  final double price;
  final bool isActive;
  final int order;

  SmsPackageModel({
    required this.id,
    required this.name,
    required this.smsCount,
    required this.price,
    this.isActive = true,
    this.order = 0,
  });

  factory SmsPackageModel.fromMap(Map<String, dynamic> map, String id) {
    return SmsPackageModel(
      id: id,
      name: map['name'] ?? '',
      smsCount: map['smsCount'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'smsCount': smsCount,
      'price': price,
      'isActive': isActive,
      'order': order,
    };
  }

  double get pricePerSms => smsCount > 0 ? price / smsCount : 0;
}

/// Vitrin Package Model (Admin tanımlı - Firmalar satın alır)
class VitrinPackageModel {
  final String id;
  final String name;
  final int durationDays;
  final int smsCost;
  final String description;
  final bool isActive;
  final int order;

  VitrinPackageModel({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.smsCost,
    required this.description,
    this.isActive = true,
    this.order = 0,
  });

  factory VitrinPackageModel.fromMap(Map<String, dynamic> map, String id) {
    return VitrinPackageModel(
      id: id,
      name: map['name'] ?? '',
      durationDays: map['durationDays'] ?? 0,
      smsCost: map['smsCost'] ?? 0,
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'durationDays': durationDays,
      'smsCost': smsCost,
      'description': description,
      'isActive': isActive,
      'order': order,
    };
  }
}

/// Campaign Package Model (Admin tanımlı - Firmalar satın alır)
class CampaignPackageModel {
  final String id;
  final String name;
  final int durationDays;
  final int smsCost;
  final String description;
  final bool isActive;
  final int order;

  CampaignPackageModel({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.smsCost,
    required this.description,
    this.isActive = true,
    this.order = 0,
  });

  factory CampaignPackageModel.fromMap(Map<String, dynamic> map, String id) {
    return CampaignPackageModel(
      id: id,
      name: map['name'] ?? '',
      durationDays: map['durationDays'] ?? 0,
      smsCost: map['smsCost'] ?? 0,
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'durationDays': durationDays,
      'smsCost': smsCost,
      'description': description,
      'isActive': isActive,
      'order': order,
    };
  }
}

/// Vitrin Model
class VitrinModel {
  final String id;
  final String firmId;
  final String title;
  final String description;
  final List<String> images;
  final int smsCost;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  final String firmName;
  final String firmLogo;
  final String firmCity;
  final String firmDistrict;

  VitrinModel({
    required this.id,
    required this.firmId,
    required this.title,
    required this.description,
    this.images = const [],
    required this.smsCost,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.firmName = '',
    this.firmLogo = '',
    this.firmCity = '',
    this.firmDistrict = '',
  });

  factory VitrinModel.fromMap(Map<String, dynamic> map, String id) {
    return VitrinModel(
      id: id,
      firmId: map['firmId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      smsCost: map['smsCost'] ?? 0,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firmName: map['firmName'] ?? '',
      firmLogo: map['firmLogo'] ?? '',
      firmCity: map['firmCity'] ?? '',
      firmDistrict: map['firmDistrict'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'title': title,
      'description': description,
      'images': images,
      'smsCost': smsCost,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'firmName': firmName,
      'firmLogo': firmLogo,
      'firmCity': firmCity,
      'firmDistrict': firmDistrict,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
}

/// Campaign Model
class CampaignModel {
  final String id;
  final String firmId;
  final String title;
  final String description;
  final int discountPercent;
  final String? image;
  final int smsCost;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  final String firmName;
  final String firmLogo;
  final String firmCity;
  final String firmDistrict;

  CampaignModel({
    required this.id,
    required this.firmId,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.image,
    required this.smsCost,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.firmName = '',
    this.firmLogo = '',
    this.firmCity = '',
    this.firmDistrict = '',
  });

  factory CampaignModel.fromMap(Map<String, dynamic> map, String id) {
    return CampaignModel(
      id: id,
      firmId: map['firmId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountPercent: map['discountPercent'] ?? 0,
      image: map['image'],
      smsCost: map['smsCost'] ?? 0,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firmName: map['firmName'] ?? '',
      firmLogo: map['firmLogo'] ?? '',
      firmCity: map['firmCity'] ?? '',
      firmDistrict: map['firmDistrict'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'title': title,
      'description': description,
      'discountPercent': discountPercent,
      'image': image,
      'smsCost': smsCost,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'firmName': firmName,
      'firmLogo': firmLogo,
      'firmCity': firmCity,
      'firmDistrict': firmDistrict,
    };
  }
}

/// Legal Document Model - Yasal dokümanlar (Admin tarafından yönetilir)
class LegalDocumentModel {
  final String id;
  final String type; // 'privacy_policy', 'kvkk', 'user_agreement', 'terms_of_service'
  final String title;
  final String content;
  final String version;
  final bool isActive;
  final DateTime updatedAt;

  LegalDocumentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.version,
    this.isActive = true,
    required this.updatedAt,
  });

  factory LegalDocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return LegalDocumentModel(
      id: id,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      version: map['version'] ?? '1.0',
      isActive: map['isActive'] ?? true,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'version': version,
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Predefined document types
  static const String typePrivacyPolicy = 'privacy_policy';
  static const String typeKvkk = 'kvkk';
  static const String typeUserAgreement = 'user_agreement';
  static const String typeTermsOfService = 'terms_of_service';
  static const String typeUsageGuide = 'usage_guide';

  // Get display title for type
  static String getDisplayTitle(String type) {
    switch (type) {
      case typePrivacyPolicy:
        return 'Gizlilik Politikası';
      case typeKvkk:
        return 'KVKK Aydınlatma Metni';
      case typeUserAgreement:
        return 'Kullanıcı Sözleşmesi';
      case typeTermsOfService:
        return 'Kullanım Şartları';
      case typeUsageGuide:
        return 'Kullanım ve Bilgiler';
      default:
        return type;
    }
  }
}

/// Order Item Model - Siparişte talep edilen/ölçülen hizmetler
class OrderItemModel {
  final String serviceId;
  final String serviceName;
  final String unit; // 'm2', 'adet', 'takım'
  final int quantity; // Müşteri girişi (adet sayısı)
  final double? measuredValue; // Firma ölçümü (m2 vb)
  final double? unitPrice; // Birim fiyat
  final double? totalPrice; // Toplam fiyat

  OrderItemModel({
    required this.serviceId,
    required this.serviceName,
    required this.unit,
    required this.quantity,
    this.measuredValue,
    this.unitPrice,
    this.totalPrice,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      unit: map['unit'] ?? 'adet',
      quantity: map['quantity'] ?? 1,
      measuredValue: map['measuredValue']?.toDouble(),
      unitPrice: map['unitPrice']?.toDouble(),
      totalPrice: map['totalPrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'unit': unit,
      'quantity': quantity,
      if (measuredValue != null) 'measuredValue': measuredValue,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (totalPrice != null) 'totalPrice': totalPrice,
    };
  }

  OrderItemModel copyWith({
    double? measuredValue,
    double? unitPrice,
    double? totalPrice,
  }) {
    return OrderItemModel(
      serviceId: serviceId,
      serviceName: serviceName,
      unit: unit,
      quantity: quantity,
      measuredValue: measuredValue ?? this.measuredValue,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

/// Order Model - Sipariş
class OrderModel {
  final String id;
  final String firmId;
  final String firmName;
  final String firmPhone;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final AddressModel customerAddress;
  final String paymentMethod;
  final String status;
  final List<OrderItemModel> items; // Talep edilen hizmetler
  final List<OrderItemModel>? measuredItems; // Ölçüm sonrası güncellenen
  final double? totalPrice; // Ölçüm sonrası belirlenen fiyat
  final String? notes; // Müşteri notu
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? pickedUpAt;
  final DateTime? measuredAt;
  final DateTime? deliveredAt;
  final bool? deletedByFirm;       // Soft delete for firm
  final bool? deletedByCustomer;   // Soft delete for customer
  // Promo Code Fields
  final String? promoCode;         // Uygulanan kampanya kodu
  final String? promoCodeType;     // "percent" veya "fixed"
  final double? promoCodeValue;    // İndirim değeri
  final double? discountAmount;    // Hesaplanan indirim tutarı

  // Sipariş durumları
  static const String statusPending = 'pending';       // Bekliyor
  static const String statusConfirmed = 'confirmed';   // Onaylandı
  static const String statusPickedUp = 'picked_up';    // Teslim Alındı
  static const String statusMeasured = 'measured';     // Ölçüm Yapıldı
  static const String statusOutForDelivery = 'out_for_delivery'; // Dağıtıma Çıktı
  static const String statusDelivered = 'delivered';   // Teslim Edildi
  static const String statusCancelled = 'cancelled';   // İptal

  static String getStatusLabel(String status) {
    switch (status) {
      case statusPending: return 'Bekliyor';
      case statusConfirmed: return 'Onaylandı';
      case statusPickedUp: return 'Teslim Alındı';
      case statusMeasured: return 'Ölçüm Yapıldı';
      case statusOutForDelivery: return 'Dağıtıma Çıktı';
      case statusDelivered: return 'Teslim Edildi';
      case statusCancelled: return 'İptal';
      default: return status;
    }
  }

  OrderModel({
    required this.id,
    required this.firmId,
    required this.firmName,
    required this.firmPhone,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.paymentMethod,
    required this.status,
    required this.items,
    this.measuredItems,
    this.totalPrice,
    this.notes,
    required this.createdAt,
    this.confirmedAt,
    this.pickedUpAt,
    this.measuredAt,
    this.deliveredAt,
    this.deletedByFirm,
    this.deletedByCustomer,
    this.promoCode,
    this.promoCodeType,
    this.promoCodeValue,
    this.discountAmount,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      firmId: map['firmId'] ?? '',
      firmName: map['firmName'] ?? '',
      firmPhone: map['firmPhone'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: AddressModel.fromMap(map['customerAddress'] ?? {}),
      paymentMethod: map['paymentMethod'] ?? FirmModel.paymentCash,
      status: map['status'] ?? statusPending,
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => OrderItemModel.fromMap(i))
              .toList() ??
          [],
      measuredItems: (map['measuredItems'] as List<dynamic>?)
              ?.map((i) => OrderItemModel.fromMap(i))
              .toList(),
      totalPrice: map['totalPrice']?.toDouble(),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedAt: (map['confirmedAt'] as Timestamp?)?.toDate(),
      pickedUpAt: (map['pickedUpAt'] as Timestamp?)?.toDate(),
      measuredAt: (map['measuredAt'] as Timestamp?)?.toDate(),
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate(),
      deletedByFirm: map['deletedByFirm'] as bool?,
      deletedByCustomer: map['deletedByCustomer'] as bool?,
      promoCode: map['promoCode'],
      promoCodeType: map['promoCodeType'],
      promoCodeValue: map['promoCodeValue']?.toDouble(),
      discountAmount: map['discountAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'firmName': firmName,
      'firmPhone': firmPhone,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress.toMap(),
      'paymentMethod': paymentMethod,
      'status': status,
      'items': items.map((i) => i.toMap()).toList(),
      if (measuredItems != null) 'measuredItems': measuredItems!.map((i) => i.toMap()).toList(),
      if (totalPrice != null) 'totalPrice': totalPrice,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      if (confirmedAt != null) 'confirmedAt': Timestamp.fromDate(confirmedAt!),
      if (pickedUpAt != null) 'pickedUpAt': Timestamp.fromDate(pickedUpAt!),
      if (measuredAt != null) 'measuredAt': Timestamp.fromDate(measuredAt!),
      if (deliveredAt != null) 'deliveredAt': Timestamp.fromDate(deliveredAt!),
      if (promoCode != null) 'promoCode': promoCode,
      if (promoCodeType != null) 'promoCodeType': promoCodeType,
      if (promoCodeValue != null) 'promoCodeValue': promoCodeValue,
      if (discountAmount != null) 'discountAmount': discountAmount,
    };
  }

  OrderModel copyWith({
    String? status,
    List<OrderItemModel>? measuredItems,
    double? totalPrice,
    DateTime? confirmedAt,
    DateTime? pickedUpAt,
    DateTime? measuredAt,
    DateTime? deliveredAt,
    String? promoCode,
    String? promoCodeType,
    double? promoCodeValue,
    double? discountAmount,
  }) {
    return OrderModel(
      id: id,
      firmId: firmId,
      firmName: firmName,
      firmPhone: firmPhone,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      items: items,
      measuredItems: measuredItems ?? this.measuredItems,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      measuredAt: measuredAt ?? this.measuredAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      promoCode: promoCode ?? this.promoCode,
      promoCodeType: promoCodeType ?? this.promoCodeType,
      promoCodeValue: promoCodeValue ?? this.promoCodeValue,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

/// FAQ Model - Sıkça Sorulan Sorular
class FaqModel {
  final String id;
  final String category; // genel, siparis, teslimat, odeme
  final String question;
  final String answer;
  final List<String> keywords;
  final bool isActive;
  final int order;

  FaqModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.keywords,
    this.isActive = true,
    this.order = 0,
  });

  factory FaqModel.fromMap(Map<String, dynamic> map, String id) {
    return FaqModel(
      id: id,
      category: map['category'] ?? 'genel',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'question': question,
      'answer': answer,
      'keywords': keywords,
      'isActive': isActive,
      'order': order,
    };
  }
}

/// Ticket Message Model - Destek mesajları
class TicketMessageModel {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String senderType; // customer, firm, admin, bot
  final String message;
  final bool isRead;
  final DateTime createdAt;

  TicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory TicketMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return TicketMessageModel(
      id: id,
      ticketId: map['ticketId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderType: map['senderType'] ?? 'customer',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Ticket Model - Destek Talepleri
class TicketModel {
  final String id;
  final String channel; // customer_firm, firm_admin
  final String senderId;
  final String senderName;
  final String senderType; // customer, firm
  final String receiverId; // firmId, admin
  final String receiverName;
  final String subject;
  final String lastMessage;
  final String status; // open, answered, closed
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? relatedOrderId; // [NEW] Link request to an order
  final String? category; // [NEW] Complaint, Suggestion, etc.

  // Status constants
  static const String statusOpen = 'open';
  static const String statusAnswered = 'answered';
  static const String statusClosed = 'closed';

  // Channel constants
  static const String channelCustomerFirm = 'customer_firm';
  static const String channelFirmAdmin = 'firm_admin';

  static String getStatusLabel(String status) {
    switch (status) {
      case statusOpen: return 'Açık';
      case statusAnswered: return 'Cevaplandı';
      case statusClosed: return 'Kapalı';
      default: return status;
    }
  }

  TicketModel({
    required this.id,
    required this.channel,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.receiverId,
    required this.receiverName,
    required this.subject,
    required this.lastMessage,
    required this.status,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.relatedOrderId,
    this.category,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map, String id) {
    return TicketModel(
      id: id,
      channel: map['channel'] ?? channelCustomerFirm,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderType: map['senderType'] ?? 'customer',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      subject: map['subject'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      status: map['status'] ?? statusOpen,
      unreadCount: map['unreadCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      relatedOrderId: map['relatedOrderId'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channel': channel,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'subject': subject,
      'lastMessage': lastMessage,
      'status': status,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (relatedOrderId != null) 'relatedOrderId': relatedOrderId,
      if (category != null) 'category': category,
    };
  }

  TicketModel copyWith({
    String? lastMessage,
    String? status,
    int? unreadCount,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id,
      channel: channel,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      receiverId: receiverId,
      receiverName: receiverName,
      subject: subject,
      lastMessage: lastMessage ?? this.lastMessage,
      status: status ?? this.status,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relatedOrderId: relatedOrderId, // Keep existing
      category: category, // Keep existing
    );
  }
}

/// Review Model - Firma değerlendirmesi
class ReviewModel {
  final String id;
  final String orderId;
  final String customerId;
  final String customerName;
  final String firmId;
  final String firmName;
  final int rating; // 1-5 yıldız
  final String? comment;
  final DateTime createdAt;
  final bool isVisible; // Admin tarafından gizlenebilir
  final String? firmReply; // Firma yanıtı
  final DateTime? firmReplyAt; // Firma yanıt tarihi

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.firmId,
    required this.firmName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.isVisible = true,
    this.firmReply,
    this.firmReplyAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      firmId: map['firmId'] ?? '',
      firmName: map['firmName'] ?? '',
      rating: map['rating'] ?? 5,
      comment: map['comment'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVisible: map['isVisible'] ?? true,
      firmReply: map['firmReply'],
      firmReplyAt: (map['firmReplyAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'firmId': firmId,
      'firmName': firmName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'isVisible': isVisible,
      if (firmReply != null) 'firmReply': firmReply,
      if (firmReplyAt != null) 'firmReplyAt': Timestamp.fromDate(firmReplyAt!),
    };
  }
}

/// Chat Message Model - Sipariş ve Canlı Destek için genel mesaj modeli
class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName; // "Müşteri", "Firma Adı" veya "Sistem"
  final String message;
  final bool isRead; // Karşı taraf okudu mu?
  final DateTime createdAt;
  
  // Opsiyonel: Mesaj tipi (text, image, location)
  final String type; 

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.type = 'text',
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle both 'timestamp' (Admin Panel) and 'createdAt' (old format) for compatibility
    DateTime parsedTime = DateTime.now();
    if (map['timestamp'] != null) {
      parsedTime = (map['timestamp'] as Timestamp).toDate();
    } else if (map['createdAt'] != null) {
      parsedTime = (map['createdAt'] as Timestamp).toDate();
    }
    
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: parsedTime,
      type: map['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'timestamp': Timestamp.fromDate(createdAt), // Admin Panel compatibility
      'type': type,
    };
  }
}

/// Promo Code Model - Kampanya/İndirim Kodları
class PromoCodeModel {
  final String id;
  final String code;           // Kod (örn: "YUZDE10", "50TL")
  final String type;           // "percent" veya "fixed"
  final double value;          // 10 (%) veya 50 (₺)
  final String? firmId;        // null = Admin kodu, değer = Firma kodu
  final String? firmName;      // Firma adı (gösterim için)
  final int? usageLimit;       // null = sınırsız
  final int usageCount;        // Kullanım sayısı
  final DateTime? expiresAt;   // Bitiş tarihi
  final bool isActive;
  final DateTime createdAt;

  // Type constants
  static const String typePercent = 'percent';
  static const String typeFixed = 'fixed';

  PromoCodeModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.firmId,
    this.firmName,
    this.usageLimit,
    this.usageCount = 0,
    this.expiresAt,
    this.isActive = true,
    required this.createdAt,
  });

  factory PromoCodeModel.fromMap(Map<String, dynamic> map, String id) {
    return PromoCodeModel(
      id: id,
      code: map['code'] ?? '',
      type: map['type'] ?? typePercent,
      value: (map['value'] ?? 0).toDouble(),
      firmId: map['firmId'],
      firmName: map['firmName'],
      usageLimit: map['usageLimit'],
      usageCount: map['usageCount'] ?? 0,
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code.toUpperCase(),
      'type': type,
      'value': value,
      if (firmId != null) 'firmId': firmId,
      if (firmName != null) 'firmName': firmName,
      if (usageLimit != null) 'usageLimit': usageLimit,
      'usageCount': usageCount,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Kod geçerli mi?
  bool get isValid {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    return true;
  }

  // İndirim tutarını hesapla
  double calculateDiscount(double originalPrice) {
    if (type == typePercent) {
      return originalPrice * (value / 100);
    } else {
      return value > originalPrice ? originalPrice : value;
    }
  }

  // İndirim açıklaması
  String get discountLabel {
    if (type == typePercent) {
      return '%${value.toStringAsFixed(0)} indirim';
    } else {
      return '₺${value.toStringAsFixed(0)} indirim';
    }
  }
}
