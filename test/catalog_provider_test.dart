import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:smap_mobile/src/data/local/catalog_local_store.dart';
import 'package:smap_mobile/src/data/local/catalog_seed.dart';
import 'package:smap_mobile/src/providers/catalog_provider.dart';

Future<CatalogLocalStore> buildStore() async {
  final db = await databaseFactoryMemory
      .openDatabase('cat-${DateTime.now().microsecondsSinceEpoch}');
  return CatalogLocalStore(db);
}

void main() {
  group('CatalogProvider', () {
    test('pré-carrega o catálogo quando vazio e ordena por nome', () async {
      final provider = CatalogProvider(store: await buildStore());
      await provider.load();

      expect(provider.loadedOnce, isTrue);
      expect(provider.totalProdutos, greaterThan(0));
      expect(provider.totalAtivos, lessThanOrEqualTo(provider.totalProdutos));

      final nomes = provider.produtos.map((p) => p.nome).toList();
      final ordenado = [...nomes]..sort();
      expect(nomes, ordenado);
    });

    test('busca filtra por nome ou código (case-insensitive)', () async {
      final provider = CatalogProvider(store: await buildStore());
      await provider.load();

      provider.setQuery('jeans');
      expect(provider.produtos, isNotEmpty);
      expect(
        provider.produtos.every((p) => p.nome.toLowerCase().contains('jeans')),
        isTrue,
      );

      // Busca por código presente no seed.
      provider.setQuery('CAM-001');
      expect(provider.produtos.length, 1);
      expect(provider.produtos.first.codigoInterno, 'CAM-001');

      provider.setQuery('inexistente-xyz');
      expect(provider.produtos, isEmpty);

      provider.setQuery('');
      expect(provider.produtos.length, provider.totalProdutos);
    });

    test('não duplica ao recarregar (seed idempotente)', () async {
      final store = await buildStore();
      final seed = const CatalogSeed();
      final provider = CatalogProvider(store: store, seed: seed);

      await provider.load();
      final primeiro = provider.totalProdutos;
      await provider.load();
      expect(provider.totalProdutos, primeiro);
      expect(primeiro, seed.produtos().length);
    });
  });
}
