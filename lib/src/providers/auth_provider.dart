import 'package:flutter/foundation.dart';

import '../data/models/smap_user.dart';
import '../data/remote/smap_api.dart';
import '../data/repositories/auth_repository.dart';
import '../security/secure_session_store.dart';
import '../services/connectivity_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated }

/// Fonte de verdade da autenticação para a UI.
///
/// Delega a lógica offline-first ao [AuthRepository] e expõe um estado simples
/// e reativo para as telas. Mantém compatibilidade com o restante do app
/// através dos getters [baseUrl], [token] e [config].
class AuthProvider with ChangeNotifier {
  AuthProvider({AuthRepository? repository, ConnectivityService? connectivity})
      : _repository = repository ?? AuthRepository(),
        _connectivity = connectivity ?? ConnectivityService();

  final AuthRepository _repository;
  final ConnectivityService _connectivity;

  AuthStatus _status = AuthStatus.unknown;
  SmapUser? _currentUser;
  SmapSession? _session;
  String? _errorMessage;
  bool _isLoading = false;
  bool _bootstrapped = false;

  AuthStatus get status => _status;
  SmapUser? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _isLoading;
  bool get isBootstrapped => _bootstrapped;
  String? get errorMessage => _errorMessage;

  /// Sessão validada offline (contra a base local) em vez do servidor.
  bool get isOfflineSession => _session?.offline ?? false;

  /// Estado de conectividade observável para a UI (indicador online/offline).
  ValueListenable<bool> get isOnline => _connectivity.isOnline;

  // Compatibilidade com providers/telas existentes.
  String get baseUrl => _repository.baseUrl;
  String? get token => _session?.token;
  Map<String, dynamic>? get config => _repository.config;

  /// Inicializa a camada local (pré-carga da base), conectividade e restaura
  /// uma sessão previamente salva. Idempotente.
  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    await _repository.bootstrap();
    await _connectivity.initialize();
    final restored = await _repository.restoreSession();
    if (restored != null) {
      _applyOutcome(restored);
    } else {
      _status = AuthStatus.unauthenticated;
    }
    _bootstrapped = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final outcome = await _repository.login(email, password);
      _applyOutcome(outcome);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    } catch (e) {
      debugPrint('AuthProvider.login erro inesperado: $e');
      _fail('Erro inesperado ao entrar. Tente novamente.');
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _session = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _applyOutcome(AuthOutcome outcome) {
    _currentUser = outcome.user;
    _session = outcome.session;
    _errorMessage = null;
    _status = AuthStatus.authenticated;
  }

  void _fail(String message) {
    _errorMessage = message;
    _isLoading = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivity.dispose();
    super.dispose();
  }
}
