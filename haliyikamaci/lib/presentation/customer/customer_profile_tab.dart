import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/utils/profanity_helper.dart';
import '../../core/utils/image_utils.dart';

import '../../core/theme/customer_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../widgets/address_selector.dart';
import '../widgets/logo_picker_dialog.dart';
import '../widgets/firm_card_widget.dart';
import '../support/support_chat_screen.dart';

/// Customer Profile Tab
class CustomerProfileTab extends ConsumerWidget {
  const CustomerProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(currentCustomerProvider);
    final l10n = AppLocalizations.of(context)!;

    return customerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.error}: $e')),
      data: (customer) {
        // DEV MODE: Use mock customer if null
        final displayCustomer = customer ?? _getMockCustomer();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // Profile Avatar with Edit Button
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: CustomerTheme.primaryGradient,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      backgroundImage: displayCustomer.profileImage != null
                          ? (displayCustomer.profileImage!.startsWith('assets/')
                              ? AssetImage(displayCustomer.profileImage!) as ImageProvider
                              : NetworkImage(displayCustomer.profileImage!))
                          : null,
                      child: displayCustomer.profileImage == null
                          ? Text(
                              displayCustomer.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CustomerTheme.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: InkWell(
                        onTap: () => _selectProfileImage(context, ref, displayCustomer),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                displayCustomer.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                displayCustomer.phone,
                style: const TextStyle(color: CustomerTheme.textMedium),
              ),
              const SizedBox(height: 24),
              
              // Edit Profile Button - New
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _showEditProfileSheet(context, ref, displayCustomer),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(l10n.editProfile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile Options - Colorful
              _buildColorfulMenuItem(
                icon: Icons.location_on,
                title: l10n.myAddresses,
                subtitle: displayCustomer.address.shortAddress,
                bgColor: const Color(0xFFFFE4EC), // Soft Pink
                iconColor: const Color(0xFFE91E63), // Rose
                onTap: () => _showAddressSheet(context, ref, displayCustomer),
              ),
              _buildColorfulMenuItem(
                icon: Icons.card_giftcard,
                title: l10n.loyaltySystem,
                subtitle: '${displayCustomer.loyaltyPoints} ${l10n.totalPoints}',
                bgColor: const Color(0xFFE3F2FD), // Soft Blue
                iconColor: const Color(0xFF2196F3), // Blue
                onTap: () => _showLoyaltySystemSheet(context, ref, displayCustomer),
              ),
              _buildColorfulMenuItem(
                icon: Icons.history,
                title: l10n.orderHistory,
                bgColor: const Color(0xFFF3E5F5), // Soft Purple
                iconColor: const Color(0xFF9C27B0), // Purple
                onTap: () => _showOrderHistory(context),
              ),
              _buildColorfulMenuItem(
                icon: Icons.star,
                title: l10n.myReviews,
                bgColor: const Color(0xFFFFF3E0), // Soft Peach
                iconColor: const Color(0xFFFF9800), // Orange
                onTap: () => _showMyReviews(context, ref, displayCustomer),
              ),
              _buildColorfulMenuItem(
                icon: Icons.favorite,
                title: l10n.myFavorites,
                bgColor: const Color(0xFFFFE4EC), // Soft Pink
                iconColor: const Color(0xFFE91E63), // Rose
                onTap: () => _showFavorites(context),
              ),
              // Settings & Support - Grouped
              _buildColorfulMenuItem(
                icon: Icons.settings,
                title: l10n.settingsAndSupport,
                subtitle: l10n.settingsSubtitle,
                bgColor: const Color(0xFFECEFF1), // Blue Grey Light
                iconColor: const Color(0xFF607D8B), // Blue Grey
                onTap: () => _showAppSettings(context, ref, displayCustomer),
              ),
              
              const SizedBox(height: 16),
              
              // Logout & Delete - Warning Colors
              _buildColorfulMenuItem(
                icon: Icons.logout,
                title: l10n.logout,
                bgColor: const Color(0xFFFFF8E1), // Light Amber
                iconColor: const Color(0xFFFF9800), // Orange
                onTap: () => _confirmLogout(context, ref),
              ),
              _buildColorfulMenuItem(
                icon: Icons.delete_forever,
                title: l10n.deleteAccount,
                subtitle: l10n.deleteAccountWarning,
                bgColor: const Color(0xFFFFEBEE), // Light Red
                iconColor: const Color(0xFFE53935), // Red
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? CustomerTheme.primary),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildColorfulMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Reduced from 12
      decoration: BoxDecoration(
        color: bgColor, // Use bgColor for entire container background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: iconColor.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Reduced vertical
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: iconColor.withAlpha(230)),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: iconColor.withAlpha(180), fontSize: 12)) : null,
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(180),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_forward_ios, size: 14, color: iconColor),
        ),
        onTap: onTap,
      ),
    );
  }

  // ... (Geri kalan metotlar aynen kopyalanacak)
  
  void _showAddressSheet(BuildContext context, WidgetRef ref, CustomerModel initialCustomer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final customerAsync = ref.watch(currentCustomerProvider);
          final customer = customerAsync.value ?? initialCustomer;
          final l10n = AppLocalizations.of(context)!;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Title
                Text(l10n.myAddresses, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Address List
                Expanded(
                  child: customer.addresses.isEmpty 
                  ? Center(child: Text(l10n.noRegisteredAddresses))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: customer.addresses.length,
                      itemBuilder: (context, index) {
                        final addr = customer.addresses[index];
                        final isSelected = customer.selectedAddressIndex == index;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFE4EC) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? CustomerTheme.primary : Colors.grey[200]!),
                          ),
                          child: ListTile(
                            onTap: () async {
                              await ref.read(customerRepositoryProvider).setSelectedAddress(customer.id, index);
                              ref.invalidate(currentCustomerProvider);
                            },
                            leading: Icon(
                              _getAddressIcon(addr.title),
                              color: isSelected ? CustomerTheme.primary : Colors.grey
                            ),
                            title: Text(
                              addr.title.isNotEmpty ? addr.title : l10n.unnamedAddress,
                              style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                            ),
                            subtitle: Text(
                              '${addr.fullAddress}\n${addr.district}, ${addr.city}',
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => _showEditAddressSheet(context, ref, customer, index),
                                ),
                                if (isSelected) const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(Icons.check_circle, color: CustomerTheme.primary),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    if (customer.addresses.length > 1) {
                                      // Use index-based deletion for reliability
                                      await ref.read(customerRepositoryProvider).deleteAddress(customer.id, index);
                                      ref.invalidate(currentCustomerProvider);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.addressConstraint))
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ),
                
                // Add Address Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddAddressSheet(context, ref, customer),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addNewAddress),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: CustomerTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context, WidgetRef ref, CustomerModel customer) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            Text(l10n.addNewAddress, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: AddressSelector(
                initialTitle: l10n.homeAddress,
                onAddressSelected: (AddressModel newAddress) async {
                  await ref.read(customerRepositoryProvider).addAddress(customer.id, newAddress);
                  ref.invalidate(currentCustomerProvider);
                  if (context.mounted) {
                    Navigator.pop(ctx); // Close add address sheet
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddressSheet(BuildContext context, WidgetRef ref, CustomerModel customer, int index) {
    final addr = customer.addresses[index];
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            Text(AppLocalizations.of(context)!.editAddress, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: AddressSelector(
                initialFullAddress: addr.fullAddress,
                initialTitle: addr.title,
                initialProvinceName: addr.city,
                initialDistrictName: addr.district,
                initialNeighborhoodName: addr.neighborhood,
                onAddressSelected: (AddressModel updatedAddress) async {
                   try {
                     // Update specific index logic
                     final newList = List<AddressModel>.from(customer.addresses);
                     newList[index] = updatedAddress;
                     
                     await ref.read(customerRepositoryProvider).updateAddressList(customer.id, newList);
                     ref.invalidate(currentCustomerProvider);
                     
                     if (context.mounted) {
                       Navigator.pop(ctx);
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text(l10n.addressUpdated)),
                       );
                     }
                   } catch (e) {
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
                       );
                     }
                   }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  IconData _getAddressIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('ev')) return Icons.home;
    if (t.contains('iş') || t.contains('is') || t.contains('ofis')) return Icons.work;
    if (t.contains('okul')) return Icons.school;
    return Icons.location_on;
  }

  void _showLoyaltySystemSheet(BuildContext context, WidgetRef ref, CustomerModel customer) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            Text(l10n.loyaltySystem, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Total Points Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF0D47A1)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.blue.withAlpha(50), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 40),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.totalAccumulatedPoints, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      Text('${customer.loyaltyPoints}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.firmBasedPoints, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            
            // Firm Breakdown
            Expanded(
              child: customer.firmLoyaltyPoints.isEmpty
                  ? Center(child: Text(l10n.noPointsFromFirms))
                  : Consumer(
                      builder: (context, ref, _) {
                        final firmsAsync = ref.watch(approvedFirmsProvider);
                        return firmsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('${l10n.error}: $e')),
                          data: (firms) {
                            final sortedPointEntries = customer.firmLoyaltyPoints.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value));
                            
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: sortedPointEntries.length,
                              itemBuilder: (context, index) {
                                final entry = sortedPointEntries[index];
                                final firmId = entry.key;
                                final points = entry.value;
                                
                                final firm = firms.firstWhere(
                                  (f) => f.id == firmId,
                                  orElse: () => FirmModel(
                                    id: firmId, uid: '', name: l10n.unknownFirm, phone: '',
                                    address: AddressModel(city: '', district: '', area: '', neighborhood: '', fullAddress: ''),
                                    createdAt: DateTime.now(), smsBalance: 0, rating: 0, reviewCount: 0, paymentMethods: [],
                                  ),
                                );

                                if (points == 0) return const SizedBox();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      backgroundImage: ImageUtils.getSafeImageProvider(firm.logo),
                                      child: ImageUtils.getSafeImageProvider(firm.logo) == null ? const Icon(Icons.store, color: Colors.blue) : null,
                                    ),
                                    title: Text(firm.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('$points ${l10n.points}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderHistory(BuildContext context) {
    context.push('/customer/orders');
  }

  void _showMyReviews(BuildContext context, WidgetRef ref, CustomerModel customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _MyReviewsSheet(customerId: customer.id),
    );
  }

  void _showFavorites(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final favorites = ref.watch(localFavoritesProvider);
          final firmsAsync = ref.watch(approvedFirmsProvider);
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(l10n.myFavorites, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: favorites.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_border, size: 64, color: CustomerTheme.primary),
                            const SizedBox(height: 16),
                            Text(l10n.noFavoriteFirms, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text(l10n.discoverFirmsHint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                          ],
                        )
                      : firmsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('${l10n.error}: $e')),
                          data: (firms) {
                            final favoriteFirms = firms.where((f) => favorites.contains(f.id)).toList();
                            if (favoriteFirms.isEmpty) {
                              return Center(child: Text(l10n.noFavoriteFirmsFound, style: const TextStyle(color: Colors.grey)));
                            }
                            return ListView.builder(
                              itemCount: favoriteFirms.length,
                              itemBuilder: (context, index) {
                                final firm = favoriteFirms[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context); // Close favorites sheet first
                                      FirmDetailSheet.show(context, firm);
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: CustomerTheme.primary,
                                      backgroundImage: ImageUtils.getSafeImageProvider(firm.logo),
                                      child: ImageUtils.getSafeImageProvider(firm.logo) == null
                                          ? Text(firm.name.isNotEmpty ? firm.name[0] : '?', style: const TextStyle(color: Colors.white))
                                          : null,
                                    ),
                                    title: Text(firm.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        Text(' ${firm.rating}'),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(firm.address.shortAddress, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.favorite, color: Colors.red),
                                      onPressed: () {
                                        ref.read(localFavoritesProvider.notifier).toggleFavorite(firm.id);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(l10n.notificationSettings, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SwitchListTile(
              value: true,
              onChanged: (v) {},
              title: Text(l10n.orderNotifications),
              subtitle: Text(l10n.orderNotificationsSubtitle),
            ),
            SwitchListTile(
              value: true,
              onChanged: (v) {},
              title: Text(l10n.campaignNotifications),
              subtitle: Text(l10n.campaignNotificationsSubtitle),
            ),
            SwitchListTile(
              value: false,
              onChanged: (v) {},
              title: Text(l10n.smsNotifications),
              subtitle: Text(l10n.smsNotificationsSubtitle),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SupportChatScreen(isCustomerToFirm: true)),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Halı Yıkamacı',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CustomerTheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.local_laundry_service, color: Colors.white),
      ),
      children: [
        Text(AppLocalizations.of(context)!.appDescription),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // Fetch from Firestore (admin-defined content)
    final legalRepo = ref.read(legalDocumentsRepositoryProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(l10n.privacyPolicy, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Content
            Expanded(
              child: FutureBuilder<LegalDocumentModel?>(
                future: legalRepo.getDocumentByType('privacy_policy'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final doc = snapshot.data;
                  if (doc == null) {
                    return Center(
                      child: Text(l10n.privacyPolicyNotDefined, style: const TextStyle(color: Colors.grey)),
                    );
                  }
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(doc.content, style: const TextStyle(fontSize: 14, height: 1.6)),
                  );
                },
              ),
            ),
            // Close Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomerTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  // ==================== DELETE ACCOUNT ====================
  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [const Icon(Icons.warning, color: Colors.red), const SizedBox(width: 8), Text(l10n.deleteAccount)]),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => _deleteAccount(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // ... implementation
    // Mock deletion
    if (context.mounted) {
      Navigator.pop(context); // This pop is likely for the AlertDialog
      
      // Sign out
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        GoRouter.of(context).go('/login');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.accountDeletedSuccess)),
      );
    }
  }

  Future<void> _selectProfileImage(BuildContext context, WidgetRef ref, CustomerModel customer) async {
    final selectedPath = await LogoPickerDialog.show(context, iconType: 'musteri');
    if (selectedPath != null) {
      // Update customer profile image
      await ref.read(customerRepositoryProvider).updateCustomer(
        customer.id,
        {'profileImage': selectedPath},
      );
      ref.invalidate(currentCustomerProvider);
    }
  }

  CustomerModel _getMockCustomer() {
    return CustomerModel(
      id: 'mock_customer_1',
      uid: 'mock_uid_1',
      phone: '0555 111 22 33',
      name: 'Ayşe',
      surname: 'Yılmaz',
      profileImage: null,
      createdAt: DateTime.now(),
      address: AddressModel(
        city: 'İstanbul',
        district: 'Kadıköy',
        area: 'Kadıköy',
        neighborhood: 'Caferağa',
        fullAddress: 'Moda Cd. No:12 D:5',
        latitude: 40.98,
        longitude: 29.03,
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, CustomerModel customer) {
    final nameController = TextEditingController(text: customer.name);
    final surnameController = TextEditingController(text: customer.surname);
    final phoneController = TextEditingController(text: customer.phone.replaceAll('+90', '').trim());
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(l10n.editProfileInfo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      Text(l10n.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: l10n.yourName,
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Surname Field
                      Text(l10n.surname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: surnameController,
                        decoration: InputDecoration(
                          hintText: l10n.yourSurname,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone Field (Read-only with note)
                      Text(l10n.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        enabled: false, // Phone can't be changed easily as it's the login
                        decoration: InputDecoration(
                          hintText: l10n.phone,
                          prefixIcon: const Icon(Icons.phone),
                          prefixText: '+90 ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.phoneCannotBeChanged,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      
                      // Change Password Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withAlpha(100)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lock, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.changePassword, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.changePasswordHint,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showChangePasswordDialog(context, ref),
                                icon: const Icon(Icons.lock_outline, size: 18),
                                label: Text(l10n.changePassword),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: const BorderSide(color: Colors.orange),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Save Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final profanityHelper = ref.read(profanityHelperProvider);
                        final newName = nameController.text.trim();
                        final newSurname = surnameController.text.trim();

                        if (newName.isEmpty || newSurname.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.nameSurnameCannotBeEmpty)),
                          );
                          return;
                        }

                        if (profanityHelper.hasProfanity(newName) || profanityHelper.hasProfanity(newSurname)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.nameSurnameProfanityWarning),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await ref.read(customerRepositoryProvider).updateProfile(
                          customer.id,
                          name: newName,
                          surname: newSurname,
                        );
                        ref.invalidate(currentCustomerProvider);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.profileUpdated)),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomerTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.changePassword),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: l10n.newPasswordConfirm,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.passwordsDoNotMatch), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.passwordMinLength), backgroundColor: Colors.red),
                  );
                  return;
                }
                
                setState(() => isLoading = true);
                try {
                  await ref.read(authRepositoryProvider).changePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.passwordChangedSuccess), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  setState(() => isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: CustomerTheme.primary),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.changePassword, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppSettings(BuildContext context, WidgetRef ref, CustomerModel customer) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.settingsAndSupport,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.notifications, color: Color(0xFF4CAF50), size: 20),
              ),
              title: Text(l10n.notificationSettings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                _showNotificationSettings(context);
              },
            ),
            const Divider(height: 1, indent: 70),
            
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.help, color: Color(0xFF2196F3), size: 20),
              ),
              title: Text(l10n.helpSupport),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                 Navigator.pop(ctx);
                _showHelpSupport(context);
              },
            ),
            const Divider(height: 1, indent: 70),
            
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF3E5F5),
                child: Icon(Icons.info, color: Color(0xFF9C27B0), size: 20),
              ),
              title: Text(l10n.about),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                 Navigator.pop(ctx);
                _showAbout(context);
              },
            ),
            const Divider(height: 1, indent: 70),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.privacy_tip, color: Color(0xFFFF9800), size: 20),
              ),
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                 Navigator.pop(ctx);
                _showPrivacyPolicy(context, ref);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// My Reviews Sheet - Müşterinin yaptığı değerlendirmeleri gösterir
class _MyReviewsSheet extends ConsumerStatefulWidget {
  final String customerId;
  const _MyReviewsSheet({required this.customerId});

  @override
  ConsumerState<_MyReviewsSheet> createState() => _MyReviewsSheetState();
}

class _MyReviewsSheetState extends ConsumerState<_MyReviewsSheet> {
  @override
  Widget build(BuildContext context) {
    final reviewsStream = ref.watch(firmRepositoryProvider).getCustomerReviews(widget.customerId);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(l10n.myReviews, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          Expanded(
            child: StreamBuilder<List<ReviewModel>>(
              stream: reviewsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final reviews = snapshot.data ?? [];
                
                if (reviews.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_border, size: 64, color: Colors.amber),
                      const SizedBox(height: 16),
                      Text(l10n.noReviewsYet, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(l10n.reviewAfterOrderHint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                    ],
                  );
                }
                
                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Firma adı ve tarih
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.firmName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Stars
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  )),
                ),
              ],
            ),
            
            // Comment
            if (review.comment?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(review.comment!, style: TextStyle(color: Colors.grey[700])),
            ],
            
            // Actions: Düzenle / Sil
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editReview(review),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(l10n.edit),
                  style: TextButton.styleFrom(foregroundColor: CustomerTheme.primary),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteReview(review),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(l10n.delete),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editReview(ReviewModel review) {
    final commentController = TextEditingController(text: review.comment ?? '');
    int selectedRating = review.rating;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.editReview),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  onPressed: () => setDialogState(() => selectedRating = i + 1),
                  icon: Icon(
                    i < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.yourComment,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ref.read(firmRepositoryProvider).updateReview(review.id, {
                    'rating': selectedRating,
                    'comment': commentController.text.trim(),
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.reviewUpdated), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReview(ReviewModel review) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteReview),
        content: Text(l10n.deleteReviewConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(firmRepositoryProvider).deleteReview(review.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.reviewDeleted), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
