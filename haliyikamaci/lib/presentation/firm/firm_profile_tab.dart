import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/providers.dart';
import '../../data/models/models.dart';
import '../../data/services/turkiye_api_service.dart';
import '../widgets/address_selector.dart';
import '../widgets/logo_picker_dialog.dart';
import '../support/support_chat_screen.dart';
import 'firm_promo_codes_screen.dart';
import 'firm_accounting_screen.dart';
import '../../l10n/generated/app_localizations.dart';

/// Firm Profile Tab
class FirmProfileTab extends ConsumerWidget {
  const FirmProfileTab({super.key});
  
  /// Helper method to safely get logo image provider
  /// Returns null for invalid logo values (test data, empty strings, etc.)
  ImageProvider? _getLogoImage(String? logo) {
    if (logo == null || logo.isEmpty) return null;
    
    // Valid asset path
    if (logo.startsWith('assets/')) {
      return AssetImage(logo);
    }
    
    // Valid URL (http or https)
    if (logo.startsWith('http://') || logo.startsWith('https://')) {
      return NetworkImage(logo);
    }
    
    // Invalid value (test data, random strings, etc.) - return null to show fallback
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firmAsync = ref.watch(currentFirmProvider);
    final l10n = AppLocalizations.of(context)!;

    return firmAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.error}: $e')),
      data: (firm) {
        // DEV MODE: Use mock firm if null
        final displayFirm = firm ?? _getMockFirm();

        // Use safe image loading for cover
        final coverProvider = _getLogoImage(displayFirm.coverImage);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header with Cover
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Cover Image Area
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withAlpha(30),
                        image: coverProvider != null
                            ? DecorationImage(
                                image: coverProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: Stack(
                         children: [
                            if (coverProvider == null)
                              const Center(child: Icon(Icons.storefront, size: 48, color: AppTheme.primaryBlue)),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, size: 16, color: AppTheme.primaryBlue),
                                  onPressed: () => _showCoverPicker(context, ref),
                                ),
                              ),
                            )
                         ]
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Logo (Overlapping or centered below cover)
                          Transform.translate(
                            offset: const Offset(0, -60), // Pull up
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 46,
                                    backgroundColor: AppTheme.primaryBlue.withAlpha(50),
                                    backgroundImage: _getLogoImage(displayFirm.logo),
                                    child: _getLogoImage(displayFirm.logo) == null
                                        ? Text(
                                            displayFirm.name.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.primaryBlue,
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, size: 14),
                                    color: Colors.white,
                                    onPressed: () => _selectLogo(context, ref, displayFirm),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () => _editField(context, ref, 'name', l10n.firmName, displayFirm.name),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        displayFirm.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.edit, size: 18, color: AppTheme.mediumGray),
                                    ],
                                  ),
                                ),
                                Text(
                                  displayFirm.address.fullAddressDisplay,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.mediumGray),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      displayFirm.rating.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(' (${displayFirm.reviewCount} ${l10n.reviewCount})'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Contact Info
              Card(
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: l10n.phone,
                      value: displayFirm.phone,
                      onTap: () => _editField(context, ref, 'phone', l10n.phone, displayFirm.phone),
                    ),
                    const Divider(height: 1),
                    _buildInfoTile(
                      icon: Icons.message,
                      title: l10n.whatsapp,
                      value: displayFirm.whatsapp ?? l10n.notSpecified,
                      onTap: () => _editField(context, ref, 'whatsapp', l10n.whatsapp, displayFirm.whatsapp ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Address
              Card(
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.location_on,
                      title: l10n.address,
                      value: displayFirm.address.fullAddressDisplay,
                      onTap: () => _editAddress(context, ref, displayFirm),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment Methods - StatefulWidget for demo mode support
              _PaymentMethodsSection(
                firm: displayFirm,
                ref: ref,
                isDemoMode: firm == null || displayFirm.id == 'demo_firm',
              ),
              const SizedBox(height: 16),

              // Loyalty Program Settings
              _LoyaltySettingsSection(
                firm: displayFirm,
                ref: ref,
                isDemoMode: firm == null || displayFirm.id == 'demo_firm',
              ),
              const SizedBox(height: 16),

              // Actions
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet, color: Colors.teal),
                      title: Text(l10n.accounting),
                      subtitle: Text(l10n.accountingSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FirmAccountingScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.share, color: AppTheme.primaryBlue),
                      title: Text(l10n.shareProfile),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Web sitesi firma detay sayfası
                        Share.share('https://www.haliyikamacibul.com/customer/firm-detail.php?id=${displayFirm.id}');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                      title: Text(l10n.usageAndInfo),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showUsageGuide(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.qr_code, color: AppTheme.primaryBlue),
                      title: Text(l10n.myQrCode),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showQrCode(context, displayFirm),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.local_offer, color: Colors.amber),
                      title: Text(l10n.myPromoCodes),
                      subtitle: Text(l10n.createDiscountCodes),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FirmPromoCodesScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Account Settings & Actions
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock, color: Colors.orange),
                      title: Text(
                        l10n.changePassword,
                        style: const TextStyle(color: Colors.orange),
                      ),
                      subtitle: Text(l10n.changePasswordSubtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.support_agent, color: AppTheme.accentGreen),
                      title: Text(
                        l10n.adminSupport,
                        style: const TextStyle(color: AppTheme.accentGreen),
                      ),
                      subtitle: Text(l10n.adminSupportSubtitle),
                      onTap: () => _openAdminSupport(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppTheme.accentOrange),
                      title: Text(
                        l10n.logout,
                        style: const TextStyle(color: AppTheme.accentOrange),
                      ),
                      onTap: () => _confirmLogout(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: AppTheme.accentRed),
                      title: Text(
                        l10n.deleteAccount,
                        style: const TextStyle(color: AppTheme.accentRed),
                      ),
                      subtitle: Text(l10n.deleteAccountWarning),
                      onTap: () => _confirmDeleteAccount(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // ==================== ADMIN SUPPORT ====================
  void _openAdminSupport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupportChatScreen(
          isCustomerToFirm: false,
          firmName: AppLocalizations.of(context)!.adminSupport,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.mediumGray)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.edit, size: 18),
      onTap: onTap,
    );
  }

  void _editField(BuildContext context, WidgetRef ref, String dbField, String label, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$label ${l10n.edit}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Update implementation
                // Note: using generic updateProfile method which needs implementation or use updateFirm
                final firm = await ref.read(currentFirmProvider.future);
                if (firm != null) {
                   await ref.read(firmRepositoryProvider).updateFirm(firm.id, {dbField: controller.text});
                   ref.invalidate(currentFirmProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
  
  void _showCoverPicker(BuildContext context, WidgetRef ref) {
    // Local Assets (Kapaklar)
    final covers = [
      'assets/kapaklar/hali1.jpg',
      'assets/kapaklar/hali2.jpg',
      'assets/kapaklar/hali3.jpg',
      'assets/kapaklar/hali4.jpg',
      'assets/kapaklar/hali5.jpg',
      'assets/kapaklar/hali6.jpg',
      'assets/kapaklar/hali7.jpg',
      'assets/kapaklar/hali8.jpg',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.selectCoverImage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: covers.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final firm = await ref.read(currentFirmProvider.future);
                        if (firm != null) {
                           await ref.read(firmRepositoryProvider).updateFirm(firm.id, {'coverImage': covers[index]});
                           ref.invalidate(currentFirmProvider);
                           if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.coverImageUpdated)));
                           }
                        }
                      } catch (e) {
                         // ignore
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(covers[index], fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectLogo(BuildContext context, WidgetRef ref, dynamic firm) async {
    final selectedLogo = await LogoPickerDialog.show(context, iconType: 'firma');
    
    if (selectedLogo != null) {
      try {
        final currentFirm = await ref.read(currentFirmProvider.future);
        if (currentFirm != null) {
          await ref.read(firmRepositoryProvider).updateFirm(currentFirm.id, {'logo': selectedLogo});
          ref.invalidate(currentFirmProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.logoUpdated), backgroundColor: Colors.green),
            );
          }
        } else {
          // Demo mode
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('DEMO: Logo seçildi: $selectedLogo'), backgroundColor: Colors.orange),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  
  void _editAddress(BuildContext context, WidgetRef ref, dynamic firm) {
    // Show full screen address editor with AddressSelector
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddressEditorSheet(
        firm: firm,
        ref: ref,
        onSaved: () {
          ref.invalidate(currentFirmProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.addressUpdated)),
            );
          }
        },
      ),
    );
  }
  
  void _showQrCode(BuildContext context, dynamic firm) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: QrImageView(
                  data: 'https://www.haliyikamacibul.com/customer/firm-detail.php?id=${firm.id}',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(firm.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.qrCodeDescription, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first
              
              // Sign out
              await ref.read(authRepositoryProvider).signOut();
              
              // Clear providers
              ref.invalidate(currentFirmProvider);
              ref.invalidate(currentCustomerProvider);
              
              // Navigate to login (use original context)
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  // ==================== DELETE ACCOUNT ====================
  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppTheme.accentRed),
            const SizedBox(width: 8),
            Text(l10n.deleteAccount),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deleteFirmAccountConfirmation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(l10n.deleteAccountWarning),
            const SizedBox(height: 8),
            Text(l10n.deleteWarningItem1),
            Text(l10n.deleteWarningItem2),
            Text(l10n.deleteWarningItem3),
            Text(l10n.deleteWarningItem4),
            Text(l10n.deleteWarningItem5),
            Text(l10n.deleteWarningItem6),
            const SizedBox(height: 16),
            Text(
              l10n.actionCannotBeUndone,
              style: const TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount(context, ref);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(l10n.deletingAccount),
          ],
        ),
      ),
    );

    try {
      final firm = ref.read(currentFirmProvider).value;
      if (firm == null) {
        throw Exception(l10n.unknownError);
      }

      await ref.read(authRepositoryProvider).deleteAccount(
        uid: firm.uid,
        userType: 'firm',
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeletedSuccess),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.accountDeleteError}$e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }



  // DEV MODE: Mock firm for testing
  FirmModel _getMockFirm() {
    return FirmModel(
      id: 'demo_firm',
      uid: 'demo_uid',
      name: 'Demo Firma',
      phone: '5551234567',
      address: AddressModel(
        city: 'İstanbul',
        district: 'Kadıköy',
        area: '',
        neighborhood: 'Caferağa',
        fullAddress: 'Demo Adres',
      ),
      createdAt: DateTime.now(),
      smsBalance: 100,
      rating: 4.5,
      reviewCount: 25,
      paymentMethods: [FirmModel.paymentCash], // Default: Nakit
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
                    const SnackBar(content: Text('Şifre en az 6 karakter olmalı!'), backgroundColor: Colors.red),
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
                      const SnackBar(content: Text('Şifreniz değiştirildi'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  setState(() => isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Şifreyi Değiştir', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsageGuide(BuildContext context, WidgetRef ref) async {
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
            const Text('KRD (Kredi) Kullanım ve Bilgiler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Content
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final docAsync = ref.watch(legalDocumentByTypeProvider(LegalDocumentModel.typeUsageGuide));
                  
                  return docAsync.when(
                    data: (doc) {
                      if (doc == null) {
                        return const Center(
                          child: Text('Kullanım kılavuzu henüz hazırlanmamış.', style: TextStyle(color: Colors.grey)),
                        );
                      }
                      
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Html(
                          data: doc.content,
                          style: {
                            "body": Style(
                              fontSize: FontSize(14),
                              lineHeight: LineHeight(1.6),
                            ),
                          },
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Center(
                      child: Text('Kullanım kılavuzu yüklenemedi.', style: TextStyle(color: Colors.grey)),
                    ),
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
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kapat', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Address Editor Sheet with full cascade dropdowns
class _AddressEditorSheet extends StatefulWidget {
  final dynamic firm;
  final WidgetRef ref;
  final VoidCallback onSaved;

  const _AddressEditorSheet({
    required this.firm,
    required this.ref,
    required this.onSaved,
  });

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  Province? _selectedProvince;
  District? _selectedDistrict;
  Neighborhood? _selectedNeighborhood;
  final _openAddressController = TextEditingController();
  final _titleController = TextEditingController(); // Title controller
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _openAddressController.text = widget.firm.address.fullAddress ?? '';
    _titleController.text = widget.firm.address.title ?? 'İş Adresi';
  }

  @override
  void dispose() {
    _openAddressController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Adres Düzenle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Address Selector (City/District/Neighborhood)
            AddressSelector(
              showButton: false,
              initialTitle: widget.firm.address.title ?? 'İş Adresi',
              titleController: _titleController,
              addressController: _openAddressController,
              initialProvinceName: widget.firm.address.city,
              initialDistrictName: widget.firm.address.district,
              initialNeighborhoodName: widget.firm.address.neighborhood,
              onChanged: (province, district, neighborhood) {
                setState(() {
                  _selectedProvince = province;
                  _selectedDistrict = district;
                  _selectedNeighborhood = neighborhood;
                });
              },
            ),
            const SizedBox(height: 16),

            // Open Address (Manual Input)

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveAddress,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Kaydet'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (_selectedProvince == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen İl ve İlçe seçin')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final newAddress = {
        'title': _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'İş Adresi',
        'city': _selectedProvince!.name,
        'district': _selectedDistrict!.name,
        'neighborhood': _selectedNeighborhood?.name ?? '',
        'area': '', // Not used in current model
        'fullAddress': _openAddressController.text,
      };

      await widget.ref.read(firmRepositoryProvider).updateFirm(
        widget.firm.id,
        {'address': newAddress},
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ==================== PAYMENT METHODS SECTION ====================
class _PaymentMethodsSection extends StatefulWidget {
  final FirmModel firm;
  final WidgetRef ref;
  final bool isDemoMode;

  const _PaymentMethodsSection({
    required this.firm,
    required this.ref,
    required this.isDemoMode,
  });

  @override
  State<_PaymentMethodsSection> createState() => _PaymentMethodsSectionState();
}

class _PaymentMethodsSectionState extends State<_PaymentMethodsSection> {
  late List<String> _selectedMethods;

  @override
  void initState() {
    super.initState();
    _selectedMethods = List.from(widget.firm.paymentMethods);
  }

  @override
  void didUpdateWidget(_PaymentMethodsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firm.id != widget.firm.id) {
      _selectedMethods = List.from(widget.firm.paymentMethods);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: AppTheme.primaryBlue),
                SizedBox(width: 12),
                Text(
                  'Ödeme Yöntemleri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Kabul ettiğiniz ödeme yöntemlerini seçin:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(FirmModel.paymentCash, 'Nakit', Icons.money),
                _buildChip(FirmModel.paymentCard, 'Kredi Kartı', Icons.credit_card),
                _buildChip(FirmModel.paymentTransfer, 'Havale/EFT', Icons.account_balance),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String method, String label, IconData icon) {
    final isSelected = _selectedMethods.contains(method);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppTheme.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selectedColor: AppTheme.primaryBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) => _onMethodSelected(method, label, selected),
    );
  }

  void _onMethodSelected(String method, String label, bool selected) async {
    // Create new list
    List<String> newMethods = List.from(_selectedMethods);
    
    if (selected) {
      if (!newMethods.contains(method)) {
        newMethods.add(method);
      }
    } else {
      // Don't allow removing if it's the last one
      if (newMethods.length > 1) {
        newMethods.remove(method);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('En az bir ödeme yöntemi seçili olmalı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Update local state immediately for UI feedback
    setState(() {
      _selectedMethods = newMethods;
    });

    // Demo mode - only update UI, don't save to Firebase
    if (widget.isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selected
              ? '$label ödeme yöntemi seçildi (Demo Mod)'
              : '$label ödeme yöntemi kaldırıldı (Demo Mod)'),
          backgroundColor: AppTheme.accentOrange,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    // Save to Firebase
    try {
      await widget.ref.read(firmRepositoryProvider).updateFirm(widget.firm.id, {
        'paymentMethods': newMethods,
      });
      widget.ref.invalidate(currentFirmProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(selected
                ? '$label ödeme yöntemi eklendi'
                : '$label ödeme yöntemi kaldırıldı'),
            backgroundColor: AppTheme.accentGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _selectedMethods = List.from(widget.firm.paymentMethods);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }
}

/// Loyalty Settings Section - Sadakat programı ayarları
class _LoyaltySettingsSection extends StatefulWidget {
  final FirmModel firm;
  final WidgetRef ref;
  final bool isDemoMode;

  const _LoyaltySettingsSection({
    required this.firm,
    required this.ref,
    required this.isDemoMode,
  });

  @override
  State<_LoyaltySettingsSection> createState() => _LoyaltySettingsSectionState();
}

class _LoyaltySettingsSectionState extends State<_LoyaltySettingsSection> {
  late bool _loyaltyEnabled;
  late double _loyaltyPercentage;

  @override
  void initState() {
    super.initState();
    _loyaltyEnabled = widget.firm.loyaltyEnabled;
    _loyaltyPercentage = widget.firm.loyaltyPercentage;
  }

  Future<void> _updateLoyaltySettings() async {
    if (widget.isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_loyaltyEnabled 
              ? 'DEMO: Sadakat programı açıldı! (%${_loyaltyPercentage.toInt()} puan)'
              : 'DEMO: Sadakat programı kapatıldı'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await widget.ref.read(firmRepositoryProvider).updateFirm(widget.firm.id, {
        'loyaltyEnabled': _loyaltyEnabled,
        'loyaltyPercentage': _loyaltyPercentage,
      });
      widget.ref.invalidate(currentFirmProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_loyaltyEnabled 
                ? 'Sadakat programı güncellendi! (%${_loyaltyPercentage.toInt()} puan)'
                : 'Sadakat programı kapatıldı'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Sadakat Programı',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: _loyaltyEnabled,
                  onChanged: (value) {
                    setState(() => _loyaltyEnabled = value);
                    _updateLoyaltySettings();
                  },
                  activeThumbColor: AppTheme.accentGreen,
                ),
              ],
            ),
            if (_loyaltyEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Müşterilere siparişlerinin %${_loyaltyPercentage.toInt()}\'si kadar puan ver',
                style: const TextStyle(color: AppTheme.mediumGray),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('%5', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _loyaltyPercentage,
                      min: 5,
                      max: 25,
                      divisions: 4,
                      label: '%${_loyaltyPercentage.toInt()}',
                      onChanged: (value) {
                        setState(() => _loyaltyPercentage = value);
                      },
                      onChangeEnd: (_) => _updateLoyaltySettings(),
                      activeColor: Colors.amber,
                    ),
                  ),
                  const Text('%25', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Örn: 100₺\'lik siparişte müşteri ${_loyaltyPercentage.toInt()} puan kazanır.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                'Sadakat programını açarak müşterilerinizi ödüllendirin ve tekrar gelmelerini sağlayın!',
                style: TextStyle(color: AppTheme.mediumGray, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
