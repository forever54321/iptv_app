import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/channel_category.dart';
import '../../providers/category_filter_provider.dart';
import '../../providers/channel_list_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/loading_widget.dart';
import 'category_sidebar.dart';
import 'channel_tile.dart';

class ChannelsScreen extends ConsumerStatefulWidget {
  const ChannelsScreen({super.key});

  @override
  ConsumerState<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends ConsumerState<ChannelsScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelListProvider);
    final selected = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search channels...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
              )
            : Text(selected?.name ?? 'Channels'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
        ],
      ),
      drawer: channelsAsync.whenOrNull(
        data: (allChannels) {
          if (allChannels.isEmpty) return null;
          final categories = ref.watch(categoriesProvider);
          final groups = categories
              .where((c) => c.type == CategoryType.group)
              .toList();
          final languages = categories
              .where((c) => c.type == CategoryType.language)
              .toList();

          return Drawer(
            backgroundColor: const Color(0xFF1A1A2E),
            child: SafeArea(
              child: CategorySidebar(
                groups: groups,
                languages: languages,
                selected: selected,
                totalCount: allChannels.length,
                onSelect: (cat) {
                  ref.read(selectedCategoryProvider.notifier).state = cat;
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
      ),
      body: channelsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading channels...'),
        error: (err, _) => ErrorDisplay(
          message: err.toString(),
          onRetry: () => ref.invalidate(channelListProvider),
        ),
        data: (allChannels) {
          if (allChannels.isEmpty) {
            return const Center(
                child: Text('No channels found in this playlist.'));
          }

          final filtered = ref.watch(filteredChannelsProvider);

          if (filtered.isEmpty) {
            return const Center(
                child: Text('No channels match your filter.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return ChannelTile(
                channel: filtered[index],
                onTap: () {
                  context.go('/player', extra: {
                    'initialIndex': index,
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
