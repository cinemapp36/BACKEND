import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthService() {
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      ApiClient.setToken(_token);
      try {
        await _fetchMe();
      } catch (_) {
        await logout();
      }
    }
  }

  Future<void> _fetchMe() async {
    final data = await ApiClient.get('/auth/me');
    _user = User.fromJson(data['user']);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });
      _token = data['token'];
      _user = User.fromJson(data['user']);
      ApiClient.setToken(_token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiClient.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });
      _token = data['token'];
      _user = User.fromJson(data['user']);
      ApiClient.setToken(_token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    ApiClient.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
