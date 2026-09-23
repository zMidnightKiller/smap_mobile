import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/produto_model.dart';
import '../providers/catalog_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Catálogo de Produtos do SMAP (offline-first): busca por nome/código, estoque,
/// variações e status, com detalhe em bottom sheet. Lê da base local.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = context.read<CatalogProvider>();
      if (!catalog.loadedOnce) catalog.load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final produtos = catalog.produtos;

    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          if (catalog.loadedOnce)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${catalog.totalAtivos}/${catalog.totalProdutos} ativos',
                  style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: catalog.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou código...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: catalog.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          catalog.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: catalog.isLoading && !catalog.loadedOnce
                ? const Center(child: CircularProgressIndicator())
                : produtos.isEmpty
                    ? _EmptyState(hasQuery: catalog.query.isNotEmpty)
                    : RefreshIndicator(
                        color: SmapTheme.primaryColor,
                        onRefresh: () => catalog.load(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: produtos.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => _ProductCard(
                            produto: produtos[i],
                            onTap: () => _showDetail(context, produtos[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Produto produto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SmapTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ProductDetailSheet(produto: produto),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.produto, required this.onTap});
  final Produto produto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semEstoque = produto.estoqueTotal <= 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: SmapTheme.cardDecoration(borderRadius: 18),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: SmapTheme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.inventory_2_rounded, color: SmapTheme.primaryColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            produto.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: SmapTheme.textColor,
                            ),
                          ),
                        ),
                        if (!produto.ativo) const _StatusPill(label: 'Inativo', color: SmapTheme.textSecondaryColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cód. ${produto.codigoInterno} · ${produto.qtdVariacoes} variações',
                      style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _EstoqueChip(estoque: produto.estoqueTotal, semEstoque: semEstoque),
                        const Spacer(),
                        Text(
                          formatMoeda(produto.precoVenda),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: SmapTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstoqueChip extends StatelessWidget {
  const _EstoqueChip({required this.estoque, required this.semEstoque});
  final double estoque;
  final bool semEstoque;

  @override
  Widget build(BuildContext context) {
    final color = semEstoque ? SmapTheme.errorColor : SmapTheme.accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(semEstoque ? Icons.remove_circle_outline_rounded : Icons.inventory_rounded,
              size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            semEstoque ? 'Sem estoque' : '${formatNumero(estoque)} em estoque',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasQuery ? Icons.search_off_rounded : Icons.inventory_2_outlined,
              size: 56, color: SmapTheme.textSecondaryColor.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'Nenhum produto encontrado' : 'Catálogo vazio',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: SmapTheme.textColor),
          ),
          const SizedBox(height: 6),
          Text(
            hasQuery ? 'Tente outro nome ou código.' : 'Sincronize com o SMAP para carregar os produtos.',
            style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  const _ProductDetailSheet({required this.produto});
  final Produto produto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: SmapTheme.borderColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: SmapTheme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: SmapTheme.primaryColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nome,
                        style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w700, color: SmapTheme.textColor),
                      ),
                      const SizedBox(height: 2),
                      Text('Cód. ${produto.codigoInterno}',
                          style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 13)),
                    ],
                  ),
                ),
                _StatusPill(
                  label: produto.ativo ? 'Ativo' : 'Inativo',
                  color: produto.ativo ? SmapTheme.accentColor : SmapTheme.textSecondaryColor,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SmapTheme.fieldColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preço de venda', style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(formatMoeda(produto.precoVenda),
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: SmapTheme.primaryColor)),
                    ],
                  ),
                  _EstoqueChip(estoque: produto.estoqueTotal, semEstoque: produto.estoqueTotal <= 0),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Variações', value: '${produto.qtdVariacoes}'),
            _DetailRow(label: 'Estoque total', value: '${formatNumero(produto.estoqueTotal)} un.'),
            _DetailRow(label: 'Status', value: produto.ativo ? 'Ativo' : 'Inativo'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                      content: Text('PDV / Nova Venda chega no próximo passo do roadmap.'),
                    ));
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: const Text('Adicionar à venda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 14)),
          Text(value, style: const TextStyle(color: SmapTheme.textColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
