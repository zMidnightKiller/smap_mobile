import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/cart_provider.dart';
import 'src/screens/loading_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/providers/product_provider.dart';
import 'src/screens/product_list_screen.dart';
import 'src/screens/main_layout.dart';
import 'src/screens/success_screen.dart';
import 'src/screens/checkout_screen.dart';
import 'src/providers/dashboard_provider.dart';
import 'src/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const SmapApp(),
    ),
  );
}

class SmapApp extends StatelessWidget {
  const SmapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'SMAP Mobile',
          debugShowCheckedModeBanner: false,
          theme: SmapTheme.getDynamicTheme(auth.config),
          initialRoute: '/',
          routes: {
            '/': (context) => const LoadingScreen(),
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const MainLayout(),
            '/products': (context) => const ProductListScreen(),
            '/checkout': (context) => const CheckoutScreen(),
            '/success': (context) => const SuccessScreen(),
          },
        );
      },
    );
  }
}
