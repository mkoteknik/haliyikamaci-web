import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../core/theme/customer_theme.dart';
import '../../data/providers/providers.dart';
import 'customer_feed_tab.dart';
import 'customer_campaigns_tab.dart';
import 'customer_firms_tab.dart';
import 'customer_profile_tab.dart';
import 'create_order_sheet.dart';
import '../../core/utils/popup_manager.dart';

/// Customer Home Screen with central floating order button
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    // Check for popup ads (Customer)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PopupManager.checkAndShowPopup(context, ref, 'customer');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(currentCustomerProvider);

    return Theme(
      data: CustomerTheme.theme,
      child: customerAsync.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Hata: $e')),
        ),
        data: (customer) {
          return Scaffold(
            body: _buildBody(),
            extendBody: true,
            bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 100, // Extra height to accommodate floating button
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Navigation bar at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildBottomNavBar(),
                  ),
                  // Floating order button - positioned above nav bar center
                  Positioned(
                    bottom: 45, // Half over the nav bar
                    child: _buildOrderButton(),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    Widget tabContent;
    switch (_selectedIndex) {
      case 0:
        tabContent = CustomerFeedTab(
          onTabChange: (index) => setState(() => _selectedIndex = index),
        );
        break;
      case 1:
        tabContent = const CustomerCampaignsTab();
        break;
      case 2:
        tabContent = const CustomerFirmsTab();
        break;
      case 3:
        // Profile Tab - No Ad Banner
        return const CustomerProfileTab();
      default:
        tabContent = const CustomerFeedTab();
    }

    // Wrap other tabs with AdBannerWidget at bottom
    return tabContent;
  }

  // ==================== ANIMATED ORDER BUTTON ====================
  Widget _buildOrderButton() {
    return GestureDetector(
      onTap: () => _showOrderWizard(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CustomerTheme.primary.withAlpha(100),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating border animation
                Transform.rotate(
                  angle: _animationController.value * 2 * math.pi,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          CustomerTheme.primary,
                          CustomerTheme.primaryLight,
                          CustomerTheme.secondary,
                          CustomerTheme.primaryLight,
                          CustomerTheme.primary,
                        ],
                      ),
                    ),
                  ),
                ),
                // Inner circle with icon
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: CustomerTheme.primaryGradient,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== CUSTOM BOTTOM NAV BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Left side - 2 buttons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Anasayfa'),
                _buildNavItem(1, Icons.local_offer_outlined, Icons.local_offer, 'Kampanyalar'),
              ],
            ),
          ),
          // Center space for floating button
          const SizedBox(width: 72),
          // Right side - 2 buttons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(2, Icons.store_outlined, Icons.store, 'Firmalar'),
                _buildNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque, // Capture taps on padding
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? CustomerTheme.primary : CustomerTheme.textMedium,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? CustomerTheme.primary : CustomerTheme.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3-STEP ORDER WIZARD ====================
  void _showOrderWizard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateOrderSheet(
        onComplete: (firmId) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sipariş talebiniz firmaya iletildi!'),
              backgroundColor: CustomerTheme.success,
            ),
          );
        },
        onNavigateToFirms: () {
          Navigator.pop(ctx);
          setState(() => _selectedIndex = 2);
        },
      ),
    );
  }
}

// ==================== END OF CUSTOMER HOME SCREEN ====================
