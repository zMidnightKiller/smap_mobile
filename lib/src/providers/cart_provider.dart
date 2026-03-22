import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/produto_model.dart';

class CartItem {
  final Produto produto;
  int quantidade;

  CartItem({required this.produto, this.quantidade = 1});

  double get total => produto.precoVenda * quantidade;
  String get nome => produto.nome;
  double get precoVenda => produto.precoVenda;
  String get codigoInterno => produto.codigoInterno;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.total;
    });
    return total;
  }

  void addItem(Produto produto) {
    if (_items.containsKey(produto.id)) {
      _items.update(
        produto.id,
        (existingItem) => CartItem(
          produto: existingItem.produto,
          quantidade: existingItem.quantidade + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        produto.id,
        () => CartItem(produto: produto),
      );
    }
    notifyListeners();
  }

  void removeItem(String produtoId) {
    _items.remove(produtoId);
    notifyListeners();
  }

  void removeSingleItem(String produtoId) {
    if (!_items.containsKey(produtoId)) return;

    if (_items[produtoId]!.quantidade > 1) {
      _items.update(
        produtoId,
        (existingItem) => CartItem(
          produto: existingItem.produto,
          quantidade: existingItem.quantidade - 1,
        ),
      );
    } else {
      _items.remove(produtoId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> checkout(String token, String baseUrl, {String formaPagamento = 'DINHEIRO', String? idCliente}) async {
    if (_items.isEmpty) return null;

    final subtotal = totalAmount;
    const desconto = 0.0;
    final total = subtotal - desconto;

    final payload = {
      'subtotal': subtotal,
      'desconto': desconto,
      'total': total,
      'forma_pagamento': formaPagamento,
      'id_cliente_fk': idCliente,
      'itens': _items.values.map((item) => {
        'codigo': item.codigoInterno,
        'descricao': item.nome,
        'quantidade': item.quantidade.toDouble(),
        'valor_unitario': item.precoVenda,
        'subtotal': item.total,
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vendas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        clear();
        return data;
      } else {
        debugPrint('Checkout error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Checkout exception: $e');
      return null;
    }
  }
}
