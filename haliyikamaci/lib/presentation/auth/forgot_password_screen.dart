import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Şifremi Unuttum Ekranı
/// 3 Aşamalı: Telefon Girişi → OTP Doğrulama → Yeni Şifre Belirleme
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Step tracking
  int _currentStep = 0; // 0: Phone, 1: OTP, 2: New Password
  
  // Controllers
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // State
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Colors
  static const Color _darkBlue = Color(0xFF1E3A5F);
  static const Color _green = Color(0xFF4CAF50);

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.forgotPassword),
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
                _errorMessage = null;
                _successMessage = null;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              
              // Step Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStep(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepCircle(0, 'Telefon'),
        _buildStepLine(0),
        _buildStepCircle(1, 'Doğrulama'),
        _buildStepLine(1),
        _buildStepCircle(2, 'Yeni Şifre'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? _darkBlue : Colors.grey[300],
              border: isCurrent ? Border.all(color: _green, width: 3) : null,
            ),
            child: Center(
              child: isActive && !isCurrent
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? _darkBlue : Colors.grey[500],
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 24),
        color: isActive ? _darkBlue : Colors.grey[300],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPhoneStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return const SizedBox();
    }
  }

  // ==================== STEP 1: PHONE ====================
  Widget _buildPhoneStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(Icons.phone_android, size: 80, color: _darkBlue.withAlpha(180)),
        const SizedBox(height: 24),
        
        // Title
        Text(
          l10n.enterPhoneNumber,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.verificationCodeWillBeSent,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Phone Input
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phoneNumber,
            prefixText: '+90 ',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: '5XX XXX XX XX',
          ),
        ),
        const SizedBox(height: 16),
        
        // Error/Success Messages
        if (_errorMessage != null)
          _buildMessageBox(_errorMessage!, isError: true),
        if (_successMessage != null)
          _buildMessageBox(_successMessage!, isError: false),
        
        const SizedBox(height: 24),
        
        // Submit Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleRequestOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(l10n.sendVerificationCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        
        const SizedBox(height: 16),
        
        // Back to Login
        TextButton(
          onPressed: () => context.pop(),
          child: Text(l10n.backToLogin, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  // ==================== STEP 2: OTP ====================
  Widget _buildOtpStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(Icons.sms, size: 80, color: _green.withAlpha(180)),
        const SizedBox(height: 24),
        
        // Title
        Text(
          l10n.verificationCode,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.verificationCodeSent} (+90 ${_phoneController.text})',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // OTP Input
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: l10n.verificationCode,
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: '• • • • • •',
          ),
        ),
        const SizedBox(height: 16),
        
        // Error/Success Messages
        if (_errorMessage != null)
          _buildMessageBox(_errorMessage!, isError: true),
        if (_successMessage != null)
          _buildMessageBox(_successMessage!, isError: false),
        
        const SizedBox(height: 24),
        
        // Submit Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleVerifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(l10n.verify, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        
        const SizedBox(height: 16),
        
        // Resend Code
        TextButton(
          onPressed: _isLoading ? null : _handleRequestOtp,
          child: Text(l10n.resendCode, style: const TextStyle(color: _darkBlue)),
        ),
      ],
    );
  }

  // ==================== STEP 3: NEW PASSWORD ====================
  Widget _buildNewPasswordStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Icon(Icons.lock_reset, size: 80, color: _darkBlue.withAlpha(180)),
        const SizedBox(height: 24),
        
        // Title
        Text(
          l10n.setNewPassword,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.passwordMinLength,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Password Input
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.newPassword,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        
        // Confirm Password
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: l10n.newPasswordConfirm,
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        
        // Error/Success Messages
        if (_errorMessage != null)
          _buildMessageBox(_errorMessage!, isError: true),
        if (_successMessage != null)
          _buildMessageBox(_successMessage!, isError: false),
        
        const SizedBox(height: 24),
        
        // Submit Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleResetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(l10n.updatePassword, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildMessageBox(String message, {required bool isError}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isError ? Colors.red : Colors.green),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: isError ? Colors.red[800] : Colors.green[800]),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HANDLERS ====================

  Future<void> _handleRequestOtp() async {
    final phone = _phoneController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    if (phone.isEmpty) {
      setState(() => _errorMessage = l10n.enterPhoneNumber);
      return;
    }

    if (phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      setState(() => _errorMessage = l10n.invalidPhoneNumber);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.requestPasswordReset(phone);

      if (result['success'] == true) {
        setState(() {
          _successMessage = result['message'];
          _currentStep = 1;
        });
      } else {
        setState(() => _errorMessage = result['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.serverError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    if (otp.isEmpty || otp.length != 6) {
      setState(() => _errorMessage = l10n.invalidCode);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.verifyPasswordResetOtp(_phoneController.text, otp);

      if (result['success'] == true) {
        setState(() {
          _successMessage = result['message'];
          _currentStep = 2;
        });
      } else {
        setState(() => _errorMessage = result['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.unknownError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    if (password.isEmpty) {
      setState(() => _errorMessage = l10n.newPassword);
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = l10n.passwordMinLength);
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.resetPasswordWithOtp(_phoneController.text, password);

      if (result['success'] == true) {
        // Show success dialog and redirect to login
        if (mounted) {
          final l10nDialog = AppLocalizations.of(context)!;
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              title: Text(l10nDialog.passwordUpdated),
              content: Text(
                l10nDialog.passwordUpdatedMessage,
                textAlign: TextAlign.center,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _green),
                  child: Text(l10nDialog.login),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() => _errorMessage = result['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = l10n.passwordUpdateError);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
