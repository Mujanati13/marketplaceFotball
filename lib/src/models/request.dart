import 'package:hive/hive.dart';

part 'request.g.dart';

@HiveType(typeId: 10)
class Request extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String listingId;

  @HiveField(3)
  final String? message;

  @HiveField(4)
  final RequestStatus status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final RequestCustomer? customer;

  @HiveField(8)
  final RequestListing? listing;

  @HiveField(9)
  final String? adminNotes;

  @HiveField(10)
  final DateTime? respondedAt;

  Request({
    required this.id,
    required this.customerId,
    required this.listingId,
    this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.listing,
    this.adminNotes,
    this.respondedAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'].toString(),
      customerId: json['sender_id'].toString(), // Map from API field
      listingId: json['listing_id']?.toString() ?? '',
      message: json['message'],
      status: _mapStatusFromApi(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customer: json['customer'] != null
          ? RequestCustomer.fromJson(json['customer'])
          : null,
      listing: json['listing'] != null
          ? RequestListing.fromJson(json['listing'])
          : null,
      adminNotes: json['admin_notes'],
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': customerId, // Map to API field
      'listing_id': listingId,
      'message': message,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customer': customer?.toJson(),
      'listing': listing?.toJson(),
      'admin_notes': adminNotes,
      'responded_at': respondedAt?.toIso8601String(),
    };
  }

  // Helper method to map API status values to our enum
  static RequestStatus _mapStatusFromApi(String? apiStatus) {
    switch (apiStatus) {
      case 'accepted':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      case 'pending':
        return RequestStatus.pending;
      case 'cancelled':
        return RequestStatus.cancelled;
      case 'completed':
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }

  bool get isPending => status == RequestStatus.pending;
  bool get isApproved => status == RequestStatus.approved;
  bool get isRejected => status == RequestStatus.rejected;
  bool get isCancelled => status == RequestStatus.cancelled;
  bool get isCompleted => status == RequestStatus.completed;
}

@HiveType(typeId: 11)
enum RequestStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
  @HiveField(3)
  cancelled,
  @HiveField(4)
  completed,
}

@HiveType(typeId: 12)
class RequestCustomer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? avatar;

  @HiveField(5)
  final String? phoneNumber;

  RequestCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.phoneNumber,
  });

  factory RequestCustomer.fromJson(Map<String, dynamic> json) {
    return RequestCustomer(
      id: json['id'].toString(),
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatar,
      'phone_number': phoneNumber,
    };
  }

  String get fullName => '$firstName $lastName';
}

@HiveType(typeId: 13)
class RequestListing extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String? location;

  @HiveField(4)
  final double? hourlyRate;

  @HiveField(5)
  final RequestListingUser? user;

  RequestListing({
    required this.id,
    required this.title,
    required this.type,
    this.location,
    this.hourlyRate,
    this.user,
  });

  factory RequestListing.fromJson(Map<String, dynamic> json) {
    return RequestListing(
      id: json['id'].toString(),
      title: json['title'],
      type: json['type'],
      location: json['location'],
      hourlyRate: json['hourly_rate']?.toDouble(),
      user: json['user'] != null
          ? RequestListingUser.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'location': location,
      'hourly_rate': hourlyRate,
      'user': user?.toJson(),
    };
  }
}

@HiveType(typeId: 14)
class RequestListingUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String? avatar;

  RequestListingUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  factory RequestListingUser.fromJson(Map<String, dynamic> json) {
    return RequestListingUser(
      id: json['id'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
    };
  }

  String get fullName => '$firstName $lastName';
}

// Response wrapper for single request API calls
class RequestResponse {
  final Request request;

  RequestResponse({required this.request});

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    return RequestResponse(request: Request.fromJson(json['request']));
  }
}

// Response wrapper for update request API calls
class UpdateRequestResponse {
  final String message;
  final Request request;

  UpdateRequestResponse({required this.message, required this.request});

  factory UpdateRequestResponse.fromJson(Map<String, dynamic> json) {
    return UpdateRequestResponse(
      message: json['message'],
      request: Request.fromJson(json['request']),
    );
  }
}
