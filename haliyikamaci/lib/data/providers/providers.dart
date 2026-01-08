import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';
import '../repositories/promo_code_repository.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Firm Repository Provider
final firmRepositoryProvider = Provider<FirmRepository>((ref) {
  return FirmRepository();
});

/// Customer Repository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository();
});

/// Services Repository Provider
final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository();
});

/// Promo Code Repository Provider
final promoCodeRepositoryProvider = Provider<PromoCodeRepository>((ref) {
  return PromoCodeRepository();
});

/// Vitrin Repository Provider
final vitrinRepositoryProvider = Provider<VitrinRepository>((ref) {
  return VitrinRepository();
});

/// Campaign Repository Provider
final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository();
});

/// SMS Packages Repository Provider
final smsPackagesRepositoryProvider = Provider<SmsPackagesRepository>((ref) {
  return SmsPackagesRepository();
});

/// Vitrin Packages Repository Provider
final vitrinPackagesRepositoryProvider = Provider<VitrinPackagesRepository>((ref) {
  return VitrinPackagesRepository();
});

/// Campaign Packages Repository Provider
final campaignPackagesRepositoryProvider = Provider<CampaignPackagesRepository>((ref) {
  return CampaignPackagesRepository();
});

/// Notification Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Unread Order Messages Provider - checks if there are unread message notifications for an order
/// Returns true if there's at least one unread notification for the given orderId
final unreadOrderMessagesProvider = StreamProvider.family<bool, ({String orderId, String userId, String userType})>((ref, params) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadOrderMessageCount(
    orderId: params.orderId,
    userId: params.userId,
    userType: params.userType,
  ).map((count) => count > 0);
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Current User Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final authRepo = ref.read(authRepositoryProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await authRepo.getUserByUid(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Current Firm Provider
final currentFirmProvider = FutureProvider<FirmModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final firmRepo = ref.read(firmRepositoryProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await firmRepo.getFirmByUid(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Current Customer Provider
final currentCustomerProvider = FutureProvider<CustomerModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final customerRepo = ref.read(customerRepositoryProvider);
  
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await customerRepo.getCustomerByUid(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Active Services Provider (for firms/customers - only active)
final activeServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final servicesRepo = ref.watch(servicesRepositoryProvider);
  return servicesRepo.getActiveServices();
});

/// All Services Provider (for admin - includes inactive)
final allServicesProvider = StreamProvider<List<ServiceModel>>((ref) {
  final servicesRepo = ref.watch(servicesRepositoryProvider);
  return servicesRepo.getAllServices();
});

/// SMS Packages Provider (for firms - only active)
final smsPackagesProvider = StreamProvider<List<SmsPackageModel>>((ref) {
  final smsRepo = ref.watch(smsPackagesRepositoryProvider);
  return smsRepo.getActivePackages();
});

/// All SMS Packages Provider (for admin - includes inactive)
final allSmsPackagesProvider = StreamProvider<List<SmsPackageModel>>((ref) {
  final smsRepo = ref.watch(smsPackagesRepositoryProvider);
  return smsRepo.getAllPackages();
});

/// Vitrin Packages Provider (for firms - only active)
final vitrinPackagesProvider = StreamProvider<List<VitrinPackageModel>>((ref) {
  final repo = ref.watch(vitrinPackagesRepositoryProvider);
  return repo.getActivePackages();
});

/// All Vitrin Packages Provider (for admin - includes inactive)
final allVitrinPackagesProvider = StreamProvider<List<VitrinPackageModel>>((ref) {
  final repo = ref.watch(vitrinPackagesRepositoryProvider);
  return repo.getAllPackages();
});

/// Campaign Packages Provider (for firms - only active)
final campaignPackagesProvider = StreamProvider<List<CampaignPackageModel>>((ref) {
  final repo = ref.watch(campaignPackagesRepositoryProvider);
  return repo.getActivePackages();
});

/// All Campaign Packages Provider (for admin - includes inactive)
final allCampaignPackagesProvider = StreamProvider<List<CampaignPackageModel>>((ref) {
  final repo = ref.watch(campaignPackagesRepositoryProvider);
  return repo.getAllPackages();
});

/// Active Vitrins Provider (for customer feed) - optionally filtered by city
final activeVitrinsProvider = StreamProvider.family<List<VitrinModel>, String?>((ref, city) {
  final vitrinRepo = ref.watch(vitrinRepositoryProvider);
  return vitrinRepo.getActiveVitrins(city: city);
});

/// Active Campaigns Provider - optionally filtered by city
final activeCampaignsProvider = StreamProvider.family<List<CampaignModel>, String?>((ref, city) {
  final campaignRepo = ref.watch(campaignRepositoryProvider);
  return campaignRepo.getActiveCampaigns(city: city);
});

/// Approved Firms Provider
final approvedFirmsProvider = StreamProvider<List<FirmModel>>((ref) {
  final firmRepo = ref.watch(firmRepositoryProvider);
  return firmRepo.getApprovedFirms();
});

/// Legal Documents Repository Provider
final legalDocumentsRepositoryProvider = Provider<LegalDocumentsRepository>((ref) {
  return LegalDocumentsRepository();
});

/// Legal Documents Provider
final legalDocumentsProvider = StreamProvider<List<LegalDocumentModel>>((ref) {
  final repo = ref.watch(legalDocumentsRepositoryProvider);
  return repo.getAllDocuments(); // Changed from getActiveDocuments for testing
});

/// Order Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Firm Orders Provider - Firma siparişleri
final firmOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, firmId) {
  final orderRepo = ref.watch(orderRepositoryProvider);
  return orderRepo.getOrdersByFirm(firmId);
});

/// Customer Orders Provider - Müşteri siparişleri
final customerOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, customerId) {
  final orderRepo = ref.watch(orderRepositoryProvider);
  return orderRepo.getOrdersByCustomer(customerId);
});

/// Support Repository Provider
final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository();
});

/// FAQ Provider - Aktif SSS'ler
final activeFaqsProvider = StreamProvider<List<FaqModel>>((ref) {
  final repo = ref.watch(supportRepositoryProvider);
  return repo.getActiveFaqs();
});

/// Tickets for Firm Provider
final firmTicketsProvider = StreamProvider.family<List<TicketModel>, String>((ref, firmId) {
  final repo = ref.watch(supportRepositoryProvider);
  return repo.getTicketsForFirm(firmId);
});

/// User Tickets Provider
final userTicketsProvider = StreamProvider.family<List<TicketModel>, String>((ref, userId) {
  final repo = ref.watch(supportRepositoryProvider);
  return repo.getUserTickets(userId);
});

/// Admin Tickets Provider
final adminTicketsProvider = StreamProvider<List<TicketModel>>((ref) {
  final repo = ref.watch(supportRepositoryProvider);
  return repo.getTicketsForAdmin();
});

/// Ticket Messages Provider
final ticketMessagesProvider = StreamProvider.family<List<TicketMessageModel>, String>((ref, ticketId) {
  final repo = ref.watch(supportRepositoryProvider);
  return repo.getTicketMessages(ticketId);
});

/// Local Favorites Provider (Synced with Firestore)
final localFavoritesProvider = StateNotifierProvider<LocalFavoritesNotifier, Set<String>>((ref) {
  final customerAsync = ref.watch(currentCustomerProvider);
  final notifier = LocalFavoritesNotifier(ref);
  
  // Sync with customer data when loaded
  customerAsync.whenData((customer) {
    if (customer != null) {
      notifier.syncFromCustomer(customer.favoriteFirmIds);
    }
  });
  
  return notifier;
});

/// Has Reviewed Order Provider - Check if customer has reviewed a specific order
/// Uses cache to prevent repeated Firestore queries on every widget rebuild
final hasReviewedOrderProvider = FutureProvider.family<bool, String>((ref, orderId) async {
  final firmRepo = ref.watch(firmRepositoryProvider);
  return await firmRepo.hasCustomerReviewedOrder(orderId);
});

/// Legal Document By Type Provider - Cache legal documents by type
/// Prevents modal opening delay by fetching documents once and caching
final legalDocumentByTypeProvider = FutureProvider.family<LegalDocumentModel?, String>((ref, type) async {
  final repo = ref.watch(legalDocumentsRepositoryProvider);
  return await repo.getDocumentByType(type);
});

/// User City Provider - Get user's city from GPS once and cache
/// Prevents battery drain from repeated GPS queries on scroll
final userCityProvider = FutureProvider<String?>((ref) async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied || requested == LocationPermission.deniedForever) {
        return null;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    ).timeout(const Duration(seconds: 5));

    final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isEmpty) return null;
    return placemarks.first.administrativeArea;
  } catch (e) {
    debugPrint('Error getting user city: $e');
    return null;
  }
});

class LocalFavoritesNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;
  
  LocalFavoritesNotifier(this._ref) : super({});

  void syncFromCustomer(List<String> firmIds) {
    state = Set<String>.from(firmIds);
  }

  Future<void> toggleFavorite(String firmId) async {
    final customerAsync = _ref.read(currentCustomerProvider);
    final customer = customerAsync.value;
    
    if (customer == null) return;

    final isAdd = !state.contains(firmId);
    
    // Update local state immediately for responsiveness
    if (isAdd) {
      state = {...state, firmId};
    } else {
      state = {...state}..remove(firmId);
    }

    try {
      // Update Firestore
      await _ref.read(customerRepositoryProvider).toggleFavoriteFirm(
        customer.id, 
        firmId, 
        isAdd
      );
      // Invalidate customer provider to refresh data in background
      _ref.invalidate(currentCustomerProvider);
    } catch (e) {
      // Optional: Rollback local state on error
      if (isAdd) {
        state = {...state}..remove(firmId);
      } else {
        state = {...state, firmId};
      }
    }
  }

  bool isFavorite(String firmId) => state.contains(firmId);
}
