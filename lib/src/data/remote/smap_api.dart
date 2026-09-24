import '../models/smap_user.dart';

/// Resultado de uma autenticação online bem-sucedida no SMAP.
class AuthResult {
  const AuthResult({
    required this.token,
    required this.user,
    this.config,
  });

  final String token;
  final SmapUser user;
  final Map<String, dynamic>? config;
}

/// Exceção de autenticação com mensagem amigável ao usuário.
class AuthException implements Exception {
  const AuthException(this.message, {this.isNetworkError = false});

  final String message;

  /// Quando verdadeiro, o erro decorre de indisponibilidade de rede/servidor,
  /// sinalizando ao repositório que o fallback offline pode ser tentado.
  final bool isNetworkError;

  @override
  String toString() => message;
}

/// Contrato com o backend do SMAP. A implementação real fala HTTP com o SMAP
/// online; o mock permite operar e demonstrar o app sem o backend disponível.
abstract class SmapApi {
  /// Autentica o usuário e retorna token + dados de perfil.
  Future<AuthResult> login(String email, String password);

  /// Busca a configuração pública (tema/identidade) do SMAP.
  Future<Map<String, dynamic>?> fetchConfig();

  /// Baixa a base de usuários do SMAP online para pré-carregar/sincronizar
  /// localmente (operação offline-first).
  Future<List<SmapUser>> fetchUserBase(String token);
}
