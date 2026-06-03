import 'package:flutter/material.dart';

/// The high-level kind of media an entry represents.
enum ContentType { live, movie, series }

extension ContentTypeDisplay on ContentType {
  String get label {
    switch (this) {
      case ContentType.live:
        return 'Live TV';
      case ContentType.movie:
        return 'Movies';
      case ContentType.series:
        return 'TV Shows';
    }
  }

  IconData get icon {
    switch (this) {
      case ContentType.live:
        return Icons.live_tv;
      case ContentType.movie:
        return Icons.movie;
      case ContentType.series:
        return Icons.tv;
    }
  }
}

/// Classifies an M3U entry into [ContentType] using a series of heuristics,
/// from strongest to weakest signal. IPTV playlists rarely tag content type
/// explicitly, so we infer it from the stream URL, group title, and name.
ContentType classifyContentType({
  required String url,
  String? groupTitle,
  String? title,
}) {
  final u = url.toLowerCase();
  final g = (groupTitle ?? '').toLowerCase();
  final t = (title ?? '').toLowerCase();

  // 1. Strongest signal: Xtream Codes URL path segments.
  if (u.contains('/series/')) return ContentType.series;
  if (u.contains('/movie/') ||
      u.contains('/movies/') ||
      u.contains('/vod/')) {
    return ContentType.movie;
  }
  if (u.contains('/live/')) return ContentType.live;

  // 2. Group-title keywords.
  bool hasAny(String s, List<String> keys) => keys.any(s.contains);
  if (hasAny(g, ['series', 'tv show', 'tv shows', 'staffel', 'temporada'])) {
    return ContentType.series;
  }
  if (hasAny(g, ['movie', 'movies', 'vod', 'film', 'cinema', 'kino'])) {
    return ContentType.movie;
  }
  if (hasAny(g, ['live', 'channel', 'channels'])) return ContentType.live;

  // 3. Season/episode pattern in the title (e.g. "Show S01 E02") => series.
  if (RegExp(r's\d{1,2}\s?[ex]\d{1,2}', caseSensitive: false).hasMatch(t)) {
    return ContentType.series;
  }

  // 4. File extension. VOD container formats => movie; stream formats => live.
  final ext = _extensionOf(u);
  const vodExt = {'mp4', 'mkv', 'avi', 'mov', 'm4v', 'flv', 'wmv', 'webm'};
  const liveExt = {'ts', 'm3u8', 'mpd'};
  if (vodExt.contains(ext)) return ContentType.movie;
  if (liveExt.contains(ext)) return ContentType.live;

  // Default: treat anything unrecognized as live.
  return ContentType.live;
}

String _extensionOf(String url) {
  var s = url;
  final q = s.indexOf('?');
  if (q != -1) s = s.substring(0, q);
  final slash = s.lastIndexOf('/');
  final dot = s.lastIndexOf('.');
  if (dot != -1 && dot > slash) return s.substring(dot + 1);
  return '';
}
