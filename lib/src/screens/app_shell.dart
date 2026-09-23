import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'coming_soon_screen.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';

/// Estrutura de navegação principal do SMAP (barra inferior), espelhando o app
/// web/win. Cada aba é reconstruída como funcionalidade offline-first ao longo
/// do roadmap; por enquanto, Início (Dashboard) e Perfil estão prontos.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  late final List<Widget> _tabs = [
    DashboardScreen(onNovaVenda: () => _goTo(2)),
    const ComingSoonScreen(
      title: 'Produtos',
      icon: Icons.inventory_2_rounded,
      description:
          'Catálogo com busca, estoque e variações — carregado da base local do SMAP.',
      roadmapStep: 'Próximo no roadmap (5)',
    ),
    const ComingSoonScreen(
      title: 'Nova Venda (PDV)',
      icon: Icons.point_of_sale_rounded,
      description:
          'Ponto de venda offline: carrinho, quantidades e formas de pagamento.',
      roadmapStep: 'Roadmap (6–8)',
    ),
    const ComingSoonScreen(
      title: 'Relatórios',
      icon: Icons.bar_chart_rounded,
      description:
          'Entradas e saídas, gráficos e períodos — a partir das vendas locais.',
      roadmapStep: 'Roadmap (10)',
    ),
    const HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: _SmapBottomBar(index: _index, onTap: _goTo),
    );
  }
}

class _SmapBottomBar extends StatelessWidget {
  const _SmapBottomBar({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SmapTheme.surfaceColor,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(icon: Icons.dashboard_rounded, label: 'Início', selected: index == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.inventory_2_rounded, label: 'Produtos', selected: index == 1, onTap: () => onTap(1)),
              _CenterButton(onTap: () => onTap(2), selected: index == 2),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Relatórios', selected: index == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_rounded, label: 'Perfil', selected: index == 4, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SmapTheme.primaryColor : SmapTheme.textSecondaryColor;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  const _CenterButton({required this.onTap, required this.selected});
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SmapTheme.primaryColor, Color(0xFFA855F7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SmapTheme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
