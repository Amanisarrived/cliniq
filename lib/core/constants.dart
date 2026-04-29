class AppConstants {
  // Firestore
  static const String usersCollection = 'users';
  static const String scansSubCollection = 'scans';
  static const String remindersSubCollection = 'reminders';
  static const String prescriptionsSubCollection = 'prescriptions';
  static const String familySubCollection = 'family';
  static const String configCollection = 'appConfig';
  static const String configDocId = 'config';
  static const String statsCollection = 'appStats';
  static const String statsDocId = 'global';
  static const String medicineCacheCollection = 'medicine_cache';

  // Cloud Functions
  static const String fnScanMedicine = 'scanMedicine';
  static const String fnSicknessGuide = 'sicknessGuide';
  static const String fnRewardAdCredits = 'rewardAdCredits';

  // SharedPreferences
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyTermsAccepted = 'terms_accepted';

  // Credits
  static const int defaultFreeCredits = 5;
  static const int adCreditsReward = 2;
  static const int maxAdsPerDay = 3;
}
