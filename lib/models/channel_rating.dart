import 'package:hive/hive.dart';

part 'channel_rating.g.dart';

@HiveType(typeId: 2)
class ChannelRating extends HiveObject {
  @HiveField(0)
  String channelUrl;

  @HiveField(1)
  double rating;

  @HiveField(2)
  DateTime ratedAt;

  ChannelRating({
    required this.channelUrl,
    required this.rating,
    DateTime? ratedAt,
  }) : ratedAt = ratedAt ?? DateTime.now();
}
