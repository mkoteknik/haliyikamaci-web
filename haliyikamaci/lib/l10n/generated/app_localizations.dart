import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Carpet Cleaner'**
  String get appTitle;

  /// No description provided for @firmLogin.
  ///
  /// In en, this message translates to:
  /// **'Business Login'**
  String get firmLogin;

  /// No description provided for @customerLogin.
  ///
  /// In en, this message translates to:
  /// **'Customer Login'**
  String get customerLogin;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendVerificationCode;

  /// No description provided for @createFirmRegistration.
  ///
  /// In en, this message translates to:
  /// **'Create Business Account'**
  String get createFirmRegistration;

  /// No description provided for @createCustomerRegistration.
  ///
  /// In en, this message translates to:
  /// **'Create Customer Account'**
  String get createCustomerRegistration;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo Mode'**
  String get demoMode;

  /// No description provided for @demoFirm.
  ///
  /// In en, this message translates to:
  /// **'Demo Business'**
  String get demoFirm;

  /// No description provided for @demoCustomer.
  ///
  /// In en, this message translates to:
  /// **'Demo Customer'**
  String get demoCustomer;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @fillCodeAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Autofill Code'**
  String get fillCodeAutomatically;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get verificationCodeSent;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @campaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaigns;

  /// No description provided for @firms.
  ///
  /// In en, this message translates to:
  /// **'Firms'**
  String get firms;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @showcase.
  ///
  /// In en, this message translates to:
  /// **'Showcase'**
  String get showcase;

  /// No description provided for @nearbyFirms.
  ///
  /// In en, this message translates to:
  /// **'Nearby Firms'**
  String get nearbyFirms;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @carpetCleaning.
  ///
  /// In en, this message translates to:
  /// **'Carpet Cleaning'**
  String get carpetCleaning;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for firms...'**
  String get searchHint;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on Map'**
  String get showOnMap;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. The following data will be permanently deleted:'**
  String get deleteAccountWarning;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get newPasswordConfirm;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @businessRegistration.
  ///
  /// In en, this message translates to:
  /// **'Business Registration'**
  String get businessRegistration;

  /// No description provided for @customerRegistration.
  ///
  /// In en, this message translates to:
  /// **'Customer Registration'**
  String get customerRegistration;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your login password'**
  String get changePasswordSubtitle;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters!'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed'**
  String get passwordChanged;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password Updated!'**
  String get passwordUpdated;

  /// No description provided for @passwordUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully.\nYou can now log in with your new password.'**
  String get passwordUpdatedMessage;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: Invalid password or phone number'**
  String get loginFailed;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Phone Number'**
  String get enterPhoneNumber;

  /// No description provided for @verificationCodeWillBeSent.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification code to your registered phone number.'**
  String get verificationCodeWillBeSent;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyAttempts;

  /// No description provided for @firm.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get firm;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @verificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code has been sent to your phone number.'**
  String get verificationCodeSentTo;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didNotReceiveCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidCode;

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Please request a new one.'**
  String get codeExpired;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @firmName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get firmName;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappNumber;

  /// No description provided for @taxOffice.
  ///
  /// In en, this message translates to:
  /// **'Tax Office'**
  String get taxOffice;

  /// No description provided for @taxNumber.
  ///
  /// In en, this message translates to:
  /// **'Tax Number'**
  String get taxNumber;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @neighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhood;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressDetails.
  ///
  /// In en, this message translates to:
  /// **'Address Details'**
  String get addressDetails;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Select Neighborhood'**
  String get selectNeighborhood;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @addressInfo.
  ///
  /// In en, this message translates to:
  /// **'Address Info'**
  String get addressInfo;

  /// No description provided for @businessInfo.
  ///
  /// In en, this message translates to:
  /// **'Business Info'**
  String get businessInfo;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registrationSuccess;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully.'**
  String get registrationSuccessMessage;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration Failed'**
  String get registrationFailed;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get serverError;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet connection.'**
  String get connectionError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @passwordResetRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Password reset request not found'**
  String get passwordResetRequestNotFound;

  /// No description provided for @enterVerificationCodeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code first'**
  String get enterVerificationCodeFirst;

  /// No description provided for @passwordUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating password'**
  String get passwordUpdateError;

  /// No description provided for @contracts.
  ///
  /// In en, this message translates to:
  /// **'Agreements'**
  String get contracts;

  /// No description provided for @contractsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve legal documents'**
  String get contractsSubtitle;

  /// No description provided for @approveContracts.
  ///
  /// In en, this message translates to:
  /// **'Approve Agreements'**
  String get approveContracts;

  /// No description provided for @pleaseApproveContracts.
  ///
  /// In en, this message translates to:
  /// **'Please approve all agreements'**
  String get pleaseApproveContracts;

  /// No description provided for @contractsWarning.
  ///
  /// In en, this message translates to:
  /// **'You must approve all agreements to continue.'**
  String get contractsWarning;

  /// No description provided for @registrationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Registration Completed!'**
  String get registrationCompleted;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// No description provided for @selectCityDistrict.
  ///
  /// In en, this message translates to:
  /// **'Please select city and district'**
  String get selectCityDistrict;

  /// No description provided for @phoneAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered.'**
  String get phoneAlreadyRegistered;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @whatsappNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number (Optional)'**
  String get whatsappNumberOptional;

  /// No description provided for @tenDigitTaxNumber.
  ///
  /// In en, this message translates to:
  /// **'10-digit tax number'**
  String get tenDigitTaxNumber;

  /// No description provided for @enterFirmAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter business address'**
  String get enterFirmAddress;

  /// No description provided for @businessAddress.
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get businessAddress;

  /// No description provided for @fillMandatoryFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all mandatory fields (Business Name, Phone, Tax Number)'**
  String get fillMandatoryFields;

  /// No description provided for @registrationReceived.
  ///
  /// In en, this message translates to:
  /// **'Registration Received!'**
  String get registrationReceived;

  /// No description provided for @firmRegistrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your business registration has been created successfully.\n\nYou can log in to your business panel after admin approval.'**
  String get firmRegistrationSuccessMessage;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @accounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accounting;

  /// No description provided for @accountingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Income and expense tracking'**
  String get accountingSubtitle;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @usageAndInfo.
  ///
  /// In en, this message translates to:
  /// **'Usage & Info (Credits)'**
  String get usageAndInfo;

  /// No description provided for @myQrCode.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get myQrCode;

  /// No description provided for @myPromoCodes.
  ///
  /// In en, this message translates to:
  /// **'My Promo Codes'**
  String get myPromoCodes;

  /// No description provided for @createDiscountCodes.
  ///
  /// In en, this message translates to:
  /// **'Create discount codes'**
  String get createDiscountCodes;

  /// No description provided for @adminSupport.
  ///
  /// In en, this message translates to:
  /// **'Admin Support'**
  String get adminSupport;

  /// No description provided for @adminSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Technical support and help'**
  String get adminSupportSubtitle;

  /// No description provided for @selectCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Select Cover Image'**
  String get selectCoverImage;

  /// No description provided for @coverImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Cover image updated'**
  String get coverImageUpdated;

  /// No description provided for @logoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Logo updated!'**
  String get logoUpdated;

  /// No description provided for @addressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get addressUpdated;

  /// No description provided for @qrCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your customers can scan this code to reach your profile.'**
  String get qrCodeDescription;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @loyaltySystem.
  ///
  /// In en, this message translates to:
  /// **'Loyalty System'**
  String get loyaltySystem;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @settingsAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Settings & Support'**
  String get settingsAndSupport;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications, Help, About, Privacy'**
  String get settingsSubtitle;

  /// No description provided for @noRegisteredAddresses.
  ///
  /// In en, this message translates to:
  /// **'You have no registered addresses yet.'**
  String get noRegisteredAddresses;

  /// No description provided for @unnamedAddress.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Address'**
  String get unnamedAddress;

  /// No description provided for @addressConstraint.
  ///
  /// In en, this message translates to:
  /// **'You must have at least one address.'**
  String get addressConstraint;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit Address'**
  String get editAddress;

  /// No description provided for @totalAccumulatedPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Accumulated Points'**
  String get totalAccumulatedPoints;

  /// No description provided for @firmBasedPoints.
  ///
  /// In en, this message translates to:
  /// **'Firm Based Points'**
  String get firmBasedPoints;

  /// No description provided for @noPointsFromFirms.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t earned points from any firm yet.'**
  String get noPointsFromFirms;

  /// No description provided for @unknownFirm.
  ///
  /// In en, this message translates to:
  /// **'Unknown Firm'**
  String get unknownFirm;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @noFavoriteFirms.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any favorite firms yet.'**
  String get noFavoriteFirms;

  /// No description provided for @discoverFirmsHint.
  ///
  /// In en, this message translates to:
  /// **'Discover firms and add the ones you like to favorites'**
  String get discoverFirmsHint;

  /// No description provided for @noFavoriteFirmsFound.
  ///
  /// In en, this message translates to:
  /// **'No favorite firms found'**
  String get noFavoriteFirmsFound;

  /// No description provided for @orderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Order Notifications'**
  String get orderNotifications;

  /// No description provided for @orderNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified about order status changes'**
  String get orderNotificationsSubtitle;

  /// No description provided for @campaignNotifications.
  ///
  /// In en, this message translates to:
  /// **'Campaign Notifications'**
  String get campaignNotifications;

  /// No description provided for @campaignNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified about discounts and campaigns'**
  String get campaignNotificationsSubtitle;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @smsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive important information via SMS'**
  String get smsNotificationsSubtitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'The most practical solution for your carpet cleaning needs.'**
  String get appDescription;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get homeAddress;

  /// No description provided for @editProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Information'**
  String get editProfileInfo;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @yourSurname.
  ///
  /// In en, this message translates to:
  /// **'Your Surname'**
  String get yourSurname;

  /// No description provided for @phoneCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Your phone number is your login credential and cannot be changed.'**
  String get phoneCannotBeChanged;

  /// No description provided for @changePasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Use the button below to change your password.'**
  String get changePasswordHint;

  /// No description provided for @nameSurnameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name and surname cannot be empty'**
  String get nameSurnameCannotBeEmpty;

  /// No description provided for @nameSurnameProfanityWarning.
  ///
  /// In en, this message translates to:
  /// **'Name or surname contains inappropriate expressions.'**
  String get nameSurnameProfanityWarning;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed'**
  String get passwordChangedSuccess;

  /// No description provided for @privacyPolicyNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy not defined yet'**
  String get privacyPolicyNotDefined;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any reviews yet'**
  String get noReviewsYet;

  /// No description provided for @reviewAfterOrderHint.
  ///
  /// In en, this message translates to:
  /// **'You can review after your orders are completed'**
  String get reviewAfterOrderHint;

  /// No description provided for @editReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Review'**
  String get editReview;

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your Comment'**
  String get yourComment;

  /// No description provided for @reviewUpdated.
  ///
  /// In en, this message translates to:
  /// **'Review updated'**
  String get reviewUpdated;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete Review'**
  String get deleteReview;

  /// No description provided for @deleteReviewConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get deleteReviewConfirm;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted'**
  String get reviewDeleted;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @deleteFirmAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your business account?'**
  String get deleteFirmAccountConfirmation;

  /// No description provided for @deleteWarningItem1.
  ///
  /// In en, this message translates to:
  /// **'• Business profile information'**
  String get deleteWarningItem1;

  /// No description provided for @deleteWarningItem2.
  ///
  /// In en, this message translates to:
  /// **'• Address and contact information'**
  String get deleteWarningItem2;

  /// No description provided for @deleteWarningItem3.
  ///
  /// In en, this message translates to:
  /// **'• All showcase items and campaigns'**
  String get deleteWarningItem3;

  /// No description provided for @deleteWarningItem4.
  ///
  /// In en, this message translates to:
  /// **'• Customer reviews and ratings'**
  String get deleteWarningItem4;

  /// No description provided for @deleteWarningItem5.
  ///
  /// In en, this message translates to:
  /// **'• Credit balance'**
  String get deleteWarningItem5;

  /// No description provided for @deleteWarningItem6.
  ///
  /// In en, this message translates to:
  /// **'• Employee comments and ratings'**
  String get deleteWarningItem6;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone!'**
  String get actionCannotBeUndone;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account...'**
  String get deletingAccount;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @accountDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: '**
  String get accountDeleteError;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @reviewCount.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviewCount;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
