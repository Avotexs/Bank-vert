import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  String? _firstname;
  String? _lastname;
  String? _email;

  String? get token => _token;
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get email => _email;

  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    try {
      _token = await _apiService.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('jwt_token', _token!);
        await fetchProfile();
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(
    String firstname,
    String lastname,
    String email,
    String password,
  ) async {
    try {
      _token = await _apiService.register(firstname, lastname, email, password);
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('jwt_token', _token!);
        _firstname = firstname;
        _lastname = lastname;
        _email = email;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final profile = await _apiService.getProfile();
      _firstname = profile['firstname'];
      _lastname = profile['lastname'];
      _email = profile['email'];
      notifyListeners();
    } catch (e) {
      // Silently fail - profile will show default
    }
  }

  Future<void> updateProfile(String firstname, String lastname) async {
    try {
      final profile = await _apiService.updateProfile(firstname, lastname);
      _firstname = profile['firstname'];
      _lastname = profile['lastname'];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _firstname = null;
    _lastname = null;
    _email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return;
    _token = prefs.getString('jwt_token');
    if (_token != null) {
      await fetchProfile();
    }
    notifyListeners();
  }
}
