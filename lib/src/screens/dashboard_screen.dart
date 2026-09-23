import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/repositories/dashboard_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Dashboard (Início) do SMAP: faturamento, vendas, ticket médio, série dos
/// últimos 7 dias, formas de pagamento e top produtos. Todos os números são
/// calculados a partir da base local — funciona offline.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onNovaVenda});

  final VoidCallback? onNovaVenda;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboard = context.read<DashboardProvider>();
      if (!dashboard.loadedOnce) dashboard.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final resumo = dashboard.resumo;

    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: SmapTheme.primaryColor,
          onRefresh: () => dashboard.load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _Header(auth: auth),
              const SizedBox(height: 24),
              _BalanceCard(
                faturamento: resumo.faturamentoHoje,
                isLoading: dashboard.isLoading && !dashboard.loadedOnce,
                onVender: widget.onNovaVenda,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.receipt_long_rounded,
                      label: 'Vendas hoje',
                      value: formatNumero(resumo.vendasHoje),
                      color: SmapTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.trending_up_rounded,
                      label: 'Ticket médio',
                      value: formatMoeda(resumo.ticketMedioHoje),
                      color: SmapTheme.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(
                title: 'Faturamento (7 dias)',
                trailing: formatMoeda(resumo.faturamento7dias),
              ),
              const SizedBox(height: 12),
              _WeeklyChart(serie: resumo.serie7dias),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Por forma de pagamento'),
              const SizedBox(height: 12),
              _PaymentBreakdown(porFormaPagamento: resumo.porFormaPagamento),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Produtos mais vendidos'),
              const SizedBox(height: 12),
              _TopProdutos(itens: resumo.topProdutos),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: SmapTheme.primaryColor.withValues(alpha: 0.2),
          child: Text(
            user?.initials ?? '?',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá,', style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 13)),
              Text(
                user?.name ?? 'Usuário',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        _ConnectivityChip(auth: auth),
      ],
    );
  }
}

class _ConnectivityChip extends StatelessWidget {
  const _ConnectivityChip({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: auth.isOnline,
      builder: (context, online, _) {
        final offline = !online || auth.isOfflineSession;
        final color = offline ? SmapTheme.accentColor : SmapTheme.primaryColor;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(offline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                  size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                offline ? 'Offline' : 'Online',
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.faturamento, required this.isLoading, this.onVender});
  final double faturamento;
  final bool isLoading;
  final VoidCallback? onVender;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: SmapTheme.gradientDecoration(borderRadius: 26),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FATURAMENTO DE HOJE',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          isLoading
              ? const SizedBox(
                  height: 38,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                    ),
                  ),
                )
              : Text(
                  formatMoeda(faturamento),
                  style: GoogleFonts.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAction(icon: Icons.add_shopping_cart_rounded, label: 'Vender', onTap: onVender),
              _QuickAction(icon: Icons.payments_rounded, label: 'Receber'),
              _QuickAction(icon: Icons.sync_rounded, label: 'Sincronizar'),
              _QuickAction(icon: Icons.more_horiz_rounded, label: 'Mais'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ??
          () => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('"$label" em breve'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        if (trailing != null)
          Text(trailing!, style: TextStyle(color: SmapTheme.primaryColor, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.serie});
  final List<DiaFaturamento> serie;

  @override
  Widget build(BuildContext context) {
    final maxTotal = serie.fold<double>(0, (m, d) => d.total > m ? d.total : m);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: SizedBox(
        height: 150,
        child: serie.isEmpty
            ? Center(
                child: Text('Sem dados', style: TextStyle(color: SmapTheme.textSecondaryColor)),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: serie.map((d) {
                  final ratio = maxTotal == 0 ? 0.0 : d.total / maxTotal;
                  final isToday = _isSameDay(d.dia, DateTime.now());
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          d.total >= 1000
                              ? '${(d.total / 1000).toStringAsFixed(1)}k'
                              : d.total.toStringAsFixed(0),
                          style: TextStyle(
                            color: SmapTheme.textSecondaryColor,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 90 * ratio + 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isToday
                                  ? [SmapTheme.primaryColor, SmapTheme.secondaryColor]
                                  : [
                                      SmapTheme.primaryColor.withValues(alpha: 0.5),
                                      SmapTheme.primaryColor.withValues(alpha: 0.25),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          diaSemanaCurto(d.dia),
                          style: TextStyle(
                            color: isToday ? Colors.white : SmapTheme.textSecondaryColor,
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PaymentBreakdown extends StatelessWidget {
  const _PaymentBreakdown({required this.porFormaPagamento});
  final Map<String, double> porFormaPagamento;

  static const _labels = {
    'DINHEIRO': 'Dinheiro',
    'CARTAO': 'Cartão',
    'PIX': 'PIX',
    'PRAZO': 'A prazo',
  };
  static const _icons = {
    'DINHEIRO': Icons.payments_rounded,
    'CARTAO': Icons.credit_card_rounded,
    'PIX': Icons.qr_code_rounded,
    'PRAZO': Icons.calendar_today_rounded,
  };
  static const _colors = {
    'DINHEIRO': SmapTheme.accentColor,
    'CARTAO': SmapTheme.primaryColor,
    'PIX': Color(0xFF8B5CF6),
    'PRAZO': SmapTheme.secondaryColor,
  };

  @override
  Widget build(BuildContext context) {
    if (porFormaPagamento.isEmpty) {
      return _emptyCard('Sem vendas no período');
    }
    final total = porFormaPagamento.values.fold<double>(0, (s, v) => s + v);
    final entries = porFormaPagamento.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: entries.map((e) {
          final ratio = total == 0 ? 0.0 : e.value / total;
          final color = _colors[e.key] ?? SmapTheme.primaryColor;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(_icons[e.key] ?? Icons.circle, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_labels[e.key] ?? e.key,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    Text(formatMoeda(e.value),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('${(ratio * 100).round()}%',
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyCard(String message) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: Text(message, style: TextStyle(color: SmapTheme.textSecondaryColor))),
      );
}

class _TopProdutos extends StatelessWidget {
  const _TopProdutos({required this.itens});
  final List<TopProduto> itens;

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(child: Text('Sem vendas no período', style: TextStyle(color: SmapTheme.textSecondaryColor))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: List.generate(itens.length, (i) {
          final p = itens[i];
          return ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: SmapTheme.primaryColor.withValues(alpha: 0.15),
              child: Text('${i + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            title: Text(p.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('${formatNumero(p.quantidade)} un.',
                style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12)),
            trailing: Text(formatMoeda(p.receita),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          );
        }),
      ),
    );
  }
}
