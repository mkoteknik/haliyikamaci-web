
abstract class EnvConfig {
  // NOTE: Tapsin SMS credentials are now stored in Firebase Remote Config
  // for security. They are no longer hardcoded in the APK.
  // See: SecureConfigService

  // Security Salt for Proxy Auth to prevent trivial guessing of generated passwords
  // In production, this should be a complex secret or fetched securely
  static const String authSalt = 'HaliYikamaci_Secure_Salt_2025';

  // Test Mode Configuration
  static const String testPhoneNumber = '5551112233'; // Test User
  static const String testOtpCode = '123456';
}
