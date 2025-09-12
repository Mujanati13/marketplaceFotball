import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/meeting.dart';
import '../core/services/http_service.dart';
import '../core/services/logger_service.dart';
import '../core/services/api_service.dart';

// Meetings state management
class MeetingsNotifier extends StateNotifier<AsyncValue<List<Meeting>>> {
  MeetingsNotifier() : super(const AsyncValue.loading());

  Future<void> loadMeetings({String? status, DateTime? date}) async {
    try {
      state = const AsyncValue.loading();

      final response = await HttpService.apiService.getMeetings(
        status: status,
        date: date?.toIso8601String(),
      );

      state = AsyncValue.data(response.meetings);
      LoggerService.info('Loaded ${response.meetings.length} meetings');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load meetings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createMeeting({
    required String requestId,
    required String coachUserId,
    required String playerUserId,
    required DateTime startAt,
    required DateTime endAt,
    String? locationUri,
    String? notes,
  }) async {
    try {
      await HttpService.apiService.createMeeting(
        CreateMeetingRequest(
          requestId: requestId,
          coachUserId: coachUserId,
          playerUserId: playerUserId,
          startAt: startAt.toIso8601String(),
          endAt: endAt.toIso8601String(),
          locationUri: locationUri,
          notes: notes,
        ),
      );

      LoggerService.info('Meeting created successfully');

      // Reload meetings
      await loadMeetings();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create meeting', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateMeetingStatus(
    String meetingId,
    MeetingStatus status,
  ) async {
    try {
      await HttpService.apiService.updateMeeting(
        meetingId,
        UpdateMeetingRequest(status: status.name),
      );

      LoggerService.info('Meeting status updated to $status');

      // Reload meetings
      await loadMeetings();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update meeting status', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelMeeting(String meetingId) async {
    try {
      await HttpService.apiService.cancelMeeting(meetingId);

      LoggerService.info('Meeting cancelled');

      // Reload meetings
      await loadMeetings();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to cancel meeting', e, stackTrace);
      rethrow;
    }
  }
}

// Upcoming meetings notifier
class UpcomingMeetingsNotifier
    extends StateNotifier<AsyncValue<List<Meeting>>> {
  UpcomingMeetingsNotifier() : super(const AsyncValue.loading());

  Future<void> loadUpcomingMeetings() async {
    try {
      state = const AsyncValue.loading();

      final response = await HttpService.apiService.getMyMeetings(
        status: 'scheduled',
        upcoming: true,
      );

      // Filter for upcoming meetings (additional client-side filtering)
      final now = DateTime.now();
      final upcomingMeetings = response.meetings
          .where((meeting) => meeting.scheduledAt.isAfter(now))
          .toList();

      // Sort by scheduled time
      upcomingMeetings.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      state = AsyncValue.data(upcomingMeetings);
      LoggerService.info('Loaded ${upcomingMeetings.length} upcoming meetings');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load upcoming meetings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Past meetings notifier
class PastMeetingsNotifier extends StateNotifier<AsyncValue<List<Meeting>>> {
  PastMeetingsNotifier() : super(const AsyncValue.loading());

  Future<void> loadPastMeetings() async {
    try {
      state = const AsyncValue.loading();

      final response = await HttpService.apiService.getMyMeetings(
        status: 'completed',
      );

      // Sort by scheduled time (most recent first)
      final pastMeetings = response.meetings.toList();
      pastMeetings.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

      state = AsyncValue.data(pastMeetings);
      LoggerService.info('Loaded ${pastMeetings.length} past meetings');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load past meetings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Requested meetings notifier
class RequestedMeetingsNotifier
    extends StateNotifier<AsyncValue<List<Meeting>>> {
  RequestedMeetingsNotifier() : super(const AsyncValue.loading());

  Future<void> loadRequestedMeetings() async {
    try {
      state = const AsyncValue.loading();

      final response = await HttpService.apiService.getMyMeetings(
        status: 'requested',
      );

      // Sort by creation time (most recent first)
      final requestedMeetings = response.meetings.toList();
      requestedMeetings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncValue.data(requestedMeetings);
      LoggerService.info(
        'Loaded ${requestedMeetings.length} requested meetings',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load requested meetings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Providers
final meetingsProvider =
    StateNotifierProvider<MeetingsNotifier, AsyncValue<List<Meeting>>>(
      (ref) => MeetingsNotifier(),
    );

final upcomingMeetingsProvider =
    StateNotifierProvider<UpcomingMeetingsNotifier, AsyncValue<List<Meeting>>>(
      (ref) => UpcomingMeetingsNotifier(),
    );

final pastMeetingsProvider =
    StateNotifierProvider<PastMeetingsNotifier, AsyncValue<List<Meeting>>>(
      (ref) => PastMeetingsNotifier(),
    );

final requestedMeetingsProvider =
    StateNotifierProvider<RequestedMeetingsNotifier, AsyncValue<List<Meeting>>>(
      (ref) => RequestedMeetingsNotifier(),
    );

// Individual meeting provider
final meetingProvider = FutureProvider.family<Meeting, String>((
  ref,
  meetingId,
) async {
  final response = await HttpService.apiService.getMeeting(meetingId);
  return response;
});
