import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/request.dart';
import '../core/services/http_service.dart';
import '../core/services/logger_service.dart';

// Sent requests provider
class SentRequestsNotifier extends StateNotifier<AsyncValue<List<Request>>> {
  SentRequestsNotifier() : super(const AsyncValue.loading());

  Future<void> loadSentRequests() async {
    try {
      state = const AsyncValue.loading();

      final response = await HttpService.apiService.getMySentRequests();

      state = AsyncValue.data(response.requests);
      LoggerService.info('Loaded ${response.requests.length} sent requests');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load sent requests', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Helper method to get current user ID (this should be implemented based on your auth system)
  String getCurrentUserId() {
    // This is a placeholder - you'll need to implement this based on your auth provider
    return '';
  }
}

// Received requests provider
class ReceivedRequestsNotifier
    extends StateNotifier<AsyncValue<List<Request>>> {
  ReceivedRequestsNotifier() : super(const AsyncValue.loading());

  Future<void> loadReceivedRequests() async {
    try {
      state = const AsyncValue.loading();

      final response = await HttpService.apiService.getMyReceivedRequests();

      state = AsyncValue.data(response.requests);
      LoggerService.info(
        'Loaded ${response.requests.length} received requests',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load received requests', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Helper method to get current user ID
  String getCurrentUserId() {
    // This is a placeholder - you'll need to implement this based on your auth provider
    return '';
  }
}

// Current request provider
class CurrentRequestNotifier extends StateNotifier<AsyncValue<Request?>> {
  CurrentRequestNotifier() : super(const AsyncValue.data(null));

  Future<void> loadRequest(String requestId) async {
    try {
      state = const AsyncValue.loading();

      final response = await HttpService.apiService.getRequest(requestId);

      state = AsyncValue.data(response.request);
      LoggerService.info('Loaded request: $requestId');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load request', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateRequestStatus(
    String requestId,
    String status, [
    String? adminNotes,
  ]) async {
    try {
      // Map mobile status values to backend status values
      String backendStatus;
      switch (status) {
        case 'approved':
          backendStatus = 'approved';
          break;
        case 'rejected':
          backendStatus = 'rejected';
          break;
        default:
          backendStatus = status; // For cancelled, pending, completed
      }

      final requestBody = <String, dynamic>{'status': backendStatus};

      // Note: Current backend /status endpoint doesn't support adminNotes
      // TODO: Add support for admin notes in backend if needed

      final response = await HttpService.apiService.updateRequestStatus(
        requestId,
        requestBody,
      );

      state = AsyncValue.data(response.request);
      LoggerService.info(
        'Updated request status: $requestId -> $backendStatus',
      );
      LoggerService.info('Response message: ${response.message}');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update request status', e, stackTrace);
      rethrow;
    }
  }

  void clearRequest() {
    state = const AsyncValue.data(null);
  }
}

// Providers
final sentRequestsProvider =
    StateNotifierProvider<SentRequestsNotifier, AsyncValue<List<Request>>>(
      (ref) => SentRequestsNotifier(),
    );

final receivedRequestsProvider =
    StateNotifierProvider<ReceivedRequestsNotifier, AsyncValue<List<Request>>>(
      (ref) => ReceivedRequestsNotifier(),
    );

final currentRequestProvider =
    StateNotifierProvider<CurrentRequestNotifier, AsyncValue<Request?>>(
      (ref) => CurrentRequestNotifier(),
    );
