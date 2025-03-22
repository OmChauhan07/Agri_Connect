import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/ngo_provider.dart';
import 'screens/auth/login_screen.dart';
import 'services/supabase_init.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add a delay for Flutter web to fully initialize
  await Future.delayed(const Duration(milliseconds: 500));
  
  try {
    // Initialize Supabase with credentials
    await SupabaseInit.initialize();
    
    // Setup the database if needed
    await SupabaseInit.setupDatabase();
    
    print('Supabase initialization completed successfully');
  } catch (e) {
    print('Error during initialization: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => NGOProvider()),
      ],
      child: MaterialApp(
        title: 'AgriConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('hi', ''), // Hindi
          Locale('gu', ''), // Gujarati
          // As per requirements: English, Hindi, Gujarati
        ],
        home: const LoginScreen(),
      ),
    );
  }
}
