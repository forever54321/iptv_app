import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_app/models/content_type.dart';

void main() {
  group('classifyContentType', () {
    test('Xtream URL path segments win', () {
      expect(
        classifyContentType(url: 'http://h:80/live/u/p/123.ts'),
        ContentType.live,
      );
      expect(
        classifyContentType(url: 'http://h:80/movie/u/p/123.mp4'),
        ContentType.movie,
      );
      expect(
        classifyContentType(url: 'http://h:80/series/u/p/123.mp4'),
        ContentType.series,
      );
    });

    test('group-title keywords', () {
      expect(
        classifyContentType(url: 'http://h/x.mp4', groupTitle: 'VOD | Action'),
        ContentType.movie,
      );
      expect(
        classifyContentType(url: 'http://h/x', groupTitle: 'TV Shows | Drama'),
        ContentType.series,
      );
      expect(
        classifyContentType(url: 'http://h/x', groupTitle: 'Live | Sports'),
        ContentType.live,
      );
    });

    test('season/episode pattern in title => series', () {
      expect(
        classifyContentType(
            url: 'http://h/x.mkv', title: 'Breaking Bad S01 E02'),
        ContentType.series,
      );
      expect(
        classifyContentType(url: 'http://h/x.mp4', title: 'The Matrix S2E5'),
        ContentType.series,
      );
    });

    test('file extension fallback', () {
      expect(
        classifyContentType(url: 'http://h/stream.m3u8'),
        ContentType.live,
      );
      expect(
        classifyContentType(url: 'http://h/film.mp4?token=abc'),
        ContentType.movie,
      );
    });

    test('defaults to live when unknown', () {
      expect(classifyContentType(url: 'http://h/12345'), ContentType.live);
    });
  });
}
