import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:smap_mobile/src/data/local/smap_seed_data.dart';
import 'package:smap_mobile/src/data/local/user_local_store.dart';
import 'package:smap_mobile/src/data/models/smap_user.dart';
import 'package:smap_mobile/src/data/remote/smap_api.dart';
import 'package:smap_mobile/src/data/repositories/auth_repository.dart';
import 'package:smap_mobile/src/security/password_hasher.dart';
import 'package:smap_mobile/src/security/secure_session_store.dart';

/// Sessão em memória para isolar os testes do armazenamento seguro do SO.
class InMemorySessionStore implements SessionStore {
  SmapSession? _session;

  @override
  Future<void> clear() async => _session = null;

  @override
  Future<SmapSession?> read() async => _session;

  @override
  Future<void> save(SmapSession session) async => _session = session;
}

/// API falsa que simula o backend do SMAP conforme configurado no teste.
class FakeSmapApi implements SmapApi {
  FakeSmapApi({this.onLogin});

  Future<AuthResult> Function(String email, String password)? onLogin;

  @override
  Future<AuthResult> login(String email, String password) {
    if (onLogin != null) return onLogin!(email, password);
    throw const AuthException('Sem conexão', isNetworkError: true);
  }

  @override
  Future<Map<String, dynamic>?> fetchConfig() async => null;

  @override
  Future<List<SmapUser>> fetchUserBase(String token) async => const [];
}

const _testHasher = PasswordHasher(iterations: 1000);

Future<UserLocalStore> buildStore() async {
  final db = await databaseFactoryMemory
      .openDatabase('test-${DateTime.now().microsecondsSinceEpoch}');
  return UserLocalStore(db);
}

Future<AuthRepository> buildRepository({
  FakeSmapApi? api,
  bool seedBase = true,
  UserLocalStore? store,
}) async {
  final userStore = store ?? await buildStore();
  const seed = SmapSeedData(hasher: _testHasher);
  if (seedBase) {
    await userStore.upsertAll(seed.users());
  }
  return AuthRepository(
    api: api ?? FakeSmapApi(),
    userStore: userStore,
    sessionStore: InMemorySessionStore(),
    hasher: _testHasher,
    seed: seed,
  );
}

void main() {
  group('AuthRepository (offline-first)', () {
    test('bootstrap pré-carrega a base local quando vazia', () async {
      final repo = await buildRepository(seedBase: false);
      await repo.bootstrap();
      final outcome = await repo.login('admin@smap.local', 'Smap@2025');
      expect(outcome.user.email, 'admin@smap.local');
      expect(outcome.isOffline, isTrue);
    });

    test('login offline funciona com credenciais da base pré-carregada', () async {
      final repo = await buildRepository();
      final outcome = await repo.login('caixa@smap.local', 'Vendas@123');
      expect(outcome.user.role, 'Operador de Caixa');
      expect(outcome.isOffline, isTrue);
      expect(outcome.session.token, startsWith('offline-'));
    });

    test('login offline rejeita senha incorreta', () async {
      final repo = await buildRepository();
      expect(
        () => repo.login('admin@smap.local', 'senhaErrada'),
        throwsA(isA<AuthException>()),
      );
    });

    test('usuário inexistente na base offline lança AuthException', () async {
      final repo = await buildRepository();
      expect(
        () => repo.login('naoexiste@smap.local', 'qualquer'),
        throwsA(isA<AuthException>()),
      );
    });

    test('credenciais inválidas confirmadas pelo servidor não fazem fallback offline',
        () async {
      final api = FakeSmapApi(
        onLogin: (_, _) async => throw const AuthException('Credenciais inválidas'),
      );
      final repo = await buildRepository(api: api);
      // Mesmo existindo o usuário localmente, um 401 do servidor não deve
      // permitir bypass via base offline.
      expect(
        () => repo.login('admin@smap.local', 'Smap@2025'),
        throwsA(isA<AuthException>()),
      );
    });

    test('login online persiste sessão e habilita login offline futuro', () async {
      final api = FakeSmapApi(
        onLogin: (email, password) async => AuthResult(
          token: 'server-token-123',
          user: SmapUser(
            id: 'usr-online',
            name: 'Online User',
            email: email,
            role: 'Administrador',
          ),
          config: const {'nome_empresa': 'SMAP'},
        ),
      );
      final sharedStore = await buildStore();
      final repo = await buildRepository(api: api, seedBase: false, store: sharedStore);

      final online = await repo.login('novo@smap.local', 'MinhaSenha1');
      expect(online.isOffline, isFalse);
      expect(online.session.token, 'server-token-123');

      // Agora, mesmo sem servidor, o mesmo usuário deve autenticar offline
      // reutilizando a base local já materializada pelo login online.
      final offlineRepo = AuthRepository(
        api: FakeSmapApi(),
        userStore: sharedStore,
        sessionStore: InMemorySessionStore(),
        hasher: _testHasher,
      );
      final offline = await offlineRepo.login('novo@smap.local', 'MinhaSenha1');
      expect(offline.isOffline, isTrue);
    });
  });
}
