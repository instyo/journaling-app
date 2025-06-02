import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _themeModeKey = 'themeMode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeString = prefs.getString(_themeModeKey);
    if (themeString != null) {
      emit(ThemeMode.values.firstWhere((e) => e.name == themeString, orElse: () => ThemeMode.system));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    emit(mode);
  }
}