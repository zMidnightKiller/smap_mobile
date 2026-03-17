import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/screens/loading_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/dashboard_screen.dart';
import 'src/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SmapApp(),
    ),
  );
}

class SmapApp extends StatelessWidget {
  const SmapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMAP Mobile',
      debugShowCheckedModeBanner: false,
      theme: SmapTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
