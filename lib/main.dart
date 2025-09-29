import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'core/app_export.dart';
import 'core/supabase_config.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/database_service.dart';
import 'services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await SupabaseConfig.initialize();
    print('DEBUG: Supabase initialized successfully');
  } catch (e) {
    print('DEBUG: Supabase initialization failed: $e');
    // Continue without Supabase for now
  }
  
  // Initialize Supabase Analytics
  try {
    await AnalyticsService.initialize();
    print('DEBUG: Supabase Analytics initialized successfully');
  } catch (e) {
    print('DEBUG: Supabase Analytics initialization failed: $e');
    // Continue without Analytics for now
  }
  
  // Set preferred orientations for admin dashboard (desktop-first)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'GroceryFlow Admin Dashboard',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
        navigatorObservers: [], // Supabase Analytics doesn't need observers
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}