// lib/services/app_config_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_config_model.dart';

class AppConfigService {
  static const _collection = 'appConfig';
  static const _doc = 'config';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppConfigModel> fetchConfig() async {
    try {
      final snap = await _db.collection(_collection).doc(_doc).get();
      if (snap.exists && snap.data() != null) {
        return AppConfigModel.fromMap(snap.data()!);
      }
      return AppConfigModel.defaults();
    } catch (e) {
      return AppConfigModel.defaults();
    }
  }
}
