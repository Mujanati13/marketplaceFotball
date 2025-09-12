import 'package:hive/hive.dart';

part 'meeting.g.dart';

@HiveType(typeId: 15)
class Meeting extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String requestId;

  @HiveField(2)
  final String customerId;

  @HiveField(3)
  final String providerId;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final DateTime scheduledAt;

  @HiveField(7)
  final int duration;

  @HiveField(8)
  final String? location;

  @HiveField(9)
  final String? meetingLink;

  @HiveField(10)
  final MeetingStatus status;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final MeetingCustomer? customer;

  @HiveField(14)
  final MeetingProvider? provider;

  @HiveField(15)
  final String? adminNotes;

  Meeting({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.providerId,
    required this.title,
    this.description,
    required this.scheduledAt,
    required this.duration,
    this.location,
    this.meetingLink,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
    this.provider,
    this.adminNotes,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'].toString(),
      requestId: json['request_id'].toString(),
      customerId: json['player_user_id'].toString(), // Map from API field
      providerId: json['coach_user_id'].toString(), // Map from API field
      title: json['title'] ?? 'Training Session',
      description: json['description'],
      scheduledAt: DateTime.parse(json['start_at']), // Map from API field
      duration:
          json['duration_minutes'] ?? 60, // Map from API field with default
      location: json['location'],
      meetingLink: json['location_uri'], // Map from API field
      status: MeetingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MeetingStatus.scheduled,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      customer: json['customer'] != null
          ? MeetingCustomer.fromJson(json['customer'])
          : (json['player_name'] != null
                ? MeetingCustomer(
                    id: json['player_user_id'].toString(),
                    firstName: json['player_name'].toString().split(' ').first,
                    lastName:
                        json['player_name'].toString().split(' ').length > 1
                        ? json['player_name']
                              .toString()
                              .split(' ')
                              .sublist(1)
                              .join(' ')
                        : '',
                    email: json['player_email'] ?? '',
                    phoneNumber: json['player_phone'],
                  )
                : null),
      provider: json['provider'] != null
          ? MeetingProvider.fromJson(json['provider'])
          : (json['coach_name'] != null
                ? MeetingProvider(
                    id: json['coach_user_id'].toString(),
                    firstName: json['coach_name'].toString().split(' ').first,
                    lastName:
                        json['coach_name'].toString().split(' ').length > 1
                        ? json['coach_name']
                              .toString()
                              .split(' ')
                              .sublist(1)
                              .join(' ')
                        : '',
                    role: 'coach',
                    phoneNumber: json['coach_phone'],
                  )
                : null),
      adminNotes: json['admin_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'player_user_id': customerId, // Map to API field
      'coach_user_id': providerId, // Map to API field
      'title': title,
      'description': description,
      'start_at': scheduledAt.toIso8601String(), // Map to API field
      'duration_minutes': duration, // Map to API field
      'location': location,
      'location_uri': meetingLink, // Map to API field
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customer': customer?.toJson(),
      'provider': provider?.toJson(),
      'admin_notes': adminNotes,
    };
  }

  DateTime get endTime => scheduledAt.add(Duration(minutes: duration));

  bool get isScheduled => status == MeetingStatus.scheduled;
  bool get isCompleted => status == MeetingStatus.completed;
  bool get isCancelled => status == MeetingStatus.cancelled;
  bool get isInProgress => status == MeetingStatus.inProgress;

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now()) && isScheduled;
  bool get isPast => scheduledAt.isBefore(DateTime.now());
  bool get isToday =>
      scheduledAt.day == DateTime.now().day &&
      scheduledAt.month == DateTime.now().month &&
      scheduledAt.year == DateTime.now().year;
}

@HiveType(typeId: 16)
enum MeetingStatus {
  @HiveField(0)
  scheduled,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
}

@HiveType(typeId: 17)
class MeetingCustomer extends HiveObject {
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

  MeetingCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    this.phoneNumber,
  });

  factory MeetingCustomer.fromJson(Map<String, dynamic> json) {
    return MeetingCustomer(
      id: json['id'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
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

@HiveType(typeId: 18)
class MeetingProvider extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final String? avatar;

  @HiveField(5)
  final String? phoneNumber;

  MeetingProvider({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatar,
    this.phoneNumber,
  });

  factory MeetingProvider.fromJson(Map<String, dynamic> json) {
    return MeetingProvider(
      id: json['id'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: json['role'],
      avatar: json['avatar'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'avatar': avatar,
      'phone_number': phoneNumber,
    };
  }

  String get fullName => '$firstName $lastName';
}

// API Response classes
class MeetingsResponse {
  final List<Meeting> meetings;
  final int total;
  final int page;
  final int limit;

  MeetingsResponse({
    required this.meetings,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory MeetingsResponse.fromJson(Map<String, dynamic> json) {
    return MeetingsResponse(
      meetings: (json['meetings'] as List)
          .map((item) => Meeting.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
    );
  }
}
