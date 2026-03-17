import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background vibrante
          Container(color: SmapTheme.backgroundColor),
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SmapTheme.primaryColor.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 8.seconds),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, auth),
                  const SizedBox(height: 32),
                  _buildWelcomeCard(auth).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 40),
                  
                  Text(
                    'Visão Geral',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Vendas Hoje',
                          'R\$ 1.250',
                          Icons.insights_rounded,
                          SmapTheme.primaryColor,
                          '↑ 12%',
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Pendências',
                          '03',
                          Icons.assignment_late_outlined,
                          SmapTheme.secondaryColor,
                          'Alerta',
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Text(
                    'Acesso Rápido',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 20),
                  
                  _buildQuickAction(
                    'Nova Venda',
                    'Abertura de ticket rápido',
                    Icons.add_shopping_cart_rounded,
                    0,
                  ),
                  _buildQuickAction(
                    'Fluxo de Caixa',
                    'Verificar entradas e saídas',
                    Icons.account_balance_wallet_rounded,
                    1,
                  ),
                  _buildQuickAction(
                    'Inventário',
                    'Gestão de estoque em tempo real',
                    Icons.inventory_2_outlined,
                    2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              'Bem-vindo de volta',
              style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 14),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: IconButton(
            onPressed: () => auth.logout().then((_) {
              Navigator.pushReplacementNamed(context, '/login');
            }),
            icon: const Icon(Icons.logout_rounded, color: SmapTheme.secondaryColor),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildWelcomeCard(AuthProvider auth) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            SmapTheme.primaryColor.withValues(alpha: 0.8),
            SmapTheme.secondaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: SmapTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                const SizedBox(height: 20),
                Text(
                  'Empresa: ${auth.config?['nome'] ?? 'Loja SMAP'}',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Plano Premium Ativo • Tudo em dia',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: SmapTheme.glassDecoration(opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                trend,
                style: TextStyle(color: SmapTheme.accentColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, IconData icon, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: SmapTheme.glassDecoration(opacity: 0.03),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SmapTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: SmapTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: SmapTheme.textSecondaryColor.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (600 + index * 100).ms, duration: 600.ms).slideX(begin: 0.1);
  }
}
