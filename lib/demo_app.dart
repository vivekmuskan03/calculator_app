import 'package:flutter/material.dart';
import 'package:nexacalc/screens/demo_calculator_screen.dart';

/// Lightweight plugin-free demo application for web/desktop targets.
class NexaCalcDemoApp extends StatelessWidget {
  const NexaCalcDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaCalc Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5BFF),
          brightness: Brightness.light,
          primary: const Color(0xFF5C4DFF),
          secondary: const Color(0xFFFF4D8D),
          tertiary: const Color(0xFF10B981),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF334155),
          ),
        ),
      ),
      home: const DemoCalculatorScreen(),
    );
  }
}
