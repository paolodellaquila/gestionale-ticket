import 'package:flutter/foundation.dart';

import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    restoreSession();
  }

  final AuthRepository _repository;

  AppUser? _user;
  bool _isRestoring = true;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _user;
  bool get isAuthenticated => _user != null;
  bool get isRestoring => _isRestoring;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    _isRestoring = true;
    notifyListeners();

    try {
      final userId = await _repository.getStoredUserId();
      if (userId != null) {
        _user = await _repository.getUserById(userId);
      }
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final trimmedUser = username.trim();
    if (trimmedUser.isEmpty || password.isEmpty) {
      _errorMessage = 'Inserisci username e password.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.login(trimmedUser, password);
      if (user == null) {
        _errorMessage = 'Credenziali non valide.';
        return false;
      }
      await _repository.saveSession(user.id);
      _user = user;
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.clearSession();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
