import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String firstName;

  @HiveField(3)
  final String lastName;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String? phoneNumber;

  @HiveField(6)
  final String? avatar;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final UserProfile? profile;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    this.avatar,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle different response formats - registration vs profile
    String firstName = '';
    String lastName = '';

    if (json['name'] != null) {
      // Registration response format
      final nameParts = json['name'].toString().split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
    } else {
      // Profile response format
      firstName = json['first_name'] ?? '';
      lastName = json['last_name'] ?? '';
    }

    return User(
      id: json['id'].toString(),
      email: json['email'],
      firstName: firstName,
      lastName: lastName,
      role: json['role'],
      phoneNumber: json['phone_number'],
      avatar: json['avatar'],
      isActive:
          json['is_active'] == 1 ||
          json['is_active'] == true ||
          json['status'] == 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.parse(json['created_at']), // Fallback to created_at
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone_number': phoneNumber,
      'avatar': avatar,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';

  bool get isPlayer => role == 'player';
  bool get isCoach => role == 'coach';
  bool get isCustomer => role == 'customer';
  bool get isAdmin => role == 'admin';
}

@HiveType(typeId: 3)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String? bio;

  @HiveField(3)
  final String? location;

  @HiveField(4)
  final String? position;

  @HiveField(5)
  final int? experience;

  @HiveField(6)
  final double? hourlyRate;

  @HiveField(7)
  final List<String>? skills;

  @HiveField(8)
  final List<String>? certifications;

  @HiveField(9)
  final String? availability;

  @HiveField(10)
  final double? rating;

  @HiveField(11)
  final int? totalReviews;

  UserProfile({
    required this.id,
    required this.userId,
    this.bio,
    this.location,
    this.position,
    this.experience,
    this.hourlyRate,
    this.skills,
    this.certifications,
    this.availability,
    this.rating,
    this.totalReviews,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      bio: json['bio'],
      location: json['location'],
      position: json['position'],
      experience: json['experience'],
      hourlyRate: json['hourly_rate']?.toDouble(),
      skills: json['skills']?.cast<String>(),
      certifications: json['certifications']?.cast<String>(),
      availability: json['availability'],
      rating: json['rating']?.toDouble(),
      totalReviews: json['total_reviews'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bio': bio,
      'location': location,
      'position': position,
      'experience': experience,
      'hourly_rate': hourlyRate,
      'skills': skills,
      'certifications': certifications,
      'availability': availability,
      'rating': rating,
      'total_reviews': totalReviews,
    };
  }
}
