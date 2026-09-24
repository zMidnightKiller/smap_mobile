import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Aba Perfil: dados do usuário, status da sessão (online/offline) e logout.
/// Estilo fintech claro.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SessionBadge(isOffline: auth.isOfflineSession),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: SmapTheme.cardDecoration(borderRadius: 20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: SmapTheme.primaryColor.withValues(alpha: 0.12),
                      child: Text(
                        user?.initials ?? '?',
                        style: GoogleFonts.outfit(
                          color: SmapTheme.primaryColor,
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
                          Text('Bem-vindo(a),', style: TextStyle(color: SmapTheme.textSecondaryColor)),
                          Text(
                            user?.name ?? 'Usuário',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: SmapTheme.textColor,
                            ),
                          ),
                          Text(user?.role ?? '', style: TextStyle(color: SmapTheme.textSecondaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _InfoTile(
                icon: Icons.mail_outline_rounded,
                label: 'E-mail',
                value: user?.email ?? '—',
              ),
              _InfoTile(
                icon: auth.isOfflineSession ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                label: 'Sessão',
                value: auth.isOfflineSession
                    ? 'Autenticado offline (base local)'
                    : 'Autenticado online (SMAP)',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SmapTheme.errorColor,
                    minimumSize: const Size.fromHeight(52),
                    side: BorderSide(color: SmapTheme.errorColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  label: const Text('Sair da conta'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Autenticação offline-first com armazenamento seguro de sessão.',
                textAlign: TextAlign.center,
                style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12, height: 1.5),
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
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded, size: 16, color: color),
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
      decoration: SmapTheme.cardDecoration(borderRadius: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: SmapTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: SmapTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: SmapTheme.textColor, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
