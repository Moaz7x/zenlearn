import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:zenlearn/core/bloc/bottomnavbar/navigation_bloc.dart';
import 'package:zenlearn/core/bloc/oserver/bloc_observer.dart';
import 'package:zenlearn/core/localization/app_localizations.dart';
import 'package:zenlearn/core/localization/language_bloc/language_bloc.dart';
import 'package:zenlearn/core/routes/app_routes.dart';
import 'package:zenlearn/core/services/notification_services.dart';
import 'package:zenlearn/core/theme/theme_cubit.dart';
import 'package:zenlearn/features/todo/presentation/bloc/todo_bloc.dart';

import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = Blocserver();
  await NotiService().initNotification();
  if (!kIsWeb && Platform.isAndroid) {}
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc()..add(LoadLanguageEvent()),
        ),
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(
          create: (context) => di.sl<TodoBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: themeState.themeData,
                locale: languageState.locale,
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('ar'), // Arabic
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
