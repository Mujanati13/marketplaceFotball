// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequestAdapter extends TypeAdapter<Request> {
  @override
  final int typeId = 10;

  @override
  Request read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Request(
      id: fields[0] as String,
      customerId: fields[1] as String,
      listingId: fields[2] as String,
      message: fields[3] as String?,
      status: fields[4] as RequestStatus,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      customer: fields[7] as RequestCustomer?,
      listing: fields[8] as RequestListing?,
      adminNotes: fields[9] as String?,
      respondedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Request obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.listingId)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.customer)
      ..writeByte(8)
      ..write(obj.listing)
      ..writeByte(9)
      ..write(obj.adminNotes)
      ..writeByte(10)
      ..write(obj.respondedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestCustomerAdapter extends TypeAdapter<RequestCustomer> {
  @override
  final int typeId = 12;

  @override
  RequestCustomer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequestCustomer(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      avatar: fields[4] as String?,
      phoneNumber: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RequestCustomer obj) {
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
      other is RequestCustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestListingAdapter extends TypeAdapter<RequestListing> {
  @override
  final int typeId = 13;

  @override
  RequestListing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequestListing(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as String,
      location: fields[3] as String?,
      hourlyRate: fields[4] as double?,
      user: fields[5] as RequestListingUser?,
    );
  }

  @override
  void write(BinaryWriter writer, RequestListing obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.hourlyRate)
      ..writeByte(5)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestListingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestListingUserAdapter extends TypeAdapter<RequestListingUser> {
  @override
  final int typeId = 14;

  @override
  RequestListingUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequestListingUser(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      avatar: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RequestListingUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.avatar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestListingUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequestStatusAdapter extends TypeAdapter<RequestStatus> {
  @override
  final int typeId = 11;

  @override
  RequestStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RequestStatus.pending;
      case 1:
        return RequestStatus.approved;
      case 2:
        return RequestStatus.rejected;
      case 3:
        return RequestStatus.cancelled;
      case 4:
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RequestStatus obj) {
    switch (obj) {
      case RequestStatus.pending:
        writer.writeByte(0);
        break;
      case RequestStatus.approved:
        writer.writeByte(1);
        break;
      case RequestStatus.rejected:
        writer.writeByte(2);
        break;
      case RequestStatus.cancelled:
        writer.writeByte(3);
        break;
      case RequestStatus.completed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
