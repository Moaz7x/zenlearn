# ZenLearn

A Flutter learning application with localization and theming support.

## Features

### Localization

- Support for English and Arabic languages
- Easy language switching with BLoC pattern
- RTL support for Arabic language
- Localized date formatting

### Theming

The app includes four beautiful themes with glass and blur effects:

1. **Dark Theme** - A sleek dark theme with purple accents
2. **Vulkan Theme** - A bold red and black theme
3. **Sky Theme** - A light blue theme
4. **Grey Theme** - A neutral grey theme

## Implementation Details

### Localization

Localization is implemented using:

- Flutter's built-in localization system
- BLoC pattern for state management
- Translation files for English and Arabic
- Extension methods for easy access to translations

### Theming

Theming is implemented using:

- BLoC pattern for state management
- Glass effect with backdrop filter for modern UI
- Shared preferences for persisting theme selection
- Extension methods for applying glass effects to widgets

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── color_constants.dart
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   ├── language_bloc/
│   │   │   └── language_bloc.dart
│   │   └── translations/
│   │       ├── ar.dart
│   │       └── en.dart
│   └── theme/
│       ├── app_theme.dart
│       └── theme_cubit.dart
└── features/
    ├── intro/
    │   └── presentation/
    │       └── pages/
    │           └── intro_page.dart
    └── settings/
        └── presentation/
            └── pages/
                └── settings_page.dart
```

## Usage

### Changing Language

```dart
context.read<LanguageBloc>().add(ChangeLanguageEvent('ar')); // Change to Arabic
context.read<LanguageBloc>().add(ChangeLanguageEvent('en')); // Change to English
```

### Translating Text

```dart
// Using extension method
'key_name'.tr(context)

// Using AppLocalizations directly
AppLocalizations.of(context).translate('key_name')
```

### Changing Theme

```dart
context.read<ThemeCubit>().changeTheme(ThemeType.dark);
context.read<ThemeCubit>().changeTheme(ThemeType.vulkan);
context.read<ThemeCubit>().changeTheme(ThemeType.sky);
context.read<ThemeCubit>().changeTheme(ThemeType.grey);
```

### Applying Glass Effect

```dart
// Using extension method
Widget myWidget = Container(...).applyGlass(
  color: Colors.white,
  opacity: 0.2,
  blur: 10.0,
);

// Using AppTheme directly
Widget myWidget = AppTheme.glassContainer(
  child: Container(...),
  color: Colors.white,
  opacity: 0.2,
  blur: 10.0,
);
```
# zenLearn.
# zenLearn.
# zenLearng
