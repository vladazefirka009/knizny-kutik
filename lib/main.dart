import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/library_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LibraryProvider(),
      child: const KniznyKutikApp(),
    ),
  );
}

class KniznyKutikApp extends StatelessWidget {
  const KniznyKutikApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF526B56);
    return MaterialApp(
      title: 'Knižný kútik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
          surface: const Color(0xFFFAF8F3),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF8F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF8F3),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFECE8DF)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFECE8DF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFECE8DF)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
