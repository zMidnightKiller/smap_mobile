import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _formaPagamento = 'DINHEIRO';
  bool _isProcessing = false;

  final Map<String, IconData> _paymentMethods = {
    'DINHEIRO': Icons.payments_rounded,
    'CARTAO': Icons.credit_card_rounded,
    'PRAZO': Icons.calendar_today_rounded,
    'PIX': Icons.qr_code_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Finalizar Venda', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do Pedido',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, i) {
                  final item = cart.items.values.toList()[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('1x R\$ ${item.precoVenda.toStringAsFixed(2)}'),
                    trailing: Text('R\$ ${item.precoVenda.toStringAsFixed(2)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const Divider(height: 32),
            _buildTotalRow('Subtotal', cart.totalAmount),
            _buildTotalRow('Total', cart.totalAmount, isTotal: true),
            const SizedBox(height: 32),
            Text(
              'Forma de Pagamento',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: _paymentMethods.entries.map((entry) {
                final isSelected = _formaPagamento == entry.key;
                return ChoiceChip(
                  label: Text(entry.key),
                  avatar: Icon(entry.value, size: 18, color: isSelected ? Colors.white : Colors.black54),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _formaPagamento = entry.key),
                  selectedColor: SmapTheme.primaryColor,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _handleCheckout(context, cart, auth),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SmapTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('CONFIRMAR VENDA', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          )),
          Text('R\$ ${value.toStringAsFixed(2)}', style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? SmapTheme.primaryColor : Colors.white,
          )),
        ],
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context, CartProvider cart, AuthProvider auth) async {
    setState(() => _isProcessing = true);

    final result = await cart.checkout(
      auth.token!,
      auth.baseUrl,
      formaPagamento: _formaPagamento,
    );

    setState(() => _isProcessing = false);

    if (result != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/success', arguments: result);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao processar venda. Verifique sua conexão.')),
        );
      }
    }
  }
}
