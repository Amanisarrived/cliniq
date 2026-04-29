// lib/models/app_config_model.dart

class AppConfigModel {
  final int adCreditsPerAd;
  final bool announcementActive;
  final String announcementText;
  final String forceUpdateVersion;
  final int freeCreditsPerDay;
  final String latestVersion;
  final bool maintenanceMode;
  final int maxAdsPerDay;
  final int proPrice;

  const AppConfigModel({
    required this.adCreditsPerAd,
    required this.announcementActive,
    required this.announcementText,
    required this.forceUpdateVersion,
    required this.freeCreditsPerDay,
    required this.latestVersion,
    required this.maintenanceMode,
    required this.maxAdsPerDay,
    required this.proPrice,
  });

  factory AppConfigModel.fromMap(Map<String, dynamic> map) {
    return AppConfigModel(
      adCreditsPerAd: (map['adCreditsPerAd'] ?? 2) as int,
      announcementActive: (map['announcementActive'] ?? false) as bool,
      announcementText: (map['announcementText'] ?? '') as String,
      forceUpdateVersion: (map['forceUpdateVersion'] ?? '') as String,
      freeCreditsPerDay: (map['freeCreditsPerDay'] ?? 5) as int,
      latestVersion: (map['latestVersion'] ?? '') as String,
      maintenanceMode: (map['maintenanceMode'] ?? false) as bool,
      maxAdsPerDay: (map['maxAdsPerDay'] ?? 2) as int,
      proPrice: (map['proPrice'] ?? 149) as int,
    );
  }

  // Safe fallback when Firestore is unreachable
  factory AppConfigModel.defaults() {
    return const AppConfigModel(
      adCreditsPerAd: 2,
      announcementActive: false,
      announcementText: '',
      forceUpdateVersion: '',
      freeCreditsPerDay: 5,
      latestVersion: '',
      maintenanceMode: false,
      maxAdsPerDay: 2,
      proPrice: 149,
    );
  }
}
