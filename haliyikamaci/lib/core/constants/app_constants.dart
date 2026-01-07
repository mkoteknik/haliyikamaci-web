/// App Constants - Uygulama sabitleri
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Halı Yıkamacı';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String firmsCollection = 'firms';
  static const String customersCollection = 'customers';
  static const String locationsCollection = 'locations';
  static const String servicesCollection = 'services';
  static const String vitrinsCollection = 'firm_vitrin_purchases';
  static const String campaignsCollection = 'campaigns';
  static const String smsPackagesCollection = 'smsPackages';
  static const String vitrinPackagesCollection = 'vitrinPackages';
  static const String campaignPackagesCollection = 'campaignPackages';
  static const String smsTransactionsCollection = 'smsPurchases'; // tentatively fixing this too based on admin/purchases.php matching
  static const String reviewsCollection = 'reviews';

  // User Types
  static const String userTypeFirm = 'firm';
  static const String userTypeCustomer = 'customer';
  static const String userTypeAdmin = 'admin';

  // SMS Costs (configurable from admin)
  static const int vitrinSmsCost = 50;
  static const int campaignSmsCost = 30;
  static const int notificationSmsCost = 1;
}
