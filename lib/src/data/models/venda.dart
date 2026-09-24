/// Item de uma venda (linha do comprovante).
class VendaItem {
  const VendaItem({
    required this.codigo,
    required this.descricao,
    required this.quantidade,
    required this.valorUnitario,
  });

  final String codigo;
  final String descricao;
  final double quantidade;
  final double valorUnitario;

  double get subtotal => quantidade * valorUnitario;

  Map<String, dynamic> toMap() => {
        'codigo': codigo,
        'descricao': descricao,
        'quantidade': quantidade,
        'valorUnitario': valorUnitario,
      };

  factory VendaItem.fromMap(Map<String, dynamic> map) => VendaItem(
        codigo: (map['codigo'] ?? '') as String,
        descricao: (map['descricao'] ?? '') as String,
        quantidade: (map['quantidade'] ?? 0).toDouble(),
        valorUnitario: (map['valorUnitario'] ?? 0).toDouble(),
      );
}

/// Uma venda do SMAP, espelhada localmente para métricas e histórico offline.
class Venda {
  const Venda({
    required this.id,
    required this.data,
    required this.total,
    required this.formaPagamento,
    this.desconto = 0,
    this.clienteNome,
    this.itens = const [],
    this.sincronizada = true,
  });

  final String id;
  final DateTime data;
  final double total;
  final String formaPagamento;
  final double desconto;
  final String? clienteNome;
  final List<VendaItem> itens;

  /// Falso quando a venda foi criada offline e ainda não subiu para o SMAP.
  final bool sincronizada;

  Map<String, dynamic> toMap() => {
        'id': id,
        'data': data.toIso8601String(),
        'total': total,
        'formaPagamento': formaPagamento,
        'desconto': desconto,
        'clienteNome': clienteNome,
        'itens': itens.map((e) => e.toMap()).toList(),
        'sincronizada': sincronizada,
      };

  factory Venda.fromMap(Map<String, dynamic> map) => Venda(
        id: map['id'] as String,
        data: DateTime.parse(map['data'] as String),
        total: (map['total'] ?? 0).toDouble(),
        formaPagamento: (map['formaPagamento'] ?? 'DINHEIRO') as String,
        desconto: (map['desconto'] ?? 0).toDouble(),
        clienteNome: map['clienteNome'] as String?,
        itens: ((map['itens'] ?? []) as List)
            .map((e) => VendaItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        sincronizada: (map['sincronizada'] ?? true) as bool,
      );
}
