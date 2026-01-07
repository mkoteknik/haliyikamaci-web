class PopupAdModel {
  final String id;
  final String title;
  final String imageUrl;
  final String targetAudience; // 'all', 'firm', 'customer'
  final bool isActive;
  final String? actionUrl;
  
  // Limits
  final int perUserDailyLimit;
  final int globalDailyLimit;
  final int globalTotalLimit;

  // Stats
  final int currentViewsToday;
  final int currentViewsTotal;
  final String lastViewDate; // YYYY-MM-DD

  PopupAdModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.targetAudience,
    required this.isActive,
    this.actionUrl,
    this.perUserDailyLimit = 0,
    this.globalDailyLimit = 0,
    this.globalTotalLimit = 0,
    this.currentViewsToday = 0,
    this.currentViewsTotal = 0,
    this.lastViewDate = '',
  });

  factory PopupAdModel.fromMap(Map<String, dynamic> map, String id) {
    return PopupAdModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      targetAudience: map['targetAudience'] ?? 'all',
      isActive: map['isActive'] ?? false,
      actionUrl: map['actionUrl'],
      perUserDailyLimit: map['perUserDailyLimit'] ?? 0,
      globalDailyLimit: map['globalDailyLimit'] ?? 0,
      globalTotalLimit: map['globalTotalLimit'] ?? 0,
      currentViewsToday: map['currentViewsToday'] ?? 0,
      currentViewsTotal: map['currentViewsTotal'] ?? 0,
      lastViewDate: map['lastViewDate'] ?? '',
    );
  }

  bool isTarget_valid(String userType) {
    if (targetAudience == 'all') return true;
    return targetAudience == userType;
  }
}
