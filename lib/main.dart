import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'providers/products_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');
    debugPrint('Base URL: ${dotenv.env['WOOCOMMERCE_URL']}');
  } catch (e) {
    debugPrint('Error loading environment variables: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await AuthService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'Nature Republic',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            primary: const Color(0xFF4CAF50),
            secondary: const Color(0xFF2E7D32),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.cairoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
