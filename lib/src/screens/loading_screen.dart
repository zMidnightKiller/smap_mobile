import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background imersivo
          Container(
            decoration: const BoxDecoration(color: SmapTheme.backgroundColor),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SmapTheme.primaryColor.withValues(alpha: 0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: 0, end: 50, duration: 4.seconds, curve: Curves.easeInOut),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SmapTheme.secondaryColor.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveX(begin: 0, end: 40, duration: 5.seconds, curve: Curves.easeInOut),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ).animate()
                 .scale(duration: 800.ms, curve: Curves.easeOutBack)
                 .shimmer(delay: 1.seconds, duration: 2.seconds, color: SmapTheme.primaryColor),
                
                const SizedBox(height: 32),
                
                Text(
                  'SMAP',
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                ).animate()
                 .fadeIn(delay: 400.ms, duration: 800.ms)
                 .blur(begin: const Offset(10, 10), end: Offset.zero),
                
                const SizedBox(height: 8),
                
                Text(
                  'ADVANCED MANAGEMENT',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: SmapTheme.textSecondaryColor,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate()
                 .fadeIn(delay: 800.ms)
                 .slideY(begin: 1),
                 
                const SizedBox(height: 100),
                
                // Barra de progresso premium personalizada
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 10,
                        height: 4,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: SmapTheme.primaryColor.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                          gradient: const LinearGradient(
                            colors: [SmapTheme.primaryColor, SmapTheme.secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .moveX(begin: 0, end: 190, duration: 2.seconds),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
