import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local/local_database.dart';
import '../local/smap_seed_data.dart';
import '../local/user_local_store.dart';
import '../models/smap_user.dart';
import '../remote/http_smap_api.dart';
import '../remote/smap_api.dart';
import '../../security/password_hasher.dart';
import '../../security/secure_session_store.dart';

/// Resultado de uma autenticação bem-sucedida.
class AuthOutcome {
  const AuthOutcome({required this.user, required this.session});

  final SmapUser user;
  final SmapSession session;

  bool get isOffline => session.offline;
}

/// Orquestra a autenticação offline-first do SMAP Mobile.
///
/// Estratégia:
/// 1. Tenta autenticar no SMAP online (fonte da verdade).
/// 2. Em sucesso: guarda a sessão de forma segura e materializa o verificador
///    de senha localmente, habilitando logins offline futuros.
/// 3. Em falha de rede/servidor: valida contra a base local pré-carregada.
/// 4. Em credenciais inválidas confirmadas pelo servidor: não faz fallback.
class AuthRepository {
  AuthRepository({
    this.baseUrl = 'http://localhost:8000/api',
    SmapApi? api,
    UserLocalStore? userStore,
    SessionStore? sessionStore,
    PasswordHasher hasher = const PasswordHasher(),
    SmapSeedData? seed,
  })  : _api = api,
        _userStore = userStore,
        _sessionStore = sessionStore ?? SecureSessionStore(),
        _hasher = hasher,
        _seed = seed ?? const SmapSeedData();

  final String baseUrl;
  SmapApi? _api;
  UserLocalStore? _userStore;
  final SessionStore _sessionStore;
  final PasswordHasher _hasher;
  final SmapSeedData _seed;

  Map<String, dynamic> _config = SmapSeedData.defaultConfig;
  Map<String, dynamic> get config => _config;

  SmapApi get _remote => _api ??= HttpSmapApi(baseUrl: baseUrl);

  Future<UserLocalStore> _store() async {
    if (_userStore != null) return _userStore!;
    final db = await LocalDatabase.instance();
    return _userStore = UserLocalStore(db.db);
  }

  /// Prepara a camada local: abre o banco e pré-carrega a base do SMAP na
  /// primeira execução (simula a sincronização inicial com o SMAP online).
  Future<void> bootstrap() async {
    final store = await _store();
    if (await store.count() == 0) {
      await store.upsertAll(_seed.users());
      debugPrint('AuthRepository: base local pré-carregada com usuários do SMAP.');
    }
  }

  /// Restaura uma sessão previamente salva de forma segura, se existir.
  Future<AuthOutcome?> restoreSession() async {
    final session = await _sessionStore.read();
    if (session == null) return null;
    final store = await _store();
    final user = await store.findByEmail(session.userEmail);
    if (user == null) return null;
    return AuthOutcome(user: user, session: session);
  }

  Future<AuthOutcome> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Informe e-mail e senha.');
    }

    try {
      final result = await _remote.login(normalizedEmail, password);
      return await _persistOnlineLogin(result, password);
    } on AuthException catch (e) {
      if (!e.isNetworkError) rethrow;
      // Sem servidor: tenta autenticação offline contra a base local.
      return await _loginOffline(normalizedEmail, password);
    }
  }

  Future<AuthOutcome> _persistOnlineLogin(AuthResult result, String password) async {
    final store = await _store();
    final existing = await store.findByEmail(result.user.email);
    final user = result.user.copyWith(
      // Deriva/atualiza o verificador para permitir login offline no futuro.
      passwordVerifier: _hasher.derive(password),
      // Mantém dados locais úteis já conhecidos.
      avatarUrl: result.user.avatarUrl ?? existing?.avatarUrl,
    );
    await store.upsert(user);

    if (result.config != null) _config = result.config!;

    final session = SmapSession(
      userEmail: user.email,
      token: result.token,
      issuedAt: DateTime.now(),
      offline: false,
    );
    await _sessionStore.save(session);

    // Best-effort: sincroniza a base de usuários em background.
    unawaited(_syncUserBase(result.token));

    return AuthOutcome(user: user, session: session);
  }

  Future<AuthOutcome> _loginOffline(String email, String password) async {
    final store = await _store();
    final user = await store.findByEmail(email);
    if (user == null) {
      throw const AuthException(
        'Usuário não encontrado na base offline. Conecte-se ao SMAP ao menos uma vez.',
      );
    }
    final verifier = user.passwordVerifier;
    if (verifier == null || !_hasher.verify(password, verifier)) {
      throw const AuthException('Credenciais inválidas.');
    }

    final session = SmapSession(
      userEmail: user.email,
      token: 'offline-${DateTime.now().millisecondsSinceEpoch}',
      issuedAt: DateTime.now(),
      offline: true,
    );
    await _sessionStore.save(session);
    return AuthOutcome(user: user, session: session);
  }

  Future<void> _syncUserBase(String token) async {
    try {
      final users = await _remote.fetchUserBase(token);
      if (users.isNotEmpty) {
        final store = await _store();
        await store.upsertAll(users);
        debugPrint('AuthRepository: base local sincronizada (${users.length} usuários).');
      }
    } catch (e) {
      debugPrint('AuthRepository: sync da base falhou ($e).');
    }
  }

  Future<void> logout() async {
    await _sessionStore.clear();
  }
}
