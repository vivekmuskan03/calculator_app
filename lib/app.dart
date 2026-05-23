import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexacalc/screens/calculator_screen.dart';

/// Root widget for NexaCalc.
///
/// Sets up [MaterialApp] with the dark glassmorphism theme and registers
/// the initial route. Uses [ConsumerWidget] so it can react to theme changes
/// from [ThemeEditor] without requiring an app restart (Requirement 11.3).
class NexaCalcApp extends ConsumerWidget {
  const NexaCalcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NexaCalc',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      // The calculator screen is the initial route.
      // Full routing will be wired in Task 14 (Calculator screen UI).
      home: const CalculatorScreen(),
    );
  }

  /// Builds the base Material theme for NexaCalc.
  ///
  /// Uses the dark colour scheme as the foundation; the glassmorphism
  /// overlay colours are applied per-widget using [AppTheme] from
  /// [ThemeEditor] (Requirement 6.1–6.4).
  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0F1F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5FF),   // number button neon
        secondary: Color(0xFFFF007A), // operator button neon
        tertiary: Color(0xFF00E676),  // equals button neon
        surface: Color(0xFF0A0F1F),
      ),
      textTheme: TextTheme(
        // Expression display: Roboto Mono 36sp (Requirement 6.5)
        displayLarge: GoogleFonts.robotoMono(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        // Result display: Inter 28sp (Requirement 6.6)
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          color: Colors.white70,
          fontWeight: FontWeight.w300,
        ),
      ),
      useMaterial3: true,
    );
  }
}

/// Temporary placeholder shown until the Calculator screen is implemented
/// in Task 14. Displays the app name on the dark background.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0F1F), // backgroundStart
              Color(0xFF10172A), // backgroundEnd
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'NexaCalc',
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 32,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}
