import 'package:hive/hive.dart';

part 'listing.g.dart';

@HiveType(typeId: 7)
class Listing extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final ListingType type;

  @HiveField(5)
  final double? hourlyRate;

  @HiveField(6)
  final String? location;

  @HiveField(7)
  final List<String>? skills;

  @HiveField(8)
  final String? availability;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @HiveField(12)
  final ListingUser? user;

  @HiveField(13)
  final int viewCount;

  @HiveField(14)
  final int requestCount;

  Listing({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    this.hourlyRate,
    this.location,
    this.skills,
    this.availability,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.viewCount = 0,
    this.requestCount = 0,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ListingType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ListingType.service,
      ),
      hourlyRate: json['price'] != null
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : json['hourly_rate'] != null
          ? double.tryParse(json['hourly_rate'].toString()) ?? 0.0
          : null,
      location: json['location'],
      skills: json['skills']?.cast<String>(),
      availability: json['availability'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      user: json['user'] != null
          ? ListingUser.fromJson(json['user'])
          : (json['owner_name'] != null
                ? ListingUser.fromJson({
                    'id': json['user_id'],
                    'name': json['owner_name'],
                    'email': json['owner_email'],
                    'avatar_url': json['owner_avatar'],
                  })
                : null),
      viewCount: json['view_count'] ?? 0,
      requestCount: json['request_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'hourly_rate': hourlyRate,
      'location': location,
      'skills': skills,
      'availability': availability,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'view_count': viewCount,
      'request_count': requestCount,
    };
  }

  bool get isPlayerListing => type == ListingType.player;
  bool get isCoachListing => type == ListingType.coach;
  bool get isServiceListing => type == ListingType.service;
}

@HiveType(typeId: 8)
enum ListingType {
  @HiveField(0)
  player,
  @HiveField(1)
  coach,
  @HiveField(2)
  service,
}

@HiveType(typeId: 9)
class ListingUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String? avatar;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final double? rating;

  @HiveField(6)
  final int? totalReviews;

  ListingUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.role,
    this.rating,
    this.totalReviews,
  });

  factory ListingUser.fromJson(Map<String, dynamic> json) {
    // Handle both separated first_name/last_name and combined name
    String firstName = json['first_name'] ?? '';
    String lastName = json['last_name'] ?? '';

    if (firstName.isEmpty && lastName.isEmpty && json['name'] != null) {
      final nameParts = (json['name'] as String).split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    }

    return ListingUser(
      id: json['id'].toString(),
      firstName: firstName,
      lastName: lastName,
      avatar: json['avatar'] ?? json['avatar_url'],
      role: json['role'] ?? 'user',
      rating: json['rating']?.toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'role': role,
      'rating': rating,
      'total_reviews': totalReviews,
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}
