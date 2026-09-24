import 'package:sembast/sembast.dart';

import '../models/smap_user.dart';

/// Persistência local dos usuários da base pré-carregada do SMAP.
///
/// Faz parte da camada offline-first: os usuários sincronizados do SMAP online
/// ficam disponíveis aqui para autenticação mesmo sem conexão.
class UserLocalStore {
  UserLocalStore(this._db);

  final Database _db;
  final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store('users');

  Future<SmapUser?> findByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final record = await _store.record(normalized).get(_db);
    if (record == null) return null;
    return SmapUser.fromMap(record);
  }

  Future<List<SmapUser>> all() async {
    final records = await _store.find(_db);
    return records.map((r) => SmapUser.fromMap(r.value)).toList();
  }

  Future<int> count() async {
    return _store.count(_db);
  }

  /// Insere ou atualiza um usuário usando o e-mail (normalizado) como chave.
  Future<void> upsert(SmapUser user) async {
    await _store.record(user.email).put(_db, user.toMap());
  }

  /// Insere/atualiza vários usuários numa única transação (usado pelo sync).
  Future<void> upsertAll(List<SmapUser> users) async {
    await _db.transaction((txn) async {
      for (final user in users) {
        await _store.record(user.email).put(txn, user.toMap());
      }
    });
  }

  Future<void> clear() async {
    await _store.delete(_db);
  }
}
