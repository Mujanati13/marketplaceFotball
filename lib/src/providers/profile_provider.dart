import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../core/services/http_service.dart';
import '../core/services/api_service.dart';
import '../core/services/logger_service.dart';
import 'auth_provider.dart';

// Profile state notifier
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> loadProfile() async {
    try {
      state = const AsyncValue.loading();

      final user = await HttpService.apiService.getCurrentUser();

      state = AsyncValue.data(user.profile);
      LoggerService.info('Loaded profile for current user');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load profile', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? bio,
    String? location,
    String? position,
    int? experience,
    double? hourlyRate,
    List<String>? skills,
    List<String>? certifications,
    String? availability,
  }) async {
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final updateRequest = UpdateProfileRequest(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        bio: bio,
        location: location,
        position: position,
        experience: experience,
        hourlyRate: hourlyRate,
        skills: skills,
        certifications: certifications,
        availability: availability,
      );

      final updatedUser = await HttpService.apiService.updateProfile(
        userId.toString(),
        updateRequest,
      );

      state = AsyncValue.data(updatedUser.profile);
      LoggerService.info('Profile updated successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update profile', e, stackTrace);
      rethrow;
    }
  }

  void clearProfile() {
    state = const AsyncValue.data(null);
  }
}

// Provider
final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>(
      (ref) => ProfileNotifier(ref),
    );
