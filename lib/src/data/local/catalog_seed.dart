import 'dart:math';

import '../../models/produto_model.dart';
import '../models/venda.dart';

/// Base de catálogo e vendas pré-carregada a partir do SMAP online. Garante que
/// o Dashboard, os Produtos e os Relatórios já nasçam populados e funcionais
/// **offline**. Em produção, estes dados viriam da sincronização inicial.
class CatalogSeed {
  const CatalogSeed();

  List<Produto> produtos() => const [
        Produto(id: 'p-001', nome: 'Camiseta Básica Premium', codigoInterno: 'CAM-001', estoqueTotal: 120, precoVenda: 79.90, qtdVariacoes: 6, ativo: true),
        Produto(id: 'p-002', nome: 'Calça Jeans Slim', codigoInterno: 'CAL-014', estoqueTotal: 64, precoVenda: 189.90, qtdVariacoes: 8, ativo: true),
        Produto(id: 'p-003', nome: 'Tênis Runner Pro', codigoInterno: 'TEN-207', estoqueTotal: 32, precoVenda: 349.90, qtdVariacoes: 10, ativo: true),
        Produto(id: 'p-004', nome: 'Boné Aba Curva', codigoInterno: 'BON-045', estoqueTotal: 210, precoVenda: 59.90, qtdVariacoes: 3, ativo: true),
        Produto(id: 'p-005', nome: 'Jaqueta Corta-Vento', codigoInterno: 'JAQ-088', estoqueTotal: 18, precoVenda: 259.90, qtdVariacoes: 5, ativo: true),
        Produto(id: 'p-006', nome: 'Meia Esportiva (kit 3)', codigoInterno: 'MEI-330', estoqueTotal: 400, precoVenda: 39.90, qtdVariacoes: 2, ativo: true),
        Produto(id: 'p-007', nome: 'Mochila Urbana 20L', codigoInterno: 'MOC-112', estoqueTotal: 27, precoVenda: 219.90, qtdVariacoes: 4, ativo: true),
        Produto(id: 'p-008', nome: 'Relógio Digital Sport', codigoInterno: 'REL-501', estoqueTotal: 12, precoVenda: 429.90, qtdVariacoes: 3, ativo: false),
      ];

  /// Gera um histórico determinístico de vendas nos últimos 14 dias, incluindo
  /// algumas vendas de hoje, para alimentar o Dashboard e os relatórios.
  List<Venda> vendas() {
    final rng = Random(42);
    final formas = ['DINHEIRO', 'CARTAO', 'PIX', 'PRAZO'];
    final produtos = this.produtos().where((p) => p.ativo).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final vendas = <Venda>[];

    for (var dia = 13; dia >= 0; dia--) {
      final data = today.subtract(Duration(days: dia));
      // Mais vendas em dias recentes; hoje tem um volume garantido.
      final qtdVendas = dia == 0 ? 5 : 2 + rng.nextInt(5);
      for (var i = 0; i < qtdVendas; i++) {
        final produto = produtos[rng.nextInt(produtos.length)];
        final quantidade = (1 + rng.nextInt(3)).toDouble();
        final hora = 9 + rng.nextInt(11);
        final minuto = rng.nextInt(60);
        final total = produto.precoVenda * quantidade;
        vendas.add(
          Venda(
            id: 'v-${data.millisecondsSinceEpoch}-$i',
            data: DateTime(data.year, data.month, data.day, hora, minuto),
            total: total,
            formaPagamento: formas[rng.nextInt(formas.length)],
            itens: [
              VendaItem(
                codigo: produto.codigoInterno,
                descricao: produto.nome,
                quantidade: quantidade,
                valorUnitario: produto.precoVenda,
              ),
            ],
          ),
        );
      }
    }
    return vendas;
  }
}
