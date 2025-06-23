import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zenlearn/core/localization/app_localizations.dart';
import 'package:zenlearn/core/localization/language_bloc/language_bloc.dart';
import 'package:zenlearn/core/theme/app_theme.dart';
import 'package:zenlearn/core/theme/theme_cubit.dart';
import 'package:zenlearn/core/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings page',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Section
                _buildSectionTitle(context, 'theme'.tr(context)),
                const SizedBox(height: 16),
                _buildThemeSelector(context),

                const SizedBox(height: 32),

                // Language Section
                _buildSectionTitle(context, 'language'.tr(context)),
                const SizedBox(height: 16),
                _buildLanguageSelector(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _languageOption(context, 'en', 'English', Icons.language),
        _languageOption(context, 'ar', 'العربية', Icons.translate),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    ).applyGlass(
      color: Theme.of(context).colorScheme.surface,
      opacity: 0.2,
      blur: 5.0,
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _themeOption(context, ThemeType.dark, 'dark_theme'),
        _themeOption(context, ThemeType.vulkan, 'vulkan_theme'),
        _themeOption(context, ThemeType.sky, 'sky_theme'),
        _themeOption(context, ThemeType.grey, 'grey_theme'),
      ],
    );
  }

  Widget _languageOption(BuildContext context, String languageCode, String label, IconData icon) {
    final currentLanguage = context.watch<LanguageBloc>().state.locale.languageCode;
    final isSelected = currentLanguage == languageCode;

    return GestureDetector(
      onTap: () {
        context.read<LanguageBloc>().add(ChangeLanguageEvent(languageCode));
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).applyGlass(
        color: Theme.of(context).colorScheme.surface,
        opacity: 0.3,
        blur: 5.0,
      ),
    );
  }

  Widget _themeOption(BuildContext context, ThemeType themeType, String label) {
    final currentTheme = context.watch<ThemeCubit>().state.themeType;
    final isSelected = currentTheme == themeType;

    Color backgroundColor;
    IconData iconData;

    switch (themeType) {
      case ThemeType.dark:
        backgroundColor = const Color(0xFF121212);
        iconData = Icons.dark_mode;
        break;
      case ThemeType.vulkan:
        backgroundColor = const Color(0xFF8B0000);
        iconData = Icons.local_fire_department;
        break;
      case ThemeType.sky:
        backgroundColor = const Color(0xFF1E88E5);
        iconData = Icons.cloud;
        break;
      case ThemeType.grey:
        backgroundColor = const Color(0xFF607D8B);
        iconData = Icons.grain;
        break;
    }

    return GestureDetector(
      onTap: () {
        context.read<ThemeCubit>().changeTheme(themeType);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label.tr(context),
              style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).applyGlass(
        color: backgroundColor,
        opacity: 0.3,
        blur: 5.0,
      ),
    );
  }
}
