import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexacalc/core/interfaces/theme_editor.dart';

class ThemeEditorImpl implements ThemeEditor {
  static const _kBgStart = 'theme_bg_start';
  static const _kBgEnd = 'theme_bg_end';
  static const _kNum = 'theme_num_border';
  static const _kOp = 'theme_op_border';
  static const _kEq = 'theme_eq_border';

  AppTheme _current = AppTheme.defaultTheme;

  ThemeEditorImpl() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final bgStart = prefs.getInt(_kBgStart);
    final bgEnd = prefs.getInt(_kBgEnd);
    final numB = prefs.getInt(_kNum);
    final opB = prefs.getInt(_kOp);
    final eqB = prefs.getInt(_kEq);

    if (bgStart != null && bgEnd != null && numB != null && opB != null && eqB != null) {
      _current = AppTheme(
        backgroundStart: Color(bgStart),
        backgroundEnd: Color(bgEnd),
        numberBorder: Color(numB),
        operatorBorder: Color(opB),
        equalsBorder: Color(eqB),
      );
    }
  }

  @override
  AppTheme get currentTheme => _current;

  @override
  Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBgStart, theme.backgroundStart.value);
    await prefs.setInt(_kBgEnd, theme.backgroundEnd.value);
    await prefs.setInt(_kNum, theme.numberBorder.value);
    await prefs.setInt(_kOp, theme.operatorBorder.value);
    await prefs.setInt(_kEq, theme.equalsBorder.value);
    _current = theme;
  }
}
