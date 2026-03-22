import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic>? transactionData;

  const SuccessScreen({super.key, this.transactionData});

  @override
  Widget build(BuildContext context) {
    // Extraímos os dados da transação
    final vendaId = transactionData?['id']?.toString() ?? '---';
    final total = transactionData?['total']?.toString() ?? '0.00';
    final data = transactionData?['data_venda'] != null 
        ? DateTime.parse(transactionData!['data_venda']).toLocal() 
        : DateTime.now();

    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: SmapTheme.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: SmapTheme.accentColor,
                      size: 64,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                  const SizedBox(height: 24),
                  Text(
                    'Venda Realizada!',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'O comprovante foi gerado com sucesso.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SmapTheme.surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Código da Venda', '#$vendaId'),
                  const Divider(height: 32, color: Colors.white10),
                  _buildDetailRow('Data', '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}'),
                  const Divider(height: 32, color: Colors.white10),
                  _buildDetailRow('Total', 'R\$ $total', isTotal: true),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/products', (route) => false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SmapTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'VOLTAR AO INÍCIO',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white60,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? SmapTheme.accentColor : Colors.white,
          ),
        ),
      ],
    );
  }
}
