import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/smap_user.dart';
import 'smap_api.dart';

/// Implementação real do [SmapApi] que conversa com o backend do SMAP online.
///
/// Segurança: usa timeouts curtos, não registra credenciais em log e trata
/// falhas de rede de forma distinta de credenciais inválidas para permitir o
/// fallback offline apenas quando faz sentido.
class HttpSmapApi implements SmapApi {
  HttpSmapApi({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 8);

  @override
  Future<AuthResult> login(String email, String password) async {
    late http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const AuthException('Servidor SMAP indisponível.', isNetworkError: true);
    } catch (_) {
      throw const AuthException('Sem conexão com o SMAP.', isNetworkError: true);
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = (data['access_token'] ?? data['token']).toString();
      final user = await _fetchProfile(token, fallbackEmail: email);
      final config = await fetchConfig();
      return AuthResult(token: token, user: user, config: config);
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const AuthException('Credenciais inválidas.');
    }
    throw AuthException('Falha ao autenticar (${response.statusCode}).');
  }

  Future<SmapUser> _fetchProfile(String token, {required String fallbackEmail}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        return SmapUser.fromApi(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // Perfil é complementar; se falhar, seguimos com um usuário mínimo.
    }
    return SmapUser(
      id: fallbackEmail,
      name: fallbackEmail.split('@').first,
      email: fallbackEmail,
      role: 'user',
      lastSyncedAt: DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>?> fetchConfig() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/public/config'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('HttpSmapApi.fetchConfig falhou: $e');
    }
    return null;
  }

  @override
  Future<List<SmapUser>> fetchUserBase(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/usuarios?size=500'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data is List ? data : (data['items'] ?? []);
        return items
            .map((e) => SmapUser.fromApi(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('HttpSmapApi.fetchUserBase falhou: $e');
    }
    return const [];
  }
}
