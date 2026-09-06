import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _token;

  static const String baseUrl =
      // kIsWeb ? 'http://localhost:8000' : 'http://10.110.250.159:8000';
      kIsWeb ? 'http://localhost:8000' : 'http://192.168.22.159:8000';

  // 🔑 yahan se baaki app token access karegi
  String? get token => _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone': phone, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        _token = data['access_token'] as String?;
        if (_token == null || _token!.isEmpty) {
          _error = 'Invalid token received';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        final meOk = await _fetchMe();
        _isLoading = false;
        notifyListeners();
        return meOk;
      } else {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Login failed';
        } catch (_) {
          _error = 'Login failed (${res.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(
    String name,
    String email,
    String password,
    String phone,
    String address,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': name,
          'phone': phone,
          'password': password,
          'email': email.isEmpty ? null : email,
          'address': address,
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final loginOk = await login(phone, password);
        _isLoading = false;
        notifyListeners();
        return loginOk;
      } else {
        try {
          final err = json.decode(res.body);
          _error = err['detail']?.toString() ?? 'Signup failed';
        } catch (_) {
          _error = 'Signup failed (${res.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Signup failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await _clearUserFromStorage();
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        await _fetchMe();
        notifyListeners();
        return;
      }

      final id = prefs.getString('user_id');
      if (id != null && id.isNotEmpty) {
        _user = User(
          id: id,
          name: prefs.getString('user_name') ?? '',
          email: prefs.getString('user_email') ?? '',
          phone: prefs.getString('user_phone') ?? '',
          address: prefs.getString('user_address') ?? '',
          createdAt: DateTime.parse(
            prefs.getString('user_created_at') ??
                DateTime.now().toIso8601String(),
          ),
          updatedAt: DateTime.parse(
            prefs.getString('user_updated_at') ??
                DateTime.now().toIso8601String(),
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage() async {
    if (_user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', _user!.id);
    await prefs.setString('user_name', _user!.name);
    await prefs.setString('user_email', _user!.email);
    await prefs.setString('user_phone', _user!.phone);
    await prefs.setString('user_address', _user!.address);
    await prefs.setString(
        'user_created_at', _user!.createdAt.toIso8601String());
    await prefs.setString(
        'user_updated_at', _user!.updatedAt.toIso8601String());
    if (_token != null) {
      await prefs.setString('auth_token', _token!);
    }
  }

  Future<void> _clearUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_phone');
    await prefs.remove('user_address');
    await prefs.remove('user_created_at');
    await prefs.remove('user_updated_at');
    await prefs.remove('auth_token');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _fetchMe() async {
    if (_token == null || _token!.isEmpty) {
      return false;
    }
    final res = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      _user = User(
        id: data['id'].toString(),
        name: (data['full_name'] ?? '').toString(),
        email: (data['email'] ?? '').toString(),
        phone: (data['phone'] ?? '').toString(),
        address: (data['address'] ?? '').toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _saveUserToStorage();
      return true;
    } else {
      return false;
    }
  }
}
