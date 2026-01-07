import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import 'firm_dashboard_tab.dart';
import 'firm_orders_tab.dart';     // NEW
import 'firm_marketing_tab.dart';  // NEW
import 'firm_services_tab.dart';
import 'firm_sms_tab.dart';
import 'firm_profile_tab.dart';
import '../widgets/ad_banner_widget.dart';
import 'firm_notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/popup_manager.dart';

/// Firm Home Screen - Main container for firm panel
class FirmHomeScreen extends ConsumerStatefulWidget {
  const FirmHomeScreen({super.key});

  @override
  ConsumerState<FirmHomeScreen> createState() => _FirmHomeScreenState();
}

class _FirmHomeScreenState extends ConsumerState<FirmHomeScreen> {
  int _selectedIndex = 0;

  List<_NavItem> get _navItems => [
    _NavItem(icon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.receipt_long, label: 'Siparişler'),
    _NavItem(icon: Icons.campaign, label: 'Pazarlama'),
    _NavItem(icon: Icons.list_alt, label: 'Hizmetler'),
    _NavItem(icon: FontAwesomeIcons.coins, label: 'KRD'),
    _NavItem(icon: Icons.person, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    // Check for popup ads (Firm)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PopupManager.checkAndShowPopup(context, ref, 'firm');
    });
  }

  @override
  Widget build(BuildContext context) {
    final firmAsync = ref.watch(currentFirmProvider);

    return firmAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Hata: $e')),
      ),
      data: (firm) {
        // DEV MODE: If no firm, show demo UI with mock data
        // In production, uncomment the redirect below
        // if (firm == null) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     context.go('/register/firm');
        //   });
        //   return const Scaffold(
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }

        // DEV MODE: Use mock firm if null
        final displayFirm = firm ?? _getMockFirm();

        // Onay bekliyor (skip in dev mode if mock)
        if (firm != null && !firm.isApproved) {
          return _buildPendingApprovalScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Firma Paneli'),
            actions: [
              // SMS Balance Badge
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: displayFirm.smsBalance > 50 
                      ? AppTheme.accentGreen 
                      : displayFirm.smsBalance > 0 
                          ? AppTheme.accentOrange 
                          : AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.coins, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${displayFirm.smsBalance} KRD',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildNotificationBadge(displayFirm),
            ],
          ),
          body: _buildBody(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: _navItems
                .map((item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    Widget tabContent;
    switch (_selectedIndex) {
      case 0:
        tabContent = FirmDashboardTab(
          onTabChange: (index) => setState(() => _selectedIndex = index),
        );
        break;
      case 1:
        tabContent = const FirmOrdersTab();
        break;
      case 2:
        tabContent = const FirmMarketingTab();
        break;
      case 3:
        tabContent = const FirmServicesTab();
        break;
      case 4:
        tabContent = const FirmSmsTab();
        break;
      case 5:
        // Profile Tab - No Ad Banner
        return const FirmProfileTab();
      default:
        tabContent = const FirmDashboardTab();
    }

    // Wrap other tabs with AdBannerWidget at bottom
    return Column(
      children: [
        Expanded(child: tabContent),
        const AdBannerWidget(),
      ],
    );
  }

  Widget _buildPendingApprovalScreen() {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty,
                      size: 40,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Kaydınız Alınmıştır',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Yönetici onayı sonrasında panele giriş yapabilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.mediumGray,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Onay işlemi tamamlandığında SMS ile bilgilendirileceksiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.mediumGray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.invalidate(currentFirmProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Durumu Kontrol Et'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      ref.read(authRepositoryProvider).signOut();
                      context.go('/login');
                    },
                    child: const Text('Çıkış Yap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build notification badge with unread count
  Widget _buildNotificationBadge(FirmModel firm) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () {},
      );
    }

    final notificationRepo = ref.watch(notificationRepositoryProvider);
    final unreadStream = notificationRepo.getUnreadCount(
      userId: user.uid,
      userType: 'firm',
    );

    return StreamBuilder<int>(
      stream: unreadStream,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FirmNotificationsScreen()),
                );
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}

// DEV MODE: Mock firm for testing
FirmModel _getMockFirm() {
  return FirmModel(
    id: 'mock-firm-id',
    uid: 'mock-uid',
    name: 'Demo Firma (Test)',
    phone: '5551112233',
    address: AddressModel(
      city: 'İstanbul',
      district: 'Kadıköy',
      area: '',
      neighborhood: 'Caferağa',
      fullAddress: 'Test Caddesi No:1',
    ),
    smsBalance: 100,
    isApproved: true,
    createdAt: DateTime.now(),
    paymentMethods: [FirmModel.paymentCash],
  );
}
