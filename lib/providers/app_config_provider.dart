// lib/providers/app_config_provider.dart

import 'package:flutter/material.dart';
import '../models/app_config_model.dart';
import '../services/app_config_service.dart';

class AppConfigProvider extends ChangeNotifier {
  final AppConfigService _service = AppConfigService();

  AppConfigModel _config = AppConfigModel.defaults();
  bool _isLoading = false;

  AppConfigModel get config => _config;
  bool get isLoading => _isLoading;

  bool get maintenanceMode => _config.maintenanceMode;
  String get forceUpdateVersion => _config.forceUpdateVersion;
  bool get hasAnnouncement =>
      _config.announcementActive && _config.announcementText.isNotEmpty;

  Future<void> loadConfig() async {
    _isLoading = true;
    notifyListeners();
    _config = await _service.fetchConfig();
    _isLoading = false;
    notifyListeners();
  }
}
