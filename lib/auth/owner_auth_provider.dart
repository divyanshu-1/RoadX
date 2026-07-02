import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/owner_model.dart';
import '../services/firebase_owner_service.dart';

/// Holds current owner session for guarded navigation.
class OwnerAuthProvider extends ChangeNotifier {
  final FirebaseOwnerService _service = FirebaseOwnerService();
  OwnerModel? _owner;
  bool _loading = false;

  OwnerModel? get owner => _owner;
  bool get isLoading => _loading;
  bool get isAuthenticated =>
      _service.isOwnerAccountLoggedIn() && _owner != null;

  Future<void> initSession() async {
    if (!_service.isOwnerAccountLoggedIn()) return;
    _loading = true;
    notifyListeners();
    _owner = await _service.getCurrentOwner();
    _loading = false;
    notifyListeners();
  }

  Future<OwnerModel?> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      _owner = await _service.loginOwner(email: email, password: password);
      return _owner;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setOwner(OwnerModel owner) {
    _owner = owner;
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.signOut();
    _owner = null;
    notifyListeners();
  }

  String mapAuthError(FirebaseAuthException e) =>
      _service.authErrorMessage(e);
}
