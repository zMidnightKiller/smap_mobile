import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/smap_seed_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Tela de login reconstruída do zero com foco em UX, segurança e suporte
/// offline. Faz parte do espelhamento do SMAP web/win no mobile.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  static const _rememberEmailKey = 'smap.rememberedEmail';

  bool _obscurePassword = true;
  bool _rememberEmail = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_rememberEmailKey);
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() => _emailController.text = saved);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail';
    final emailRegex = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w\-.]+$');
    if (!emailRegex.hasMatch(email)) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Informe sua senha';
    if (password.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final email = _emailController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    if (_rememberEmail) {
      await prefs.setString(_rememberEmailKey, email);
    } else {
      await prefs.remove(_rememberEmailKey);
    }

    final success = await auth.login(email, _passwordController.text);
    if (!mounted) return;

    if (!success) {
      // Em caso de sucesso, o AuthGate reconstrói para o AppShell
      // automaticamente ao observar a mudança de estado do AuthProvider.
      final message = auth.errorMessage ?? 'Não foi possível entrar.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: SmapTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
    }
  }

  void _fillDemoCredentials(Map<String, String> credential) {
    // Nota: não chamar _formKey.reset() aqui — isso reverteria os campos para o
    // valor inicial (vazio) e apagaria o texto recém-preenchido.
    setState(() {
      _emailController.text = credential['email'] ?? '';
      _passwordController.text = credential['senha'] ?? '';
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AuroraBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildConnectivityBanner(),
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildForm(),
                      const SizedBox(height: 24),
                      _buildDemoHint(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityBanner() {
    final auth = context.watch<AuthProvider>();
    return ValueListenableBuilder<bool>(
      valueListenable: auth.isOnline,
      builder: (context, online, _) {
        if (online) return const SizedBox.shrink();
        return Semantics(
          liveRegion: true,
          label: 'Você está offline. O login usará a base local do SMAP.',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: SmapTheme.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SmapTheme.accentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_off_rounded, size: 18, color: SmapTheme.accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Modo offline — usando a base local do SMAP',
                    style: TextStyle(
                      color: SmapTheme.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 72,
          width: 72,
          decoration: SmapTheme.gradientDecoration(borderRadius: 22),
          child: const Icon(Icons.insights_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 20),
        Text(
          'SMAP',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: 6,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Acesse sua gestão em qualquer lugar',
          textAlign: TextAlign.center,
          style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    return Form(
      key: _formKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'E-mail',
              hintText: 'voce@empresa.com',
              prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
            ),
            validator: _validateEmail,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            enabled: !isLoading,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: isLoading
                      ? null
                      : () => setState(() => _rememberEmail = !_rememberEmail),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberEmail,
                            onChanged: isLoading
                                ? null
                                : (v) => setState(() => _rememberEmail = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Lembrar e-mail',
                            style: TextStyle(color: SmapTheme.textSecondaryColor)),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: isLoading ? null : _showRecoverInfo,
                child: const Text('Esqueci a senha'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.4),
                    )
                  : const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_rounded,
                  size: 16, color: SmapTheme.textSecondaryColor),
              const SizedBox(width: 8),
              Text(
                'Acesso de demonstração (offline)',
                style: TextStyle(
                  color: SmapTheme.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...SmapSeedData.demoCredentials.map(
            (cred) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _fillDemoCredentials(cred),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${cred['perfil']} · ${cred['email']}',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: SmapTheme.textSecondaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecoverInfo() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
              'Recuperação de senha é feita pelo administrador do SMAP.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }
}

/// Fundo decorativo suave e performático (sem animações pesadas) para dar
/// profundidade à tela mantendo a legibilidade.
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: SmapTheme.backgroundColor),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _blurCircle(260, SmapTheme.primaryColor.withValues(alpha: 0.22)),
          ),
          Positioned(
            bottom: -100,
            left: -90,
            child: _blurCircle(240, SmapTheme.secondaryColor.withValues(alpha: 0.16)),
          ),
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
