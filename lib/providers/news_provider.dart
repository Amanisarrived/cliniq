import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _error;

  List<NewsModel> get news => List.unmodifiable(_news);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNews => _news.isNotEmpty;

  // ─── Fetch News ───────────────────────────────
  Future<void> fetchNews() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _db
          .collection('health_news')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      _news = snap.docs
          .map((doc) => NewsModel.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('fetchNews error: $e');
      _error = 'Could not load news';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Refresh ──────────────────────────────────
  Future<void> refresh() async {
    _news = [];
    await fetchNews();
  }
}
