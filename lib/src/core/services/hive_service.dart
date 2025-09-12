import 'package:hive_flutter/hive_flutter.dart';

import '../../models/user.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';
import '../config/app_config.dart';

class HiveService {
  static const String _userBoxName = 'user_box';
  static const String _chatBoxName = 'chat_box';
  static const String _settingsBoxName = 'settings_box';

  static late Box<User> _userBox;
  static late Box<dynamic> _chatBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ConversationAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageAdapter());
    }

    // Open boxes
    _userBox = await Hive.openBox<User>(_userBoxName);
    _chatBox = await Hive.openBox(_chatBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // User storage
  static User? getCurrentUser() {
    return _userBox.get(AppConfig.userDataKey);
  }

  static Future<void> saveCurrentUser(User user) async {
    await _userBox.put(AppConfig.userDataKey, user);
  }

  static Future<void> clearCurrentUser() async {
    await _userBox.delete(AppConfig.userDataKey);
  }

  // Chat storage
  static List<Conversation> getCachedConversations() {
    final conversations = _chatBox.get(
      'conversations',
      defaultValue: <Conversation>[],
    );
    return List<Conversation>.from(conversations);
  }

  static Future<void> saveCachedConversations(
    List<Conversation> conversations,
  ) async {
    await _chatBox.put('conversations', conversations);
  }

  static List<Message> getCachedMessages(String conversationId) {
    final messages = _chatBox.get(
      'messages_$conversationId',
      defaultValue: <Message>[],
    );
    return List<Message>.from(messages);
  }

  static Future<void> saveCachedMessages(
    String conversationId,
    List<Message> messages,
  ) async {
    await _chatBox.put('messages_$conversationId', messages);
  }

  static Future<void> addCachedMessage(
    String conversationId,
    Message message,
  ) async {
    final messages = getCachedMessages(conversationId);
    messages.add(message);
    await saveCachedMessages(conversationId, messages);
  }

  // Settings storage
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> saveSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _userBox.clear();
    await _chatBox.clear();
    await _settingsBox.clear();
  }

  // Close boxes
  static Future<void> close() async {
    await _userBox.close();
    await _chatBox.close();
    await _settingsBox.close();
  }
}
