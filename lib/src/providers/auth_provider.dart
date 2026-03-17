import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _config;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  Map<String, dynamic>? get config => _config;

  final String baseUrl = 'http://localhost:8000/api'; // Mudar para IP real em prod

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        await fetchConfig();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchConfig() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/public/config'));
      if (response.statusCode == 200) {
        _config = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Config error: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
