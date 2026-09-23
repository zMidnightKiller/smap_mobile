import 'package:flutter_test/flutter_test.dart';
import 'package:smap_mobile/src/data/models/venda.dart';
import 'package:smap_mobile/src/data/repositories/dashboard_repository.dart';

void main() {
  final now = DateTime(2026, 9, 23, 15, 0);
  DateTime hoje(int h) => DateTime(2026, 9, 23, h, 0);
  DateTime diasAtras(int d, int h) =>
      DateTime(2026, 9, 23, h, 0).subtract(Duration(days: d));

  Venda venda(String id, DateTime data, double total, String forma,
          {List<VendaItem> itens = const []}) =>
      Venda(id: id, data: data, total: total, formaPagamento: forma, itens: itens);

  group('DashboardRepository.computeResumo', () {
    test('resumo vazio quando não há vendas', () {
      final r = DashboardRepository.computeResumo([], now: now);
      expect(r.faturamentoHoje, 0);
      expect(r.vendasHoje, 0);
      expect(r.ticketMedioHoje, 0);
      expect(r.serie7dias.length, 7);
      expect(r.porFormaPagamento, isEmpty);
    });

    test('agrega faturamento, contagem e ticket médio de hoje', () {
      final r = DashboardRepository.computeResumo([
        venda('a', hoje(9), 100, 'PIX'),
        venda('b', hoje(12), 300, 'CARTAO'),
        venda('c', diasAtras(1, 10), 999, 'DINHEIRO'), // ontem, não conta hoje
      ], now: now);

      expect(r.faturamentoHoje, 400);
      expect(r.vendasHoje, 2);
      expect(r.ticketMedioHoje, 200);
    });

    test('série de 7 dias tem 7 pontos e soma o faturamento do período', () {
      final r = DashboardRepository.computeResumo([
        venda('a', hoje(9), 100, 'PIX'),
        venda('b', diasAtras(2, 10), 50, 'PIX'),
        venda('c', diasAtras(6, 10), 25, 'PIX'),
        venda('d', diasAtras(10, 10), 500, 'PIX'), // fora da janela de 7 dias
      ], now: now);

      expect(r.serie7dias.length, 7);
      expect(r.faturamento7dias, 175);
      final totalSerie = r.serie7dias.fold<double>(0, (s, d) => s + d.total);
      expect(totalSerie, 175);
    });

    test('breakdown por forma de pagamento e top produtos', () {
      final r = DashboardRepository.computeResumo([
        venda('a', hoje(9), 100, 'PIX', itens: const [
          VendaItem(codigo: 'X', descricao: 'Produto X', quantidade: 2, valorUnitario: 50),
        ]),
        venda('b', hoje(10), 200, 'CARTAO', itens: const [
          VendaItem(codigo: 'Y', descricao: 'Produto Y', quantidade: 1, valorUnitario: 200),
        ]),
        venda('c', hoje(11), 100, 'PIX', itens: const [
          VendaItem(codigo: 'X', descricao: 'Produto X', quantidade: 2, valorUnitario: 50),
        ]),
      ], now: now);

      expect(r.porFormaPagamento['PIX'], 200);
      expect(r.porFormaPagamento['CARTAO'], 200);
      expect(r.topProdutos.first.nome, 'Produto X');
      expect(r.topProdutos.first.receita, 200);
      expect(r.topProdutos.first.quantidade, 4);
    });
  });
}
