import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider({required AuthService authService})
      : _authService = authService {
    _init();
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  void _init() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        _setStatus(AuthStatus.unauthenticated);
        return false;
      }
      _user = result.user;
      _setStatus(AuthStatus.authenticated);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  Future<void> signOut() async {
    _setStatus(AuthStatus.loading);
    try {
      await _authService.signOut();
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _setStatus(AuthStatus.error);
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _setStatus(_user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated);
    }
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('network')) {
      return 'No internet connection. Please try again.';
    } else if (error.contains('cancelled')) {
      return 'Sign in was cancelled.';
    } else if (error.contains('account-exists')) {
      return 'An account already exists with this email.';
    }
    return 'Something went wrong. Please try again.';
  }
}
