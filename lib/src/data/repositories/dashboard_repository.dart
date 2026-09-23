import '../../models/produto_model.dart';
import '../local/catalog_local_store.dart';
import '../local/catalog_seed.dart';
import '../local/local_database.dart';
import '../models/venda.dart';

/// Faturamento de um dia (para a série dos últimos dias).
class DiaFaturamento {
  const DiaFaturamento({required this.dia, required this.total});
  final DateTime dia;
  final double total;
}

/// Produto mais vendido no período (por receita).
class TopProduto {
  const TopProduto({required this.nome, required this.receita, required this.quantidade});
  final String nome;
  final double receita;
  final double quantidade;
}

/// Resumo consolidado exibido no Dashboard, computado a partir das vendas
/// locais — funciona 100% offline.
class DashboardResumo {
  const DashboardResumo({
    required this.faturamentoHoje,
    required this.vendasHoje,
    required this.ticketMedioHoje,
    required this.faturamento7dias,
    required this.serie7dias,
    required this.porFormaPagamento,
    required this.topProdutos,
  });

  final double faturamentoHoje;
  final int vendasHoje;
  final double ticketMedioHoje;
  final double faturamento7dias;
  final List<DiaFaturamento> serie7dias;
  final Map<String, double> porFormaPagamento;
  final List<TopProduto> topProdutos;

  static const empty = DashboardResumo(
    faturamentoHoje: 0,
    vendasHoje: 0,
    ticketMedioHoje: 0,
    faturamento7dias: 0,
    serie7dias: [],
    porFormaPagamento: {},
    topProdutos: [],
  );
}

/// Fornece dados do Dashboard a partir da base local (offline-first). Faz o
/// pré-carregamento (seed) do catálogo e das vendas na primeira execução.
class DashboardRepository {
  DashboardRepository({CatalogLocalStore? store, CatalogSeed seed = const CatalogSeed()})
      : _store = store,
        _seed = seed;

  CatalogLocalStore? _store;
  final CatalogSeed _seed;

  Future<CatalogLocalStore> _catalog() async {
    if (_store != null) return _store!;
    final db = await LocalDatabase.instance();
    return _store = CatalogLocalStore(db.db);
  }

  /// Pré-carrega catálogo e vendas caso a base esteja vazia.
  Future<void> bootstrap() async {
    final store = await _catalog();
    if (await store.produtosCount() == 0) {
      await store.upsertProdutos(_seed.produtos());
    }
    if (await store.vendasCount() == 0) {
      await store.upsertVendas(_seed.vendas());
    }
  }

  Future<List<Produto>> produtos() async => (await _catalog()).produtos();

  Future<DashboardResumo> resumo() async {
    final store = await _catalog();
    final vendas = await store.vendas();
    return computeResumo(vendas);
  }

  /// Lógica pura de agregação — isolada para ser testável sem banco.
  static DashboardResumo computeResumo(List<Venda> vendas, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final hoje = DateTime(reference.year, reference.month, reference.day);
    final inicio7 = hoje.subtract(const Duration(days: 6));

    final vendasHoje = vendas.where((v) => !v.data.isBefore(hoje)).toList();
    final faturamentoHoje = vendasHoje.fold<double>(0, (s, v) => s + v.total);
    final ticketMedio = vendasHoje.isEmpty ? 0.0 : faturamentoHoje / vendasHoje.length;

    final vendas7 = vendas.where((v) {
      final dia = DateTime(v.data.year, v.data.month, v.data.day);
      return !dia.isBefore(inicio7) && !dia.isAfter(hoje);
    }).toList();
    final faturamento7 = vendas7.fold<double>(0, (s, v) => s + v.total);

    // Série dos últimos 7 dias (inclui dias sem venda com total 0).
    final Map<String, double> porDia = {};
    for (var i = 0; i < 7; i++) {
      final dia = inicio7.add(Duration(days: i));
      porDia[_dayKey(dia)] = 0;
    }
    for (final v in vendas7) {
      final key = _dayKey(v.data);
      porDia[key] = (porDia[key] ?? 0) + v.total;
    }
    final serie = List<DiaFaturamento>.generate(7, (i) {
      final dia = inicio7.add(Duration(days: i));
      return DiaFaturamento(dia: dia, total: porDia[_dayKey(dia)] ?? 0);
    });

    // Breakdown por forma de pagamento (últimos 7 dias).
    final Map<String, double> porPagamento = {};
    for (final v in vendas7) {
      porPagamento[v.formaPagamento] = (porPagamento[v.formaPagamento] ?? 0) + v.total;
    }

    // Top produtos por receita (últimos 7 dias).
    final Map<String, TopProduto> topMap = {};
    for (final v in vendas7) {
      for (final item in v.itens) {
        final atual = topMap[item.descricao];
        topMap[item.descricao] = TopProduto(
          nome: item.descricao,
          receita: (atual?.receita ?? 0) + item.subtotal,
          quantidade: (atual?.quantidade ?? 0) + item.quantidade,
        );
      }
    }
    final top = topMap.values.toList()
      ..sort((a, b) => b.receita.compareTo(a.receita));

    return DashboardResumo(
      faturamentoHoje: faturamentoHoje,
      vendasHoje: vendasHoje.length,
      ticketMedioHoje: ticketMedio,
      faturamento7dias: faturamento7,
      serie7dias: serie,
      porFormaPagamento: porPagamento,
      topProdutos: top.take(4).toList(),
    );
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
