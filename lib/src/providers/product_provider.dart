import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/produto_model.dart';
import 'auth_provider.dart';

class ProductProvider with ChangeNotifier {
  List<Produto> _produtos = [];
  bool _isLoading = false;
  String? _error;

  List<Produto> get produtos => _produtos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProdutos(AuthProvider auth) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${auth.baseUrl}/produtos?page=1&size=100'),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data['items'] ?? [];
        _produtos = items.map((item) => Produto.fromJson(item)).toList();
      } else {
        _error = 'Erro ao carregar produtos: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Erro de conexão: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
