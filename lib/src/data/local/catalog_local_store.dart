import 'package:sembast/sembast.dart';

import '../../models/produto_model.dart';
import '../models/venda.dart';

/// Persistência local do catálogo (produtos) e das vendas, base da operação
/// offline-first do PDV. Produtos e vendas ficam disponíveis mesmo sem conexão
/// e alimentam o Dashboard e os relatórios.
class CatalogLocalStore {
  CatalogLocalStore(this._db);

  final Database _db;
  final StoreRef<String, Map<String, dynamic>> _produtos =
      stringMapStoreFactory.store('produtos');
  final StoreRef<String, Map<String, dynamic>> _vendas =
      stringMapStoreFactory.store('vendas');

  // ---- Produtos ----
  Future<int> produtosCount() => _produtos.count(_db);

  Future<List<Produto>> produtos() async {
    final records = await _produtos.find(_db);
    return records.map((r) => _produtoFromMap(r.value)).toList();
  }

  Future<void> upsertProdutos(List<Produto> produtos) async {
    await _db.transaction((txn) async {
      for (final p in produtos) {
        await _produtos.record(p.id).put(txn, _produtoToMap(p));
      }
    });
  }

  // ---- Vendas ----
  Future<int> vendasCount() => _vendas.count(_db);

  Future<List<Venda>> vendas() async {
    final records = await _vendas.find(
      _db,
      finder: Finder(sortOrders: [SortOrder('data', false)]),
    );
    return records.map((r) => Venda.fromMap(r.value)).toList();
  }

  Future<void> upsertVenda(Venda venda) async {
    await _vendas.record(venda.id).put(_db, venda.toMap());
  }

  Future<void> upsertVendas(List<Venda> vendas) async {
    await _db.transaction((txn) async {
      for (final v in vendas) {
        await _vendas.record(v.id).put(txn, v.toMap());
      }
    });
  }

  Map<String, dynamic> _produtoToMap(Produto p) => {
        'id_produto': p.id,
        'nome': p.nome,
        'codigo_interno': p.codigoInterno,
        'estoque_total': p.estoqueTotal,
        'preco_venda': p.precoVenda,
        'qtd_variacoes': p.qtdVariacoes,
        'ativo': p.ativo,
      };

  Produto _produtoFromMap(Map<String, dynamic> map) => Produto.fromJson(map);
}
