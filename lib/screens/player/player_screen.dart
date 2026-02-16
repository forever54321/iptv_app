import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../providers/player_provider.dart';
import '../../providers/rating_provider.dart';
import '../../widgets/star_rating.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final int initialChannelIndex;
  const PlayerScreen({super.key, required this.initialChannelIndex});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final VideoController _videoController;
  bool _showOverlay = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(playerProvider.notifier);
    _videoController = VideoController(notifier.player);
    Future.microtask(() {
      notifier.playChannel(widget.initialChannelIndex);
    });
    // Force landscape for video playback on iOS
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    ref.read(playerProvider.notifier).stop();
    // Restore orientations when leaving player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _goBack() async {
    await ref.read(playerProvider.notifier).stop();
    if (mounted) context.go('/channels');
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  void _showRatingSheet() {
    _hideTimer?.cancel();
    final notifier = ref.read(playerProvider.notifier);
    final channel = notifier.currentChannel;
    if (channel == null) return;

    final currentRating =
        ref.read(channelRatingProvider(channel.url)) ?? 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        double tempRating = currentRating;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rate ${channel.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    StarRating(
                      rating: tempRating,
                      size: 40,
                      onRatingChanged: (rating) {
                        setSheetState(() => tempRating = rating);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tempRating > 0
                          ? '${tempRating.toInt()} / 5'
                          : 'Tap a star to rate',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (currentRating > 0)
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(ratingsProvider.notifier)
                                  .removeRating(channel.url);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Remove Rating'),
                          ),
                        FilledButton(
                          onPressed: tempRating > 0
                              ? () {
                                  ref
                                      .read(ratingsProvider.notifier)
                                      .setRating(channel.url, tempRating);
                                  Navigator.pop(ctx);
                                }
                              : null,
                          child: const Text('Save Rating'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _startHideTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerProvider);
    final notifier = ref.read(playerProvider.notifier);
    final channel = notifier.currentChannel;
    final rating = channel != null
        ? ref.watch(channelRatingProvider(channel.url))
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() => _showOverlay = !_showOverlay);
          if (_showOverlay) _startHideTimer();
        },
        child: Stack(
          children: [
            // Video
            Positioned.fill(
              child: Video(
                controller: _videoController,
                controls: NoVideoControls,
              ),
            ),
            // Overlay controls
            if (_showOverlay) ...[
              // Top bar: back + channel info + rating
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: _goBack,
                          ),
                          const SizedBox(width: 8),
                          if (channel != null) ...[
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    channel.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (channel.groupTitle != null)
                                    Text(
                                      channel.groupTitle!,
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          // Rating display + tap to rate
                          GestureDetector(
                            onTap: _showRatingSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    rating != null
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating != null
                                        ? rating.toStringAsFixed(0)
                                        : 'Rate',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous,
                                color: Colors.white, size: 36),
                            onPressed: () => notifier.previousChannel(),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: Icon(
                              state.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 56,
                            ),
                            onPressed: () => notifier.playPause(),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            icon: const Icon(Icons.skip_next,
                                color: Colors.white, size: 36),
                            onPressed: () => notifier.nextChannel(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
