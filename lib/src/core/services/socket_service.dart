import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'hive_service.dart';
import 'logger_service.dart';
import '../../models/message.dart';
import '../../models/conversation.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  // Stream controllers for real-time events
  static final _messageController = StreamController<Message>.broadcast();
  static final _conversationController =
      StreamController<Conversation>.broadcast();
  static final _typingController = StreamController<TypingEvent>.broadcast();
  static final _onlineStatusController =
      StreamController<OnlineStatusEvent>.broadcast();

  // Getters for streams
  static Stream<Message> get messageStream => _messageController.stream;
  static Stream<Conversation> get conversationStream =>
      _conversationController.stream;
  static Stream<TypingEvent> get typingStream => _typingController.stream;
  static Stream<OnlineStatusEvent> get onlineStatusStream =>
      _onlineStatusController.stream;

  static bool get isConnected => _isConnected;

  static Future<void> connect() async {
    if (_socket?.connected == true) {
      return;
    }

    final token = HiveService.getSetting<String>('access_token');
    if (token == null) {
      LoggerService.error('Cannot connect to socket: No auth token');
      return;
    }

    try {
      // ✅ ATTEMPT 2: Simplified configuration to avoid port parsing issues
      final baseUrl = 'https://footbalmarketplace.albech.me';
      
      _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['polling']) // Polling only to avoid websocket upgrade issues
            .setAuth({'token': token})
            .disableAutoConnect()
            .enableForceNew()
            .setTimeout(20000)
            .enableReconnection()
            .setReconnectionAttempts(3)
            .setReconnectionDelay(2000)
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();

      LoggerService.info('🔌 Socket connecting to $baseUrl');
      LoggerService.info('✅ Using socket_io_client 3.1.2 with polling-only transport');
    } catch (e) {
      LoggerService.error('❌ Socket connection failed', e);
      _isConnected = false;
    }
  }

  static void disconnect() {
    if (_socket?.connected == true) {
      _socket!.disconnect();
      LoggerService.info('Socket disconnected');
    }
    _isConnected = false;
  }

  static void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      LoggerService.info(
        '✅ Socket connected successfully to ${AppConfig.socketUrl}',
      );
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      LoggerService.info('🔌 Socket disconnected. Reason: $reason');
    });

    _socket!.onError((error) {
      _isConnected = false;
      LoggerService.error('❌ Socket error', error);
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      LoggerService.error('❌ Socket connection error', error);
    });

    // Authentication events
    _socket!.on('connect_error', (error) {
      LoggerService.error('🔐 Socket authentication failed', error);
    });

    // Chat events
    _socket!.on('new_message', (data) {
      try {
        final message = Message.fromJson(data);
        _messageController.add(message);
        LoggerService.debug('Received new message: ${message.id}');
      } catch (e) {
        LoggerService.error('Error parsing new message', e);
      }
    });

    _socket!.on('message_read', (data) {
      try {
        final messageId = data['message_id'].toString();
        LoggerService.debug('Message marked as read: $messageId');
        // Handle message read status update
      } catch (e) {
        LoggerService.error('Error parsing message read event', e);
      }
    });

    _socket!.on('conversation_updated', (data) {
      try {
        final conversation = Conversation.fromJson(data);
        _conversationController.add(conversation);
        LoggerService.debug('Conversation updated: ${conversation.id}');
      } catch (e) {
        LoggerService.error('Error parsing conversation update', e);
      }
    });

    _socket!.on('user_typing', (data) {
      try {
        final typingEvent = TypingEvent.fromJson(data);
        _typingController.add(typingEvent);
        LoggerService.debug('User typing: ${typingEvent.userId}');
      } catch (e) {
        LoggerService.error('Error parsing typing event', e);
      }
    });

    _socket!.on('user_online', (data) {
      try {
        final onlineEvent = OnlineStatusEvent.fromJson(data);
        _onlineStatusController.add(onlineEvent);
        LoggerService.debug(
          'User online status: ${onlineEvent.userId} - ${onlineEvent.isOnline}',
        );
      } catch (e) {
        LoggerService.error('Error parsing online status event', e);
      }
    });
  }

  // Emit events
  static void joinConversation(String conversationId) {
    if (_socket?.connected == true) {
      _socket!.emit('join_conversation', {'conversation_id': conversationId});
      LoggerService.debug('Joined conversation: $conversationId');
    }
  }

  static void leaveConversation(String conversationId) {
    if (_socket?.connected == true) {
      _socket!.emit('leave_conversation', {'conversation_id': conversationId});
      LoggerService.debug('Left conversation: $conversationId');
    }
  }

  static void sendMessage({
    required String conversationId,
    required String content,
    String type = 'text',
    String? attachmentUrl,
  }) {
    if (_socket?.connected == true) {
      _socket!.emit('send_message', {
        'conversation_id': conversationId,
        'content': content,
        'type': type,
        'attachment_url': attachmentUrl,
      });
      LoggerService.debug('Message sent to conversation: $conversationId');
    }
  }

  static void startTyping(String conversationId) {
    if (_socket?.connected == true) {
      _socket!.emit('start_typing', {'conversation_id': conversationId});
    }
  }

  static void stopTyping(String conversationId) {
    if (_socket?.connected == true) {
      _socket!.emit('stop_typing', {'conversation_id': conversationId});
    }
  }

  static void markAsRead(String conversationId) {
    if (_socket?.connected == true) {
      _socket!.emit('mark_read', {'conversation_id': conversationId});
    }
  }

  static void updateOnlineStatus() {
    if (_socket?.connected == true) {
      _socket!.emit('update_online_status');
    }
  }

  // Cleanup
  static void dispose() {
    disconnect();
    _messageController.close();
    _conversationController.close();
    _typingController.close();
    _onlineStatusController.close();
    _socket?.dispose();
    _socket = null;
  }
}

// Event models
class TypingEvent {
  final String userId;
  final String conversationId;
  final String userName;
  final bool isTyping;

  TypingEvent({
    required this.userId,
    required this.conversationId,
    required this.userName,
    required this.isTyping,
  });

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      userId: json['user_id'].toString(),
      conversationId: json['conversation_id'].toString(),
      userName: json['user_name'],
      isTyping: json['is_typing'] ?? false,
    );
  }
}

class OnlineStatusEvent {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;

  OnlineStatusEvent({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
  });

  factory OnlineStatusEvent.fromJson(Map<String, dynamic> json) {
    return OnlineStatusEvent(
      userId: json['user_id'].toString(),
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
    );
  }
}

// Providers
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

final messageStreamProvider = StreamProvider<Message>((ref) {
  return SocketService.messageStream;
});

final conversationStreamProvider = StreamProvider<Conversation>((ref) {
  return SocketService.conversationStream;
});

final typingStreamProvider = StreamProvider<TypingEvent>((ref) {
  return SocketService.typingStream;
});

final onlineStatusStreamProvider = StreamProvider<OnlineStatusEvent>((ref) {
  return SocketService.onlineStatusStream;
});
