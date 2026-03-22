import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estatísticas', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: SmapTheme.glassDecoration(opacity: 0.05, borderRadius: 12),
            child: Row(
              children: [
                const Text('Maio 2024', style: TextStyle(fontSize: 12)),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 40),
          _buildCircularChart(),
          const SizedBox(height: 40),
          Expanded(
            child: _buildBreakdownList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: SmapTheme.glassDecoration(opacity: 0.03, borderRadius: 16),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: -20, vertical: 8),
        indicator: BoxDecoration(
          color: SmapTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: SmapTheme.textSecondaryColor,
        tabs: const [
          Tab(text: 'Entradas'),
          Tab(text: 'Saídas'),
        ],
      ),
    );
  }

  Widget _buildCircularChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: ChartPainter(),
          ),
        ).animate().rotate(duration: 1.seconds, curve: Curves.easeOutCubic),
        Column(
          children: [
            Text(
              'TOTAL ENTRADAS',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: SmapTheme.textSecondaryColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ 20.173,00',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownList() {
    final items = [
      {'label': 'Venda Direta', 'value': 'R\$ 10.086,50', 'percent': 0.50, 'color': SmapTheme.primaryColor},
      {'label': 'E-commerce', 'value': 'R\$ 3.631,14', 'percent': 0.18, 'color': SmapTheme.secondaryColor},
      {'label': 'Serviços', 'value': 'R\$ 3.429,41', 'percent': 0.17, 'color': const Color(0xFF8B5CF6)},
      {'label': 'Outros', 'value': 'R\$ 3.025,95', 'percent': 0.15, 'color': const Color(0xFF1E212E)},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(item['value'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${((item['percent'] as double) * 100).toInt()}%',
                      style: TextStyle(color: item['color'] as Color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item['percent'] as double,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation(item['color'] as Color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (200 * index).ms).slideX(begin: 0.1);
      },
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    // Background circle
    paint.color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(center, radius - 15, paint);

    // Segment 1
    paint.color = const Color(0xFF6366F1);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      -pi / 2,
      pi,
      false,
      paint,
    );

    // Segment 2
    paint.color = const Color(0xFFFB7185);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      pi / 2,
      pi * 0.4,
      false,
      paint,
    );
    
    // Segment 3
    paint.color = const Color(0xFF8B5CF6);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      pi * 0.9,
      pi * 0.3,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
