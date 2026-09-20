import 'package:sembast/sembast.dart';

/// Fallback usado apenas quando nenhuma plataforma suportada é detectada em
/// tempo de compilação. Nunca deve ser executado em runtime.
Future<Database> openLocalDatabase(String name) {
  throw UnsupportedError(
    'Nenhum backend de banco local disponível para esta plataforma.',
  );
}
