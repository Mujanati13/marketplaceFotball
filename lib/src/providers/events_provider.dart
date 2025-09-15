import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/http_service.dart';
import '../models/event.dart';
import '../core/services/logger_service.dart';

// Provider for API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return HttpService.apiService;
});

// State class for events
class EventsState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const EventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  EventsState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return EventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Events Provider
class EventsNotifier extends StateNotifier<EventsState> {
  final ApiService _apiService;

  EventsNotifier(this._apiService) : super(const EventsState());

  Future<void> loadEvents({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        events: [],
        currentPage: 1,
        hasMore: true,
      );
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      LoggerService.info('Loading events...');
      final response = await _apiService.getEvents(
        page: refresh ? 1 : state.currentPage,
        limit: 20,
      );

      final newEvents = refresh
          ? response.events
          : [...state.events, ...response.events];

      state = state.copyWith(
        events: newEvents,
        isLoading: false,
        hasMore: response.pagination.hasNext,
        currentPage: response.pagination.currentPage + 1,
      );

      LoggerService.info('Events loaded: ${response.events.length}');
    } catch (e) {
      LoggerService.error('Failed to load events', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadEventsByType(
    String eventType, {
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        events: [],
        currentPage: 1,
        hasMore: true,
      );
    } else if (state.isLoading || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      LoggerService.info('Loading events by type: $eventType');
      final response = await _apiService.getEvents(
        page: refresh ? 1 : state.currentPage,
        limit: 20,
        type: eventType,
      );

      final newEvents = refresh
          ? response.events
          : [...state.events, ...response.events];

      state = state.copyWith(
        events: newEvents,
        isLoading: false,
        hasMore: response.pagination.hasNext,
        currentPage: response.pagination.currentPage + 1,
      );

      LoggerService.info('Events loaded by type: ${response.events.length}');
    } catch (e) {
      LoggerService.error('Failed to load events by type', e);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Event?> getEvent(String id) async {
    try {
      LoggerService.info('Getting event: $id');
      final event = await _apiService.getEvent(id);
      LoggerService.info('Event loaded: ${event.title}');
      return event;
    } catch (e) {
      LoggerService.error('Failed to get event', e);
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider for events
final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return EventsNotifier(apiService);
});

// Provider for filtered events by type
final eventsFilterProvider =
    StateNotifierProvider.family<EventsNotifier, EventsState, String?>((
      ref,
      eventType,
    ) {
      final apiService = ref.watch(apiServiceProvider);
      final notifier = EventsNotifier(apiService);

      // Auto-load events when provider is created
      Future.microtask(() {
        if (eventType != null) {
          notifier.loadEventsByType(eventType, refresh: true);
        } else {
          notifier.loadEvents(refresh: true);
        }
      });

      return notifier;
    });
