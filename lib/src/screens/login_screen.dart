import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ops! Verifique seus dados e tente novamente.'),
          backgroundColor: SmapTheme.errorColor.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient animado
          Container(color: SmapTheme.backgroundColor),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SmapTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .move(begin: const Offset(0, 0), end: const Offset(30, 50), duration: 6.seconds),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      decoration: SmapTheme.glassDecoration(opacity: 0.08),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: SmapTheme.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.analytics_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'Entrar no SMAP',
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          const Text(
                            'Sua gestão avançada em um só lugar',
                            style: TextStyle(color: SmapTheme.textSecondaryColor),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined, size: 22),
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                          
                          const SizedBox(height: 20),
                          
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline, size: 22),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                          
                          const SizedBox(height: 12),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Recuperar acesso'),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return ElevatedButton(
                                onPressed: auth.isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SmapTheme.primaryColor,
                                  shadowColor: SmapTheme.primaryColor.withValues(alpha: 0.5),
                                  elevation: 10,
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Iniciar Sessão'),
                              );
                            },
                          ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Novo por aqui?',
                                style: TextStyle(color: SmapTheme.textSecondaryColor),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Criar conta',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
