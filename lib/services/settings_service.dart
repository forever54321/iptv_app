import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

/// Persists [AppSettings] in a simple key/value Hive box.
class SettingsService {
  static const _boxName = 'settings';

  static Box get _box => Hive.box(_boxName);

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static AppSettings load() {
    return AppSettings(
      themeMode: ThemeMode.values[
          (_box.get('themeMode', defaultValue: ThemeMode.dark.index) as int)
              .clamp(0, ThemeMode.values.length - 1)],
      accentIndex: _box.get('accentIndex', defaultValue: 0) as int,
      defaultVolume:
          (_box.get('defaultVolume', defaultValue: 100.0) as num).toDouble(),
      autoplay: _box.get('autoplay', defaultValue: true) as bool,
    );
  }

  static Future<void> save(AppSettings s) async {
    await _box.put('themeMode', s.themeMode.index);
    await _box.put('accentIndex', s.accentIndex);
    await _box.put('defaultVolume', s.defaultVolume);
    await _box.put('autoplay', s.autoplay);
  }
}
