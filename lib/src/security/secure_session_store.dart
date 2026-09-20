import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Sessão autenticada persistida de forma segura.
class SmapSession {
  const SmapSession({
    required this.userEmail,
    required this.token,
    required this.issuedAt,
    this.offline = false,
  });

  final String userEmail;
  final String token;
  final DateTime issuedAt;

  /// Indica se a sessão foi estabelecida via autenticação offline (validada
  /// contra a base local) em vez do servidor SMAP.
  final bool offline;

  Map<String, dynamic> toMap() => {
        'userEmail': userEmail,
        'token': token,
        'issuedAt': issuedAt.toIso8601String(),
        'offline': offline,
      };

  factory SmapSession.fromMap(Map<String, dynamic> map) => SmapSession(
        userEmail: map['userEmail'] as String,
        token: map['token'] as String,
        issuedAt: DateTime.parse(map['issuedAt'] as String),
        offline: (map['offline'] ?? false) as bool,
      );
}

/// Contrato de persistência de sessão, permitindo trocar a implementação
/// (segura em produção, em memória em testes).
abstract class SessionStore {
  Future<void> save(SmapSession session);
  Future<SmapSession?> read();
  Future<void> clear();
}

/// Armazena a sessão (token + metadados) usando armazenamento seguro do SO
/// (Keychain/Keystore em nativo, storage criptografado no web). Substitui o
/// antigo uso inseguro de SharedPreferences em texto puro (OWASP Mobile M2/M9).
class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;
  static const _sessionKey = 'smap.session';

  @override
  Future<void> save(SmapSession session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toMap()),
    );
  }

  @override
  Future<SmapSession?> read() async {
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) return null;
      return SmapSession.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Sessão corrompida/incompatível: descarta silenciosamente.
      await clear();
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _sessionKey);
  }
}
