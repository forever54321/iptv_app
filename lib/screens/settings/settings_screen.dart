import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';
import '../../providers/playlist_source_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _sectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(settings.themeMode)),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  tooltip: 'System',
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  tooltip: 'Light',
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  tooltip: 'Dark',
                ),
              ],
              showSelectedIcon: false,
              selected: {settings.themeMode},
              onSelectionChanged: (s) => notifier.setThemeMode(s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accent color',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < AppSettings.accentColors.length; i++)
                      _ColorDot(
                        color: AppSettings.accentColors[i],
                        selected: settings.accentIndex == i,
                        onTap: () => notifier.setAccentIndex(i),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          _sectionHeader(context, 'Playback'),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Default volume'),
            subtitle: Slider(
              value: settings.defaultVolume,
              max: 100,
              divisions: 20,
              label: '${settings.defaultVolume.round()}%',
              onChanged: (v) => notifier.setDefaultVolume(v),
            ),
            trailing: Text('${settings.defaultVolume.round()}%'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.play_circle_outline),
            title: const Text('Autoplay'),
            subtitle: const Text('Start playing as soon as a channel opens'),
            value: settings.autoplay,
            onChanged: (v) => notifier.setAutoplay(v),
          ),
          const Divider(height: 1),

          _sectionHeader(context, 'Data'),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
            title: Text(
              'Clear all playlists',
              style: TextStyle(color: Colors.red.shade400),
            ),
            subtitle: const Text('Remove every saved playlist source'),
            onTap: () => _confirmClear(context, ref),
          ),
          const Divider(height: 1),

          _sectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.live_tv),
            title: Text('IPTV Player'),
            subtitle: Text('Version 1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.playlist_play),
            title: Text('Playlists'),
            subtitle: Text('M3U URL and Xtream Codes supported'),
          ),
          const ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Contact'),
            subtitle: Text('IPTV@zakari.me'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all playlists?'),
        content: const Text(
          'This permanently removes every saved playlist source. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(playlistSourcesProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All playlists cleared')),
        );
      }
    }
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
