import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => SettingsService.load();

  Future<void> _update(AppSettings next) async {
    state = next;
    await SettingsService.save(next);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setAccentIndex(int index) =>
      _update(state.copyWith(accentIndex: index));

  Future<void> setDefaultVolume(double volume) =>
      _update(state.copyWith(defaultVolume: volume));

  Future<void> setAutoplay(bool value) =>
      _update(state.copyWith(autoplay: value));
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
