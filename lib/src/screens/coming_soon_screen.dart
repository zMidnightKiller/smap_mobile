import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Placeholder elegante para funcionalidades do SMAP ainda em reconstrução.
/// Mantém a experiência coesa enquanto avançamos no roadmap, tela a tela.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.roadmapStep,
  });

  final String title;
  final IconData icon;
  final String description;
  final String? roadmapStep;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmapTheme.backgroundColor,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: SmapTheme.primaryColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: SmapTheme.primaryColor.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, size: 42, color: SmapTheme.primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: SmapTheme.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SmapTheme.textSecondaryColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SmapTheme.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SmapTheme.accentColor.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.construction_rounded, size: 15, color: SmapTheme.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      roadmapStep ?? 'Em desenvolvimento',
                      style: const TextStyle(
                        color: SmapTheme.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
