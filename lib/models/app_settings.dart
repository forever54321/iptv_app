import 'package:flutter/material.dart';

/// User-configurable application settings, persisted via [SettingsService].
class AppSettings {
  final ThemeMode themeMode;

  /// Index into [accentColors] of the chosen accent / seed color.
  final int accentIndex;

  /// Default playback volume (0–100) applied when a channel starts.
  final double defaultVolume;

  /// Whether playback starts automatically when a channel is opened.
  final bool autoplay;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.accentIndex = 0,
    this.defaultVolume = 100,
    this.autoplay = true,
  });

  /// Preset accent colors selectable in Settings.
  static const List<Color> accentColors = <Color>[
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.pink,
  ];

  static const List<String> accentNames = <String>[
    'Purple',
    'Indigo',
    'Blue',
    'Teal',
    'Green',
    'Orange',
    'Red',
    'Pink',
  ];

  Color get accentColor =>
      accentColors[accentIndex.clamp(0, accentColors.length - 1)];

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? accentIndex,
    double? defaultVolume,
    bool? autoplay,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentIndex: accentIndex ?? this.accentIndex,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      autoplay: autoplay ?? this.autoplay,
    );
  }
}
