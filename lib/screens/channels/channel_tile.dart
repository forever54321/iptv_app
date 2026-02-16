import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/m3u_entry.dart';
import '../../providers/rating_provider.dart';
import '../../widgets/star_rating.dart';

class ChannelTile extends ConsumerWidget {
  final M3uEntry channel;
  final VoidCallback onTap;

  const ChannelTile({
    super.key,
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = ref.watch(channelRatingProvider(channel.url));

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildLogo(),
              ),
            ),
            if (rating != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: StarRating(rating: rating, size: 14),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.black26,
              child: Text(
                channel.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (channel.tvgLogo != null && channel.tvgLogo!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: channel.tvgLogo!,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Icon(Icons.live_tv, size: 40),
        errorWidget: (_, __, ___) => const Icon(Icons.live_tv, size: 40),
      );
    }
    return const Icon(Icons.live_tv, size: 40);
  }
}
