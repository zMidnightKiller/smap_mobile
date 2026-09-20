import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

/// Abre o banco local em plataformas nativas (Android/iOS/desktop) usando um
/// arquivo no diretório de documentos do app.
Future<Database> openLocalDatabase(String name) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/$name';
  return databaseFactoryIo.openDatabase(path);
}
