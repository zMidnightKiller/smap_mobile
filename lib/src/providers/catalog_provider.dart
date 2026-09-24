import 'package:flutter/foundation.dart';

import '../data/local/catalog_local_store.dart';
import '../data/local/catalog_seed.dart';
import '../data/local/local_database.dart';
import '../models/produto_model.dart';

/// Estado do catálogo de produtos, alimentado pela base local (offline-first).
/// Faz o pré-carregamento (seed) na primeira execução e oferece busca por nome
/// ou código.
class CatalogProvider with ChangeNotifier {
  CatalogProvider({CatalogLocalStore? store, CatalogSeed seed = const CatalogSeed()})
      : _store = store,
        _seed = seed;

  CatalogLocalStore? _store;
  final CatalogSeed _seed;

  List<Produto> _produtos = [];
  bool _isLoading = false;
  bool _loadedOnce = false;
  String _query = '';

  bool get isLoading => _isLoading;
  bool get loadedOnce => _loadedOnce;
  String get query => _query;

  /// Produtos filtrados pela busca atual (nome ou código).
  List<Produto> get produtos {
    if (_query.trim().isEmpty) return List.unmodifiable(_produtos);
    final q = _query.toLowerCase();
    return _produtos
        .where((p) =>
            p.nome.toLowerCase().contains(q) ||
            p.codigoInterno.toLowerCase().contains(q))
        .toList();
  }

  int get totalProdutos => _produtos.length;
  int get totalAtivos => _produtos.where((p) => p.ativo).length;

  Future<CatalogLocalStore> _catalog() async {
    if (_store != null) return _store!;
    final db = await LocalDatabase.instance();
    return _store = CatalogLocalStore(db.db);
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final store = await _catalog();
      if (await store.produtosCount() == 0) {
        await store.upsertProdutos(_seed.produtos());
      }
      _produtos = await store.produtos();
      _produtos.sort((a, b) => a.nome.compareTo(b.nome));
    } catch (e) {
      debugPrint('CatalogProvider.load erro: $e');
    } finally {
      _isLoading = false;
      _loadedOnce = true;
      notifyListeners();
    }
  }
}
