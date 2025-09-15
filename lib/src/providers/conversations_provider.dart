import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/http_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../core/services/logger_service.dart';

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return HttpService.apiService;
});

// State class for conversations
class ConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Conversations Provider
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ApiService _apiService;

  ConversationsNotifier(this._apiService) : super(const ConversationsState());

  Future<void> loadConversations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      LoggerService.info('Loading conversations...');
      final response = await _apiService.getConversations();

      state = state.copyWith(
        conversations: response.conversations,
        isLoading: false,
      );

      LoggerService.info(
        'Conversations loaded: ${response.conversations.length}',
      );
    } catch (e) {
      LoggerService.error('Failed to load conversations', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Conversation?> createConversation(
    CreateConversationRequest request,
  ) async {
    try {
      LoggerService.info('Creating conversation...');
      final conversation = await _apiService.createConversation(request);

      // Add to current list
      state = state.copyWith(
        conversations: [conversation, ...state.conversations],
        error: null, // Clear any previous errors
      );

      LoggerService.info('Conversation created: ${conversation.id}');
      return conversation;
    } catch (e) {
      // Handle permission errors gracefully without extensive logging
      String errorMessage = 'Failed to create conversation';

      if (e.toString().contains('403') ||
          e.toString().toLowerCase().contains('insufficient permissions')) {
        errorMessage = 'Insufficient permissions to create this conversation';
        LoggerService.info(
          'Permission denied for conversation creation - this is handled gracefully',
        );
      } else {
        LoggerService.error('Failed to create conversation', e);
      }

      state = state.copyWith(error: errorMessage);
      return null;
    }
  }

  Future<Conversation?> getConversation(String id) async {
    try {
      LoggerService.info('Getting conversation: $id');
      final conversation = await _apiService.getConversation(id);

      // Update in current list if exists
      final updatedConversations = state.conversations.map((c) {
        return c.id == id ? conversation : c;
      }).toList();

      state = state.copyWith(conversations: updatedConversations);

      return conversation;
    } catch (e) {
      LoggerService.error('Failed to get conversation', e);
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

// Provider for conversations
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return ConversationsNotifier(apiService);
    });

// State class for messages
class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final String? error;
  final bool isLoadingMore;

  const MessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isLoadingMore = false,
  });

  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    String? error,
    bool? isLoadingMore,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// Messages Provider
class MessagesNotifier extends StateNotifier<MessagesState> {
  final ApiService _apiService;

  MessagesNotifier(this._apiService) : super(const MessagesState());

  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      LoggerService.info('Loading messages for conversation: $conversationId');
      final response = await _apiService.getMessages(conversationId);

      state = state.copyWith(
        messages: response.messages.reversed
            .toList(), // Reverse to show newest at bottom
        isLoading: false,
      );

      LoggerService.info('Messages loaded: ${response.messages.length}');
    } catch (e) {
      LoggerService.error('Failed to load messages', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(
    String conversationId,
    SendMessageRequest request,
  ) async {
    try {
      LoggerService.info('Sending message to conversation: $conversationId');
      final message = await _apiService.sendMessage(conversationId, request);

      // Add to current list
      state = state.copyWith(messages: [...state.messages, message]);

      LoggerService.info('Message sent: ${message.id}');
    } catch (e) {
      LoggerService.error('Failed to send message', e);
      state = state.copyWith(error: e.toString());
    }
  }

  void clearMessages() {
    state = const MessagesState();
  }
}

// Provider for messages
final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>(
  (ref) {
    final apiService = ref.watch(apiServiceProvider);
    return MessagesNotifier(apiService);
  },
);

// Provider for a specific conversation's messages
final conversationMessagesProvider =
    StateNotifierProvider.family<MessagesNotifier, MessagesState, String>((
      ref,
      conversationId,
    ) {
      final apiService = ref.watch(apiServiceProvider);
      final notifier = MessagesNotifier(apiService);

      // Auto-load messages when provider is created
      Future.microtask(() => notifier.loadMessages(conversationId));

      return notifier;
    });
