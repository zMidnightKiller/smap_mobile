import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'app_shell.dart';
import 'login_screen.dart';

/// Porta de entrada do app: inicializa a camada offline (pré-carga da base),
/// restaura a sessão segura e encaminha para Login ou Home.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isBootstrapped) {
      return const _SplashView();
    }
    return auth.isAuthenticated ? const AppShell() : const LoginScreen();
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: SmapTheme.gradientDecoration(borderRadius: 22),
              child: const Icon(Icons.insights_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'SMAP',
              style: GoogleFonts.outfit(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
                color: SmapTheme.textColor,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          ],
        ),
      ),
    );
  }
}
