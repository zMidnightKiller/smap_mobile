import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Área autenticada mínima exibida após o login. Serve como confirmação do
/// fluxo de autenticação (online/offline) enquanto as demais telas do SMAP são
/// reconstruídas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('SMAP'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SessionBadge(isOffline: auth.isOfflineSession),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: SmapTheme.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      user?.initials ?? '?',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo(a),',
                          style: TextStyle(color: SmapTheme.textSecondaryColor),
                        ),
                        Text(
                          user?.name ?? 'Usuário',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          user?.role ?? '',
                          style: TextStyle(color: SmapTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _InfoTile(
                icon: Icons.mail_outline_rounded,
                label: 'E-mail',
                value: user?.email ?? '—',
              ),
              _InfoTile(
                icon: auth.isOfflineSession
                    ? Icons.cloud_off_rounded
                    : Icons.cloud_done_rounded,
                label: 'Sessão',
                value: auth.isOfflineSession
                    ? 'Autenticado offline (base local)'
                    : 'Autenticado online (SMAP)',
              ),
              const Spacer(),
              Text(
                'Autenticação reconstruída com suporte offline-first e '
                'armazenamento seguro de sessão. As demais telas do SMAP serão '
                'espelhadas a seguir.',
                style: TextStyle(
                  color: SmapTheme.textSecondaryColor,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.isOffline});
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final color = isOffline ? SmapTheme.accentColor : SmapTheme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
              size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            isOffline ? 'Modo offline' : 'Conectado ao SMAP',
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: SmapTheme.primaryColor, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: SmapTheme.textSecondaryColor, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
