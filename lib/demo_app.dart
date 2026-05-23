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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF007A),
          tertiary: Color(0xFF00E676),
          surface: Color(0xFF0A0F1F),
        ),
      ),
      home: const DemoCalculatorScreen(),
    );
  }
}
