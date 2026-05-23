import 'package:flutter/material.dart';

/// The complete colour scheme for the NexaCalc glassmorphism UI.
///
/// All five colour fields are persisted in SharedPreferences as integer ARGB
/// values (Requirement 11.4). Default values match the design specification.
class AppTheme {
  /// Background gradient start colour. Default: `#0A0F1F`.
  final Color backgroundStart;

  /// Background gradient end colour. Default: `#10172A`.
  final Color backgroundEnd;

  /// 1px neon border colour for number buttons. Default: `#00E5FF`.
  final Color numberBorder;

  /// 1px neon border colour for operator buttons. Default: `#FF007A`.
  final Color operatorBorder;

  /// 1px neon border colour for the equals button. Default: `#00E676`.
  final Color equalsBorder;

  const AppTheme({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.numberBorder,
    required this.operatorBorder,
    required this.equalsBorder,
  });

  /// The default NexaCalc theme as specified in the design document.
  static const AppTheme defaultTheme = AppTheme(
    backgroundStart: Color(0xFF0A0F1F),
    backgroundEnd: Color(0xFF10172A),
    numberBorder: Color(0xFF00E5FF),
    operatorBorder: Color(0xFFFF007A),
    equalsBorder: Color(0xFF00E676),
  );

  /// Creates a copy of this theme with the given fields replaced.
  AppTheme copyWith({
    Color? backgroundStart,
    Color? backgroundEnd,
    Color? numberBorder,
    Color? operatorBorder,
    Color? equalsBorder,
  }) {
    return AppTheme(
      backgroundStart: backgroundStart ?? this.backgroundStart,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      numberBorder: numberBorder ?? this.numberBorder,
      operatorBorder: operatorBorder ?? this.operatorBorder,
      equalsBorder: equalsBorder ?? this.equalsBorder,
    );
  }

  @override
  String toString() =>
      'AppTheme(backgroundStart: $backgroundStart, backgroundEnd: $backgroundEnd, '
      'numberBorder: $numberBorder, operatorBorder: $operatorBorder, '
      'equalsBorder: $equalsBorder)';

  @override
  bool operator ==(Object other) =>
      other is AppTheme &&
      other.backgroundStart == backgroundStart &&
      other.backgroundEnd == backgroundEnd &&
      other.numberBorder == numberBorder &&
      other.operatorBorder == operatorBorder &&
      other.equalsBorder == equalsBorder;

  @override
  int get hashCode => Object.hash(
        backgroundStart,
        backgroundEnd,
        numberBorder,
        operatorBorder,
        equalsBorder,
      );
}

/// Abstract interface for reading and writing the custom app theme.
///
/// Persists each [AppTheme] colour field as an integer ARGB value in
/// SharedPreferences (Requirement 11.4, 11.5).
///
/// SharedPreferences keys:
/// - `theme_bg_start`   → [AppTheme.backgroundStart]
/// - `theme_bg_end`     → [AppTheme.backgroundEnd]
/// - `theme_num_border` → [AppTheme.numberBorder]
/// - `theme_op_border`  → [AppTheme.operatorBorder]
/// - `theme_eq_border`  → [AppTheme.equalsBorder]
abstract class ThemeEditor {
  /// The currently active theme.
  ///
  /// Returns the saved custom theme if one exists in SharedPreferences,
  /// otherwise returns [AppTheme.defaultTheme] (Requirement 11.5).
  AppTheme get currentTheme;

  /// Persists [theme] to SharedPreferences and updates [currentTheme].
  ///
  /// The new theme is applied immediately without requiring an app restart
  /// (Requirement 11.3).
  Future<void> saveTheme(AppTheme theme);
}
