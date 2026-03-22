class Produto {
  final String id;
  final String nome;
  final String codigoInterno;
  final double estoqueTotal;
  final double precoVenda;
  final int qtdVariacoes;
  final bool ativo;

  Produto({
    required this.id,
    required this.nome,
    required this.codigoInterno,
    required this.estoqueTotal,
    required this.precoVenda,
    required this.qtdVariacoes,
    required this.ativo,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id_produto'] ?? '',
      nome: json['nome'] ?? '',
      codigoInterno: json['codigo_interno'] ?? '',
      estoqueTotal: (json['estoque_total'] ?? 0).toDouble(),
      precoVenda: (json['preco_venda'] ?? 0.0).toDouble(),
      qtdVariacoes: json['qtd_variacoes'] ?? 0,
      ativo: json['ativo'] ?? true,
    );
  }
}
