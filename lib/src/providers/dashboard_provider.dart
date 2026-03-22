import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic>? _resumo;
  bool _isLoading = false;

  Map<String, dynamic>? get resumo => _resumo;
  bool get isLoading => _isLoading;

  Future<void> fetchResumo(String token, String baseUrl) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/resumo'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _resumo = jsonDecode(response.body);
      } else {
        debugPrint('Dashboard error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Dashboard exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
