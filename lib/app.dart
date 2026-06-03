import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'providers/settings_provider.dart';

class IptvApp extends ConsumerWidget {
  const IptvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'IPTV Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeFor(Brightness.light, settings.accentColor),
      darkTheme: AppTheme.themeFor(Brightness.dark, settings.accentColor),
      themeMode: settings.themeMode,
      routerConfig: appRouter,
    );
  }
}
