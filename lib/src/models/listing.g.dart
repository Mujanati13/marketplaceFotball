// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListingAdapter extends TypeAdapter<Listing> {
  @override
  final int typeId = 7;

  @override
  Listing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Listing(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      type: fields[4] as ListingType,
      hourlyRate: fields[5] as double?,
      location: fields[6] as String?,
      skills: (fields[7] as List?)?.cast<String>(),
      availability: fields[8] as String?,
      isActive: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      user: fields[12] as ListingUser?,
      viewCount: fields[13] as int,
      requestCount: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Listing obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.hourlyRate)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.skills)
      ..writeByte(8)
      ..write(obj.availability)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.user)
      ..writeByte(13)
      ..write(obj.viewCount)
      ..writeByte(14)
      ..write(obj.requestCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListingUserAdapter extends TypeAdapter<ListingUser> {
  @override
  final int typeId = 9;

  @override
  ListingUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListingUser(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      avatar: fields[3] as String?,
      role: fields[4] as String,
      rating: fields[5] as double?,
      totalReviews: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ListingUser obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.totalReviews);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListingTypeAdapter extends TypeAdapter<ListingType> {
  @override
  final int typeId = 8;

  @override
  ListingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ListingType.player;
      case 1:
        return ListingType.coach;
      case 2:
        return ListingType.service;
      default:
        return ListingType.player;
    }
  }

  @override
  void write(BinaryWriter writer, ListingType obj) {
    switch (obj) {
      case ListingType.player:
        writer.writeByte(0);
        break;
      case ListingType.coach:
        writer.writeByte(1);
        break;
      case ListingType.service:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
