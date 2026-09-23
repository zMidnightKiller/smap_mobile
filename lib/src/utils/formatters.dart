/// Utilitários de formatação no padrão brasileiro, sem depender de carregamento
/// de dados de locale (evita inicialização assíncrona do intl no boot).
library;

/// Formata um valor monetário como `R$ 1.234,56`.
String formatMoeda(num valor) {
  final negativo = valor < 0;
  final fixed = valor.abs().toStringAsFixed(2);
  final partes = fixed.split('.');
  final inteiro = _comSeparadorMilhar(partes[0]);
  final decimal = partes[1];
  final prefixo = negativo ? '-R\$ ' : 'R\$ ';
  return '$prefixo$inteiro,$decimal';
}

/// Formata um número inteiro/decimal com separador de milhar (`1.234`).
String formatNumero(num valor, {int casas = 0}) {
  final fixed = valor.toStringAsFixed(casas);
  final partes = fixed.split('.');
  final inteiro = _comSeparadorMilhar(partes[0]);
  if (partes.length == 1) return inteiro;
  return '$inteiro,${partes[1]}';
}

String _comSeparadorMilhar(String inteiro) {
  final buffer = StringBuffer();
  final chars = inteiro.split('');
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && (chars.length - i) % 3 == 0) buffer.write('.');
    buffer.write(chars[i]);
  }
  return buffer.toString();
}

const _diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

/// Rótulo curto do dia da semana (`Seg`, `Ter`, ...).
String diaSemanaCurto(DateTime data) => _diasSemana[data.weekday - 1];
