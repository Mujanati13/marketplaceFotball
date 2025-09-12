import 'package:hive/hive.dart';

part 'conversation.g.dart';

@HiveType(typeId: 1)
class Conversation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<String> participantIds;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? lastMessageContent;

  @HiveField(4)
  final DateTime? lastMessageAt;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final List<ConversationParticipant> participants;

  @HiveField(8)
  final int unreadCount;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.title,
    this.lastMessageContent,
    this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Extract participant IDs from the response structure
    List<String> participantIds = [];
    if (json['user1_id'] != null)
      participantIds.add(json['user1_id'].toString());
    if (json['user2_id'] != null)
      participantIds.add(json['user2_id'].toString());

    // Use participant IDs from participants array if available
    if (json['participants'] != null) {
      final participantsList = json['participants'] as List<dynamic>;
      for (var participant in participantsList) {
        final userId = participant['user_id']?.toString();
        if (userId != null && !participantIds.contains(userId)) {
          participantIds.add(userId);
        }
      }
    }

    return Conversation(
      id: json['id'].toString(),
      participantIds: participantIds,
      title: json['title'] ?? 'Conversation', // Default title if none provided
      lastMessageContent: json['last_message'], // Can be null
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.parse(json['created_at']), // Fallback to created_at
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((p) => ConversationParticipant.fromJson(p))
              .toList() ??
          [],
      unreadCount: json['unread_count'] ?? json['message_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'title': title,
      'last_message': lastMessageContent,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'unread_count': unreadCount,
    };
  }

  String getOtherParticipantName(String currentUserId) {
    if (participants.isEmpty) return 'Unknown User';

    final otherParticipant = participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
    return otherParticipant.fullName;
  }

  String? getOtherParticipantAvatar(String currentUserId) {
    if (participants.isEmpty) return null;

    final otherParticipant = participants.firstWhere(
      (p) => p.userId != currentUserId,
      orElse: () => participants.first,
    );
    return otherParticipant.avatar;
  }
}

@HiveType(typeId: 4)
class ConversationParticipant extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String? avatar;

  @HiveField(4)
  final bool isOnline;

  @HiveField(5)
  final DateTime? lastSeen;

  ConversationParticipant({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    // Handle different API response formats
    final name = json['name'] ?? '';
    final nameParts = name.split(' ');

    return ConversationParticipant(
      userId: json['user_id'].toString(),
      firstName:
          json['first_name'] ??
          (nameParts.isNotEmpty ? nameParts.first : 'Unknown'),
      lastName:
          json['last_name'] ??
          (nameParts.length > 1 ? nameParts.skip(1).join(' ') : 'User'),
      avatar: json['avatar'] ?? json['avatar_url'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
