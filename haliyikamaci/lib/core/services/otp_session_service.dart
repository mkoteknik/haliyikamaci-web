import 'package:shared_preferences/shared_preferences.dart';

/// OTP bypass logic service
/// Manages 12-hour OTP verification bypass and code storage
class OtpSessionService {
  static const String _lastOtpVerificationKey = 'last_otp_verification_time';
  static const String _verifiedPhoneKey = 'verified_phone_number';
  static const String _storedOtpCodeKey = 'stored_otp_code';
  static const String _otpSentTimeKey = 'otp_sent_time';
  static const Duration _bypassDuration = Duration(hours: 12);

  /// Check if OTP should be bypassed (within 12 hours of last verification)
  Future<bool> shouldBypassOtp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastVerificationMs = prefs.getInt(_lastOtpVerificationKey);
      
      if (lastVerificationMs == null) {
        return false;
      }
      
      final lastVerification = DateTime.fromMillisecondsSinceEpoch(lastVerificationMs);
      final now = DateTime.now();
      final difference = now.difference(lastVerification);
      
      // If less than 12 hours passed, bypass OTP
      return difference < _bypassDuration;
    } catch (e) {
      return false;
    }
  }

  /// Check if new OTP can be sent (12 hour limit)
  Future<bool> canSendNewOtp(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPhone = prefs.getString(_verifiedPhoneKey);
      final otpSentTimeMs = prefs.getInt(_otpSentTimeKey);
      
      // Different phone number, allow new OTP
      if (storedPhone != phone) {
        return true;
      }
      
      // No OTP sent before, allow
      if (otpSentTimeMs == null) {
        return true;
      }
      
      final otpSentTime = DateTime.fromMillisecondsSinceEpoch(otpSentTimeMs);
      final now = DateTime.now();
      final difference = now.difference(otpSentTime);
      
      // If 12 hours passed, allow new OTP
      return difference >= _bypassDuration;
    } catch (e) {
      return true;
    }
  }

  /// Get stored OTP code if still valid
  Future<String?> getStoredOtpCode(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPhone = prefs.getString(_verifiedPhoneKey);
      final otpSentTimeMs = prefs.getInt(_otpSentTimeKey);
      
      // Different phone, no stored code
      if (storedPhone != phone) {
        return null;
      }
      
      // Check if OTP still valid (12 hours)
      if (otpSentTimeMs == null) {
        return null;
      }
      
      final otpSentTime = DateTime.fromMillisecondsSinceEpoch(otpSentTimeMs);
      final now = DateTime.now();
      final difference = now.difference(otpSentTime);
      
      if (difference >= _bypassDuration) {
        return null; // Code expired
      }
      
      return prefs.getString(_storedOtpCodeKey);
    } catch (e) {
      return null;
    }
  }

  /// Save OTP code when sent
  Future<void> saveOtpCode(String phone, String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_verifiedPhoneKey, phone);
      await prefs.setString(_storedOtpCodeKey, code);
      await prefs.setInt(_otpSentTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silent fail
    }
  }

  /// Get remaining time for existing OTP
  Future<String?> getRemainingOtpTime(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPhone = prefs.getString(_verifiedPhoneKey);
      final otpSentTimeMs = prefs.getInt(_otpSentTimeKey);
      
      if (storedPhone != phone || otpSentTimeMs == null) {
        return null;
      }
      
      final otpSentTime = DateTime.fromMillisecondsSinceEpoch(otpSentTimeMs);
      final expiryTime = otpSentTime.add(_bypassDuration);
      final now = DateTime.now();
      
      if (now.isAfter(expiryTime)) {
        return null;
      }
      
      final remaining = expiryTime.difference(now);
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      
      if (hours > 0) {
        return '$hours saat $minutes dakika';
      } else {
        return '$minutes dakika';
      }
    } catch (e) {
      return null;
    }
  }

  /// Save OTP verification time (call after successful OTP verification)
  Future<void> saveOtpVerificationTime(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastOtpVerificationKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_verifiedPhoneKey, phoneNumber);
    } catch (e) {
      // Silent fail
    }
  }

  /// Get the verified phone number
  Future<String?> getVerifiedPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_verifiedPhoneKey);
    } catch (e) {
      return null;
    }
  }

  /// Clear session (call on logout)
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastOtpVerificationKey);
      await prefs.remove(_verifiedPhoneKey);
      await prefs.remove(_storedOtpCodeKey);
      await prefs.remove(_otpSentTimeKey);
    } catch (e) {
      // Silent fail
    }
  }
}

