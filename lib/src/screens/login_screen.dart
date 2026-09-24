import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/smap_seed_data.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Tela de login estilo fintech (clara): reconstruída do zero com foco em UX,
/// segurança e suporte offline. Faz parte do espelhamento do SMAP web/win.
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
          ),
        );
    }
  }

  void _fillDemoCredentials(Map<String, String> credential) {
    setState(() {
      _emailController.text = credential['email'] ?? '';
      _passwordController.text = credential['senha'] ?? '';
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      body: Stack(
        children: [
          const _BrandBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildConnectivityBanner(),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildFormCard(),
                      const SizedBox(height: 16),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: SmapTheme.accentColor.withValues(alpha: 0.10),
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
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 68,
          width: 68,
          decoration: SmapTheme.gradientDecoration(borderRadius: 20),
          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 18),
        Text(
          'SMAP',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: SmapTheme.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sua gestão na palma da mão',
          textAlign: TextAlign.center,
          style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: SmapTheme.cardDecoration(borderRadius: 24),
      child: Form(
        key: _formKey,
        autovalidateMode:
            _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entrar',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: SmapTheme.textColor,
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              style: const TextStyle(color: SmapTheme.textColor),
              decoration: const InputDecoration(
                labelText: 'E-mail',
                hintText: 'voce@empresa.com',
                prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
              ),
              validator: _validateEmail,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !isLoading,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              style: const TextStyle(color: SmapTheme.textColor),
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
            const SizedBox(height: 6),
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
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                      )
                    : const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SmapTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SmapTheme.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_rounded, size: 16, color: SmapTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Acesso de demonstração (offline)',
                style: TextStyle(
                  color: SmapTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...SmapSeedData.demoCredentials.map(
            (cred) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _fillDemoCredentials(cred),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${cred['perfil']} · ${cred['email']}',
                          style: const TextStyle(color: SmapTheme.textColor, fontSize: 13),
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
        const SnackBar(
          content: Text('Recuperação de senha é feita pelo administrador do SMAP.'),
        ),
      );
  }
}

/// Fundo claro com um leve halo da cor de marca no topo, dando profundidade sem
/// comprometer a legibilidade (padrão fintech).
class _BrandBackdrop extends StatelessWidget {
  const _BrandBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: SmapTheme.backgroundColor),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -60,
            child: _blurCircle(260, SmapTheme.primaryColor.withValues(alpha: 0.12)),
          ),
          Positioned(
            top: 40,
            left: -90,
            child: _blurCircle(220, SmapTheme.accentColor.withValues(alpha: 0.10)),
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
