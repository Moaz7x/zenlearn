import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

// Theme States
enum ThemeType { dark, vulkan, sky, grey }

class ThemeState extends Equatable {
  final ThemeData themeData;
  final ThemeType themeType;

  const ThemeState(this.themeData, this.themeType);

  @override
  List<Object> get props => [themeType];
}

// Theme Cubit
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themePreferenceKey = 'theme_preference';

  ThemeCubit() : super(ThemeState(AppTheme.darkTheme(), ThemeType.dark)) {
    loadTheme();
  }

  void changeTheme(ThemeType themeType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, themeType.toString());

    ThemeData themeData;
    switch (themeType) {
      case ThemeType.dark:
        themeData = AppTheme.darkTheme();
        break;
      case ThemeType.vulkan:
        themeData = AppTheme.vulkanTheme();
        break;
      case ThemeType.sky:
        themeData = AppTheme.skyTheme();
        break;
      case ThemeType.grey:
        themeData = AppTheme.greyTheme();
        break;
    }

    emit(ThemeState(themeData, themeType));
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themePreferenceKey);

    ThemeType themeType = ThemeType.dark; // Default theme

    if (themeString != null) {
      try {
        themeType = ThemeType.values.firstWhere(
          (element) => element.toString() == themeString,
          orElse: () => ThemeType.dark,
        );
      } catch (_) {
        // If there's an error, use the default theme
        
      }
    }

    changeTheme(themeType);
  }
}
