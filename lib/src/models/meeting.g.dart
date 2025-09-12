// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeetingAdapter extends TypeAdapter<Meeting> {
  @override
  final int typeId = 15;

  @override
  Meeting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Meeting(
      id: fields[0] as String,
      requestId: fields[1] as String,
      customerId: fields[2] as String,
      providerId: fields[3] as String,
      title: fields[4] as String,
      description: fields[5] as String?,
      scheduledAt: fields[6] as DateTime,
      duration: fields[7] as int,
      location: fields[8] as String?,
      meetingLink: fields[9] as String?,
      status: fields[10] as MeetingStatus,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      customer: fields[13] as MeetingCustomer?,
      provider: fields[14] as MeetingProvider?,
      adminNotes: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Meeting obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.requestId)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.providerId)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.scheduledAt)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.meetingLink)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.customer)
      ..writeByte(14)
      ..write(obj.provider)
      ..writeByte(15)
      ..write(obj.adminNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeetingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeetingCustomerAdapter extends TypeAdapter<MeetingCustomer> {
  @override
  final int typeId = 17;

  @override
  MeetingCustomer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeetingCustomer(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      avatar: fields[4] as String?,
      phoneNumber: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MeetingCustomer obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.avatar)
      ..writeByte(5)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeetingCustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeetingProviderAdapter extends TypeAdapter<MeetingProvider> {
  @override
  final int typeId = 18;

  @override
  MeetingProvider read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeetingProvider(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      role: fields[3] as String,
      avatar: fields[4] as String?,
      phoneNumber: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MeetingProvider obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.avatar)
      ..writeByte(5)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeetingProviderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeetingStatusAdapter extends TypeAdapter<MeetingStatus> {
  @override
  final int typeId = 16;

  @override
  MeetingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MeetingStatus.scheduled;
      case 1:
        return MeetingStatus.inProgress;
      case 2:
        return MeetingStatus.completed;
      case 3:
        return MeetingStatus.cancelled;
      default:
        return MeetingStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, MeetingStatus obj) {
    switch (obj) {
      case MeetingStatus.scheduled:
        writer.writeByte(0);
        break;
      case MeetingStatus.inProgress:
        writer.writeByte(1);
        break;
      case MeetingStatus.completed:
        writer.writeByte(2);
        break;
      case MeetingStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeetingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
