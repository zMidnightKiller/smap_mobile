import 'package:sembast/sembast.dart';

import 'database_provider_stub.dart'
    if (dart.library.io) 'database_provider_io.dart'
    if (dart.library.html) 'database_provider_web.dart';

/// Ponto único de acesso ao banco local offline-first do SMAP Mobile.
///
/// Encapsula a abertura do [Database] do sembast escolhendo automaticamente o
/// backend correto (arquivo em nativo, IndexedDB no web).
class LocalDatabase {
  LocalDatabase._(this._db);

  final Database _db;
  Database get db => _db;

  static LocalDatabase? _instance;

  /// Abre (uma única vez) e retorna a instância compartilhada do banco.
  static Future<LocalDatabase> instance() async {
    if (_instance != null) return _instance!;
    final db = await openLocalDatabase('smap_mobile.db');
    _instance = LocalDatabase._(db);
    return _instance!;
  }
}
