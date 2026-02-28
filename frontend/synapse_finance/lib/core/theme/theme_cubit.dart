import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  static const _key = 'theme_mode';

  ThemeCubit(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value == 'light') return ThemeMode.light;
    return ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    _prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
    emit(mode);
  }

  bool get isDark => state == ThemeMode.dark;
}
