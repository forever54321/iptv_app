// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_rating.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelRatingAdapter extends TypeAdapter<ChannelRating> {
  @override
  final int typeId = 2;

  @override
  ChannelRating read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChannelRating(
      channelUrl: fields[0] as String,
      rating: fields[1] as double,
      ratedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChannelRating obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.channelUrl)
      ..writeByte(1)
      ..write(obj.rating)
      ..writeByte(2)
      ..write(obj.ratedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelRatingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
