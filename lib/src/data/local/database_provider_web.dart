import 'package:sembast_web/sembast_web.dart';

/// Abre o banco local no Flutter Web usando IndexedDB. Isso garante que a base
/// pré-carregada do SMAP persista entre sessões mesmo offline.
Future<Database> openLocalDatabase(String name) async {
  return databaseFactoryWeb.openDatabase(name);
}
