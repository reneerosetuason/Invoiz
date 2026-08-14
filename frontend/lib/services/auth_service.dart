import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  String? _token;
  User? _user;
  bool _loading = true;

  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _loading;
  bool get isLoggedIn => _token != null;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    ApiService.setToken(_token);
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await ApiService().post('login', {'email': email, 'password': password});
    await _saveSession(data);
  }

  Future<void> saveAfterRegistration() async {
    // Registration does not log the user in; they must wait for approval.
  }

  Future<void> _saveSession(dynamic data) async {
    _token = data['token'] as String;
    _user = User.fromJson(data['user'] as Map<String, dynamic>);
    ApiService.setToken(_token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token!);
    await prefs.setString(_userKey, jsonEncode(data['user']));
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final data = await ApiService().get('me');
      _user = User.fromJson(data['user'] as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(data['user']));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await ApiService().post('logout', {});
    } catch (_) {}
    _token = null;
    _user = null;
    ApiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }
}