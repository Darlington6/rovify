// theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences? prefs;

  ThemeCubit(this.prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final isDark = prefs?.getBool('isDarkTheme') ?? false;
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      emit(ThemeMode.system);
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      await prefs?.setBool('isDarkTheme', isDark);
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      debugPrint('Error saving theme: $e');
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }
}