import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../data/providers/providers.dart';
import '../../core/providers/locale_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController(); 
  bool _isFirmLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Colors from the image
  static const Color _darkBlue = Color(0xFF1E3A5F); // approximate dark blue from image
  static const Color _green = Color(0xFF4CAF50); // approximate green

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppLocalizations.of(context)!; // Using l10n is good but for precise UI match let's stick to base first or keep l10n
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      resizeToAvoidBottomInset: false, // Handle keyboard manually or let listview handle it
      body: SafeArea(
        child: Column(
          children: [
             // Header: Lang Selector
             Padding(
               padding: const EdgeInsets.only(top: 16, right: 16),
               child: Align(
                 alignment: Alignment.centerRight,
                 child: _buildLanguageSelector(ref),
               ),
             ),
             
           Expanded(
               child: Center(
                 child: SingleChildScrollView(
                   padding: const EdgeInsets.symmetric(horizontal: 24),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.stretch,
                     children: [
                       // Logo
                       Image.asset(
                         'assets/images/logo.png', // Ensure this exists, or use text fallback
                         height: 120, // Bigger logo
                         fit: BoxFit.contain,
                         errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              l10n.appTitle,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _darkBlue, fontFamily: 'Cursive'),
                            ),
                         ),
                       ),
                       const SizedBox(height: 32),

                       // [1] Segmented Tabs with White Background Card
                       Container(
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: [
                              BoxShadow(color: Colors.grey.withAlpha(80), blurRadius: 8, offset: const Offset(0, 3))
                           ],
                         ),
                         child: Row(
                           children: [
                             Expanded(child: _buildSegmentedTab(l10n.firmLogin, Icons.business, true)),
                             Expanded(child: _buildSegmentedTab(l10n.customerLogin, Icons.person, false)),
                           ],
                         ),
                       ),
                       const SizedBox(height: 24),

                       // [2] Form Area with White Background Card
                       Container(
                         padding: const EdgeInsets.all(24),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(16),
                           boxShadow: [
                              BoxShadow(color: Colors.grey.withAlpha(80), blurRadius: 10, offset: const Offset(0, 4))
                           ],
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [
                             // Form Title
                             Text(
                               _isFirmLogin ? l10n.firmLogin : l10n.customerLogin,
                               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                               textAlign: TextAlign.left,
                             ),
                             const SizedBox(height: 20),

                             // Phone Input
                             TextField(
                               controller: _phoneController,
                               keyboardType: TextInputType.phone,
                               decoration: InputDecoration(
                                 labelText: l10n.phoneNumber,
                                 prefixIcon: const Icon(Icons.phone),
                                 prefixText: '+90 ',
                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                               ),
                             ),
                             const SizedBox(height: 16),

                             // Password Input
                             TextField(
                               controller: _passwordController,
                               obscureText: _obscurePassword,
                               decoration: InputDecoration(
                                 labelText: l10n.password,
                                 prefixIcon: const Icon(Icons.lock),
                                 suffixIcon: IconButton(
                                   icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                   onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                 ),
                                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                               ),
                             ),
                             const SizedBox(height: 20),

                             // Login Button
                             ElevatedButton(
                               onPressed: _isLoading ? null : _handleLogin,
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: _darkBlue,
                                 foregroundColor: Colors.white,
                                 padding: const EdgeInsets.symmetric(vertical: 16),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                 elevation: 2,
                               ),
                               child: _isLoading
                                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                   : Text(l10n.login, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                             ),
                             const SizedBox(height: 12),

                             // Register Link
                             TextButton(
                               onPressed: _handleRegister,
                               child: Text(
                                 _isFirmLogin ? l10n.createFirmRegistration : l10n.createCustomerRegistration,
                                 style: TextStyle(color: _darkBlue.withAlpha(200)),
                               ),
                             ),
                             
                             // Forgot Password Link
                             TextButton(
                               onPressed: () => context.push('/forgot-password'),
                               child: Text(
                                 l10n.forgotPassword,
                                 style: TextStyle(color: Colors.grey[600]),
                               ),
                             ),
                           ],
                         ),
                       ),
                       
                       // [3] Demo Mode (Green Box) - Moved inside scroll view with reduced spacing
                       const SizedBox(height: 24), // Reduced from being at bottom
                       Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: _green.withAlpha(30), // Light green bg
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(color: _green.withAlpha(100)),
                         ),
                         child: Column(
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 const Icon(Icons.play_circle_filled, color: _green, size: 20),
                                 const SizedBox(width: 8),
                                 Text(l10n.demoMode, style: const TextStyle(color: _green, fontWeight: FontWeight.bold)),
                               ],
                             ),
                             const SizedBox(height: 12),
                             Row(
                               children: [
                                 Expanded(
                                   child: ElevatedButton.icon(
                                     onPressed: () => _handleDemoLogin('firm'),
                                     icon: const Icon(Icons.business, size: 18),
                                     label: Text(l10n.firm),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: _darkBlue,
                                       foregroundColor: Colors.white,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: ElevatedButton.icon(
                                     onPressed: () => _handleDemoLogin('customer'),
                                     icon: const Icon(Icons.person, size: 18),
                                     label: Text(l10n.customer),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: _green,
                                       foregroundColor: Colors.white,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                     ),
                                   ),
                                 ),
                               ],
                             )
                           ],
                         ),
                       ),
                       const SizedBox(height: 16), // Bottom padding
                     ],
                   ),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTab(String title, IconData icon, bool isFirmTab) {
    final bool isSelected = _isFirmLogin == isFirmTab;
    return GestureDetector(
      onTap: () => setState(() => _isFirmLogin = isFirmTab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Language Selector (Cleaned up)
  Widget _buildLanguageSelector(WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(50), blurRadius: 4)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFlag(ref, 'tr', '🇹🇷', currentLocale.languageCode == 'tr'),
          const SizedBox(width: 8),
          _buildFlag(ref, 'en', '🇺🇸', currentLocale.languageCode == 'en'),
        ],
      ),
    );
  }
  
  Widget _buildFlag(WidgetRef ref, String code, String flag, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.5,
        child: Text(flag, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  // ... Logic Methods (Keep exactly same implementation) ...
  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      _showMessage('Lütfen telefon numarası girin', isError: true);
      return;
    }
    if (password.isEmpty) {
      _showMessage('Lütfen şifre girin', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // 1. Sign in with Phone+Password
      await authRepo.signInWithPassword(phone, password);

      // [CRITICAL FIX] Clear Demo Mode to prevent stuck redirection
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('demo_mode');
        await prefs.remove('demo_user_type');
        debugPrint('🧹 Login: Kesinlikle Demo Mod temizlendi.');
      } catch (e) {
        debugPrint('⚠️ Demo temizleme hatası: $e');
      }

      // 2. Check User Type Match
      // 2. Check User Type Match (Use UID for reliability)
      final currentUser = authRepo.currentUser;
      if (currentUser == null) throw Exception('Auth failed');

      final user = await authRepo.getUserByUid(currentUser.uid);
      
      if (user == null) {
          await authRepo.signOut(); 
          setState(() => _isLoading = false);
          _showMessage('Kullanıcı profili bulunamadı.', isError: true);
          return;
      }

      final selectedType = _isFirmLogin ? 'firm' : 'customer';
      if (user.userType != selectedType) {
         // Wrong login type
         await authRepo.signOut(); 
         setState(() => _isLoading = false);
         
         if (user.userType == 'admin') {
           _showMessage('Yönetici girişi sadece Web Paneli üzerinden yapılabilir.', isError: true);
         } else {
           _showMessage('Bu hesap ${_isFirmLogin ? "Müşteri" : "Firma"} hesabıdır.', isError: true);
         }
         return;
      }

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (_isFirmLogin) {
        context.go('/firm');
      } else {
        context.go('/customer');
      }

    } catch (e) {
      setState(() => _isLoading = false);
      final l10n = AppLocalizations.of(context)!;
      _showMessage(l10n.loginFailed, isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null));
  }

  void _handleRegister() {
    if (_isFirmLogin) {
      context.push('/register/firm');
    } else {
      context.push('/register/customer');
    }
  }

  Future<void> _handleDemoLogin(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('demo_mode', true);
    await prefs.setString('demo_user_type', type);
    
    // Seed demo data if needed (optional, keeping it light)
    // await ref.read(seedDemoDataProvider).seedDataIfNeeded();

    if (!mounted) return;
    
    if (type == 'firm') {
      context.go('/firm');
    } else {
      context.go('/customer');
    }
  }
}
