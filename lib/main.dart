import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interquatier/theme/app_theme.dart';
import 'package:interquatier/widgets/error_boundary.dart';
import 'package:interquatier/screens/main_screen.dart';
import 'package:interquatier/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Starting app initialization...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(
    ErrorBoundary(
      child: ProviderScope(
        child: InterQuatierApp(),
      ),
    ),
  );
  debugPrint('App started');
}

class InterQuatierApp extends StatelessWidget {
  const InterQuatierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InterQuatier',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainScreen(),
    );
  }
} 