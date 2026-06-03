import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/content_type.dart';
import '../../providers/category_filter_provider.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/loading_widget.dart';

class ContentTypeScreen extends ConsumerWidget {
  const ContentTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Browse'),
      ),
      body: channelsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading playlist...'),
        error: (err, _) => ErrorDisplay(
          message: err.toString(),
          onRetry: () => ref.invalidate(channelListProvider),
        ),
        data: (channels) {
          final counts = ref.watch(contentTypeCountsProvider);
          final available =
              ContentType.values.where((t) => (counts[t] ?? 0) > 0).toList();

          if (available.isEmpty) {
            return const Center(
              child: Text('No channels found in this playlist.'),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'What would you like to watch?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  for (final type in ContentType.values)
                    _ContentTypeCard(
                      type: type,
                      count: counts[type] ?? 0,
                      onTap: (counts[type] ?? 0) == 0
                          ? null
                          : () => _select(context, ref, type),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, ContentType type) {
    // Reset downstream filters so the new section starts clean.
    ref.read(selectedContentTypeProvider.notifier).state = type;
    ref.read(selectedCategoryProvider.notifier).state = null;
    ref.read(searchQueryProvider.notifier).state = '';
    context.go('/channels');
  }
}

class _ContentTypeCard extends StatelessWidget {
  final ContentType type;
  final int count;
  final VoidCallback? onTap;

  const _ContentTypeCard({
    required this.type,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final enabled = onTap != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(type.icon, color: color, size: 30),
          ),
          title: Text(
            type.label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            enabled
                ? '$count ${count == 1 ? 'item' : 'items'}'
                : 'None available',
          ),
          trailing: enabled
              ? const Icon(Icons.chevron_right)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
