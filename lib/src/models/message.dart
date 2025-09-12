import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 2)
class Message extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final MessageType type;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final MessageSender sender;

  @HiveField(7)
  final bool isRead;

  @HiveField(8)
  final String? attachmentUrl;

  @HiveField(9)
  final String? attachmentType;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.sender,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      conversationId: json['conversation_id'].toString(),
      senderId: json['sender_id'].toString(),
      content: json['content'],
      type: MessageType.values.firstWhere(
        (t) => t.name == (json['type'] ?? json['message_type']),
        orElse: () => MessageType.text,
      ),
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'] != null
          ? MessageSender.fromJson(json['sender'])
          : MessageSender(
              id: json['sender_id'].toString(),
              firstName: json['sender_first_name'] ?? 'Unknown',
              lastName: json['sender_last_name'] ?? 'User',
              avatar: json['sender_avatar'],
            ),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'sender': sender.toJson(),
      'is_read': isRead,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };
  }

  bool get isMine => senderId == sender.id;
  bool get hasAttachment => attachmentUrl != null;
  bool get isImage => attachmentType?.startsWith('image/') == true;
  bool get isVideo => attachmentType?.startsWith('video/') == true;
  bool get isAudio => attachmentType?.startsWith('audio/') == true;
}

@HiveType(typeId: 5)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  video,
  @HiveField(3)
  audio,
  @HiveField(4)
  file,
  @HiveField(5)
  system,
}

@HiveType(typeId: 6)
class MessageSender extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String? avatar;

  MessageSender({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
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
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}
