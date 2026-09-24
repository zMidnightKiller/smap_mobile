import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/cart_provider.dart';
import 'src/providers/catalog_provider.dart';
import 'src/screens/auth_gate.dart';
import 'src/providers/product_provider.dart';
import 'src/screens/product_list_screen.dart';
import 'src/screens/success_screen.dart';
import 'src/screens/checkout_screen.dart';
import 'src/providers/dashboard_provider.dart';
import 'src/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
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
          home: const AuthGate(),
          routes: {
            // Fluxo de PDV legado (será reconstruído nos itens 6–8 do roadmap).
            '/products': (context) => const ProductListScreen(),
            '/checkout': (context) => const CheckoutScreen(),
            '/success': (context) => const SuccessScreen(),
          },
        );
      },
    );
  }
}
