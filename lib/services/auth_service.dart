import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _currentUser = ValueNotifier<User?>(null);
  ValueListenable<User?> get currentUser => _currentUser;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser.value = User.fromJson(json.decode(userJson));
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String address,
  }) async {
    try {
      // TODO: Replace with actual API call
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        address: address,
      );

      await _saveUser(user);
      _currentUser.value = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual API call
      if (email == 'demo@demo.com' && password == '123456') {
        final user = User(
          id: '1',
          name: 'مستخدم تجريبي',
          email: email,
          address: 'دبي، الإمارات العربية المتحدة',
        );

        await _saveUser(user);
        _currentUser.value = user;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String address,
  }) async {
    final user = _currentUser.value;
    if (user == null) {
      throw Exception('يرجى تسجيل الدخول أولاً');
    }

    // TODO: Add API integration
    // For now, we'll just update the user locally
    _currentUser.value = User(
      id: user.id,
      name: name,
      email: email,
      address: address,
    );
    await _saveUser(_currentUser.value!);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _currentUser.value = null;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
  }

  bool get isLoggedIn => _currentUser.value != null;
}
