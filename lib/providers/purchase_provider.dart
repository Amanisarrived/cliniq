import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchase_service.dart';

enum PurchaseStatus { idle, loading, success, error, cancelled }

class PurchaseProvider extends ChangeNotifier {
  final PurchaseService _service = PurchaseService.instance;

  PurchaseStatus _status = PurchaseStatus.idle;
  bool _isPro = false;
  Offerings? _offerings;
  String? _error;

  PurchaseStatus get status => _status;
  bool get isPro => _isPro;
  Offerings? get offerings => _offerings;
  String? get error => _error;
  bool get isLoading => _status == PurchaseStatus.loading;

  // ─── Check Pro Status ─────────────────────────────
  Future<void> checkProStatus() async {
    try {
      _isPro = await _service.isPro();
      notifyListeners();
    } catch (e) {
      debugPrint('checkProStatus error: $e');
    }
  }

  // ─── Load Offerings ───────────────────────────────
  Future<void> loadOfferings() async {
    _setStatus(PurchaseStatus.loading);
    try {
      _offerings = await _service.getOfferings();
      _setStatus(PurchaseStatus.idle);
    } catch (e) {
      debugPrint('loadOfferings error: $e');
      _setError('Could not load plans. Please try again.');
    }
  }

  // ─── Purchase ─────────────────────────────────────
  Future<void> purchase(Package package) async {
    _setStatus(PurchaseStatus.loading);
    try {
      final success = await _service.purchase(package);
      if (success) {
        _isPro = true;
        _setStatus(PurchaseStatus.success);
      } else {
        _setStatus(PurchaseStatus.cancelled);
      }
    } catch (e) {
      debugPrint('purchase error: $e');
      _setError('Purchase failed. Please try again.');
    }
  }

  // ─── Restore ──────────────────────────────────────
  Future<void> restorePurchases() async {
    _setStatus(PurchaseStatus.loading);
    try {
      final success = await _service.restorePurchases();
      if (success) {
        _isPro = true;
        _setStatus(PurchaseStatus.success);
      } else {
        _setError('No previous purchases found.');
      }
    } catch (e) {
      debugPrint('restorePurchases error: $e');
      _setError('Restore failed. Please try again.');
    }
  }

  // ─── Update Pro from Firestore ────────────────────
  // UserProvider stream se automatically sync hoga
  void setProFromFirestore(bool isPro) {
    if (_isPro != isPro) {
      _isPro = isPro;
      notifyListeners();
    }
  }

  void _setStatus(PurchaseStatus s) {
    _status = s;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = PurchaseStatus.error;
    _error = msg;
    notifyListeners();
  }

  void clearStatus() {
    _status = PurchaseStatus.idle;
    _error = null;
    notifyListeners();
  }
}
