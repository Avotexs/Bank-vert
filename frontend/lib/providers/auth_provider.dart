import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    try {
      _token = await _apiService.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('jwt_token', _token!);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String firstname, String lastname, String email, String password) async {
    try {
      _token = await _apiService.register(firstname, lastname, email, password);
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
         await prefs.setString('jwt_token', _token!);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return;
    _token = prefs.getString('jwt_token');
    notifyListeners();
  }
}
