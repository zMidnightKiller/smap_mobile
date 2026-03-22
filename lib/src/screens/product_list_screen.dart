import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProductProvider>(context, listen: false).fetchProdutos(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Buscar produtos...',
            prefixIcon: const Icon(Icons.search_rounded, color: SmapTheme.textSecondaryColor),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final filteredProdutos = provider.produtos.where((p) {
            return p.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   p.codigoInterno.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredProdutos.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado.'));
          }

          final cart = Provider.of<CartProvider>(context, listen: false);

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: filteredProdutos.length,
            itemBuilder: (context, index) {
              final produto = filteredProdutos[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: SmapTheme.glassDecoration(opacity: 0.05),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SmapTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: SmapTheme.primaryColor),
                  ),
                  title: Text(
                    produto.nome,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Cód: ${produto.codigoInterno}', style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Grade: ${produto.qtdVariacoes} variações', style: TextStyle(color: SmapTheme.textSecondaryColor, fontSize: 12)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: SmapTheme.primaryColor),
                      ),
                      const Text('Preço', style: TextStyle(fontSize: 10, color: SmapTheme.textSecondaryColor)),
                    ],
                  ),
                  onTap: () {
                    cart.addItem(produto);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${produto.nome} adicionado ao carrinho'),
                        duration: 1.seconds,
                        backgroundColor: SmapTheme.primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return cart.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              label: Text('Checkout (${cart.items.length})',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              backgroundColor: SmapTheme.primaryColor,
            ).animate().scale()
          : const SizedBox.shrink();
        },
      ),
    );
  }
}
