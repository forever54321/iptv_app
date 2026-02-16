import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

class RatingsNotifier extends AsyncNotifier<Map<String, double>> {
  @override
  Future<Map<String, double>> build() async {
    return StorageService.getAllRatings();
  }

  Future<void> setRating(String channelUrl, double rating) async {
    await StorageService.setRating(channelUrl, rating);
    ref.invalidateSelf();
  }

  Future<void> removeRating(String channelUrl) async {
    await StorageService.removeRating(channelUrl);
    ref.invalidateSelf();
  }
}

final ratingsProvider =
    AsyncNotifierProvider<RatingsNotifier, Map<String, double>>(
  RatingsNotifier.new,
);

final channelRatingProvider = Provider.family<double?, String>((ref, url) {
  final ratings = ref.watch(ratingsProvider).valueOrNull;
  return ratings?[url];
});
