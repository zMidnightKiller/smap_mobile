import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Deriva e verifica senhas usando PBKDF2-HMAC-SHA256.
///
/// Nunca armazenamos a senha em texto puro. Guardamos apenas um verificador
/// (`salt` + `hash` derivado), permitindo autenticar o usuário offline sem
/// jamais reter a credencial original.
class PasswordHasher {
  const PasswordHasher({this.iterations = 12000, this.keyLength = 32});

  /// Número de iterações do PBKDF2. Quanto maior, mais custoso é um ataque de
  /// força bruta. 12k é um equilíbrio razoável para rodar no cliente (inclusive
  /// web) sem travar a UI.
  final int iterations;

  /// Tamanho da chave derivada em bytes.
  final int keyLength;

  static final Random _random = Random.secure();

  /// Gera um verificador serializável no formato
  /// `pbkdf2$<iterations>$<saltBase64>$<hashBase64>`.
  String derive(String password) {
    final salt = _randomBytes(16);
    final hash = _pbkdf2(utf8.encode(password), salt);
    final saltB64 = base64.encode(salt);
    final hashB64 = base64.encode(hash);
    return 'pbkdf2\$$iterations\$$saltB64\$$hashB64';
  }

  /// Verifica uma senha contra um verificador previamente gerado por [derive].
  /// Usa comparação em tempo constante para evitar timing attacks.
  bool verify(String password, String encoded) {
    final parts = encoded.split('\$');
    if (parts.length != 4 || parts[0] != 'pbkdf2') return false;

    final storedIterations = int.tryParse(parts[1]);
    if (storedIterations == null) return false;

    final salt = base64.decode(parts[2]);
    final expected = base64.decode(parts[3]);
    final actual = _pbkdf2(
      utf8.encode(password),
      salt,
      iterations: storedIterations,
      keyLength: expected.length,
    );
    return _constantTimeEquals(expected, actual);
  }

  Uint8List _pbkdf2(
    List<int> password,
    List<int> salt, {
    int? iterations,
    int? keyLength,
  }) {
    final rounds = iterations ?? this.iterations;
    final length = keyLength ?? this.keyLength;
    final hmac = Hmac(sha256, password);
    final blockCount = (length / 32).ceil();
    final output = <int>[];

    for (var block = 1; block <= blockCount; block++) {
      output.addAll(_deriveBlock(hmac, salt, rounds, block));
    }
    return Uint8List.fromList(output.sublist(0, length));
  }

  List<int> _deriveBlock(Hmac hmac, List<int> salt, int rounds, int blockIndex) {
    final blockIndexBytes = Uint8List(4)
      ..[0] = (blockIndex >> 24) & 0xff
      ..[1] = (blockIndex >> 16) & 0xff
      ..[2] = (blockIndex >> 8) & 0xff
      ..[3] = blockIndex & 0xff;

    var u = hmac.convert(<int>[...salt, ...blockIndexBytes]).bytes;
    final result = List<int>.from(u);

    for (var i = 1; i < rounds; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return result;
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }
}
