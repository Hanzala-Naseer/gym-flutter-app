import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    if (token != null) {
      try {
        final response = await ApiService.getMemberProfile();
        if (response['success']) {
          _isAuthenticated = true;
          _user = response['data'];
          notifyListeners();
        }
      } catch (e) {
        await logout();
      }
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.memberLogin(
        email: email,
        password: password,
      );

      if (response['success']) {
        await ApiService.saveToken(response['data']['token']);
        _isAuthenticated = true;
        _user = response['data']['member'];
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await ApiService.removeToken();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final response = await ApiService.getMemberProfile();
    if (response['success']) {
      _user = response['data'];
      notifyListeners();
    }
  }
}
