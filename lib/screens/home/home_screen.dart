import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/playlist_source.dart';
import '../../providers/playlist_source_provider.dart';
import '../../widgets/loading_widget.dart';
import 'add_playlist_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(playlistSourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV Player'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: sourcesAsync.when(
          loading: () => const LoadingWidget(message: 'Loading playlists...'),
          error: (err, _) => ErrorDisplay(
            message: err.toString(),
            onRetry: () => ref.invalidate(playlistSourcesProvider),
          ),
          data: (sources) {
            if (sources.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.live_tv,
                          size: 80, color: Colors.deepPurple.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No playlists added yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add an M3U playlist URL',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: sources.length,
              itemBuilder: (context, index) {
                final source = sources[index];
                return _PlaylistCard(source: source);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddPlaylistSheet(),
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  final PlaylistSource source;
  const _PlaylistCard({required this.source});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(source.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Playlist'),
            content: Text('Remove "${source.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(playlistSourcesProvider.notifier).remove(source);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: source.isActive
              ? BorderSide(color: Colors.deepPurple.shade300, width: 2)
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor:
                source.isActive ? Colors.deepPurple : Colors.grey.shade800,
            child: Icon(
              source.type == PlaylistType.xtreamCodes ? Icons.dns : Icons.link,
              color: Colors.white,
            ),
          ),
          title: Text(
            source.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            source.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          trailing: source.isActive
              ? Chip(
                  label: const Text('Active', style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.deepPurple.shade800,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              : null,
          onTap: () {
            ref.read(playlistSourcesProvider.notifier).setActive(source);
            context.go('/channels');
          },
        ),
      ),
    );
  }
}
