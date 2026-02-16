import 'package:hive/hive.dart';
import '../models/playlist_source.dart';
import '../models/channel_rating.dart';

class StorageService {
  static const _playlistBoxName = 'playlists';
  static const _ratingsBoxName = 'ratings';

  static Future<Box<PlaylistSource>> get _playlistBox async =>
      Hive.box<PlaylistSource>(_playlistBoxName);

  static Future<Box<ChannelRating>> get _ratingsBox async =>
      Hive.box<ChannelRating>(_ratingsBoxName);

  static Future<void> init() async {
    Hive.registerAdapter(PlaylistTypeAdapter());
    Hive.registerAdapter(PlaylistSourceAdapter());
    Hive.registerAdapter(ChannelRatingAdapter());
    await Hive.openBox<PlaylistSource>(_playlistBoxName);
    await Hive.openBox<ChannelRating>(_ratingsBoxName);
  }

  // Playlist methods

  static Future<List<PlaylistSource>> getAll() async {
    final box = await _playlistBox;
    return box.values.toList();
  }

  static Future<void> add(PlaylistSource source) async {
    final box = await _playlistBox;
    await box.add(source);
  }

  static Future<void> update(PlaylistSource source) async {
    await source.save();
  }

  static Future<void> delete(PlaylistSource source) async {
    await source.delete();
  }

  static Future<void> setActive(PlaylistSource source) async {
    final box = await _playlistBox;
    for (final item in box.values) {
      if (item.isActive) {
        item.isActive = false;
        await item.save();
      }
    }
    source.isActive = true;
    await source.save();
  }

  static Future<PlaylistSource?> getActive() async {
    final box = await _playlistBox;
    try {
      return box.values.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  // Rating methods

  static Future<Map<String, double>> getAllRatings() async {
    final box = await _ratingsBox;
    final map = <String, double>{};
    for (final rating in box.values) {
      map[rating.channelUrl] = rating.rating;
    }
    return map;
  }

  static Future<double?> getRating(String channelUrl) async {
    final box = await _ratingsBox;
    try {
      final rating = box.values.firstWhere((r) => r.channelUrl == channelUrl);
      return rating.rating;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setRating(String channelUrl, double rating) async {
    final box = await _ratingsBox;
    ChannelRating? existing;
    for (final r in box.values) {
      if (r.channelUrl == channelUrl) {
        existing = r;
        break;
      }
    }

    if (existing != null) {
      existing.rating = rating;
      existing.ratedAt = DateTime.now();
      await existing.save();
    } else {
      await box.add(ChannelRating(
        channelUrl: channelUrl,
        rating: rating,
      ));
    }
  }

  static Future<void> removeRating(String channelUrl) async {
    final box = await _ratingsBox;
    final keysToDelete = <dynamic>[];
    for (final entry in box.toMap().entries) {
      if (entry.value.channelUrl == channelUrl) {
        keysToDelete.add(entry.key);
      }
    }
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }
}
