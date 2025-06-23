import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguageEvent extends LanguageEvent {
  final String languageCode;

  const ChangeLanguageEvent(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

class LoadLanguageEvent extends LanguageEvent {}

// States
class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object> get props => [locale];
}

// BLoC
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _languagePreferenceKey = 'language_code';

  LanguageBloc() : super(const LanguageState(Locale('en'))) {
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<LoadLanguageEvent>(_onLoadLanguage);
  }

  Future<void> _onChangeLanguage(ChangeLanguageEvent event, Emitter<LanguageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePreferenceKey, event.languageCode);
    emit(LanguageState(Locale(event.languageCode)));
  }

  Future<void> _onLoadLanguage(LoadLanguageEvent event, Emitter<LanguageState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languagePreferenceKey) ?? 'en';
    emit(LanguageState(Locale(languageCode)));
  }
}
