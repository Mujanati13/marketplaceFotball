// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 1;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      id: fields[0] as String,
      participantIds: (fields[1] as List).cast<String>(),
      title: fields[2] as String,
      lastMessageContent: fields[3] as String?,
      lastMessageAt: fields[4] as DateTime?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      participants: (fields[7] as List).cast<ConversationParticipant>(),
      unreadCount: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.participantIds)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.lastMessageContent)
      ..writeByte(4)
      ..write(obj.lastMessageAt)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.participants)
      ..writeByte(8)
      ..write(obj.unreadCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationParticipantAdapter
    extends TypeAdapter<ConversationParticipant> {
  @override
  final int typeId = 4;

  @override
  ConversationParticipant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationParticipant(
      userId: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      avatar: fields[3] as String?,
      isOnline: fields[4] as bool,
      lastSeen: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationParticipant obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.isOnline)
      ..writeByte(5)
      ..write(obj.lastSeen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationParticipantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
