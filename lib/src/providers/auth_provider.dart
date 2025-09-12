import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/user.dart';
import '../core/services/api_service.dart';
import '../core/services/hive_service.dart';
import '../core/services/http_service.dart';
import '../core/services/socket_service.dart';
import '../core/services/logger_service.dart';

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._apiService) : super(const AuthState()) {
    _initializeAuth();
  }

  final ApiService _apiService;

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = HiveService.getCurrentUser();
      final token = HiveService.getSetting<String>('access_token');

      if (user != null && token != null) {
        // Verify token is still valid by fetching current user
        try {
          final currentUser = await _apiService.getCurrentUser();
          await HiveService.saveCurrentUser(currentUser);
          HttpService.updateAuthToken(token);
          await SocketService.connect();

          state = state.copyWith(
            user: currentUser,
            isAuthenticated: true,
            isLoading: false,
          );
        } catch (e) {
          // Token is invalid, clear auth data
          await _clearAuthData();
          state = state.copyWith(isLoading: false, isAuthenticated: false);
        }
      } else {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
      }
    } catch (e) {
      LoggerService.error('Auth initialization error', e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication',
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.login(
        LoginRequest(email: email, password: password),
      );

      // Save auth data
      await HiveService.saveSetting('access_token', response.accessToken);
      await HiveService.saveSetting('refresh_token', response.refreshToken);
      await HiveService.saveCurrentUser(response.user);

      // Update HTTP service
      HttpService.updateAuthToken(response.accessToken);

      // Connect to socket
      await SocketService.connect();

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );

      LoggerService.info('User logged in successfully: ${response.user.email}');
      return true;
    } catch (e) {
      LoggerService.error('Login error', e);
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.register(
        RegisterRequest(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          role: role,
          phoneNumber: phoneNumber,
        ),
      );

      // Save auth data
      await HiveService.saveSetting('access_token', response.accessToken);
      await HiveService.saveSetting('refresh_token', response.refreshToken);
      await HiveService.saveCurrentUser(response.user);

      // Update HTTP service
      HttpService.updateAuthToken(response.accessToken);

      // Connect to socket
      await SocketService.connect();

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );

      LoggerService.info(
        'User registered successfully: ${response.user.email}',
      );
      return true;
    } catch (e) {
      LoggerService.error('Registration error', e);
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      LoggerService.error('Logout API error', e);
    }

    await _clearAuthData();
    SocketService.disconnect();

    state = const AuthState();
    LoggerService.info('User logged out');
  }

  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final currentUser = await _apiService.getCurrentUser();
      await HiveService.saveCurrentUser(currentUser);

      state = state.copyWith(user: currentUser);
      LoggerService.info('User data refreshed successfully');
    } catch (e) {
      LoggerService.error('Failed to refresh user data', e);
    }
  }

  Future<bool> updateProfile({
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
    if (!state.isAuthenticated) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentUserId = state.user?.id;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final updatedUser = await _apiService.updateProfile(
        currentUserId.toString(),
        UpdateProfileRequest(
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
        ),
      );

      await HiveService.saveCurrentUser(updatedUser);

      state = state.copyWith(user: updatedUser, isLoading: false);

      LoggerService.info('Profile updated successfully');
      return true;
    } catch (e) {
      LoggerService.error('Profile update error', e);
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.forgotPassword(ForgotPasswordRequest(email: email));

      state = state.copyWith(isLoading: false);
      LoggerService.info('Password reset email sent to: $email');
      return true;
    } catch (e) {
      LoggerService.error('Forgot password error', e);
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  Future<bool> resetPassword(String token, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _apiService.resetPassword(
        ResetPasswordRequest(token: token, password: password),
      );

      state = state.copyWith(isLoading: false);
      LoggerService.info('Password reset successfully');
      return true;
    } catch (e) {
      LoggerService.error('Reset password error', e);
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
      return false;
    }
  }

  Future<void> _clearAuthData() async {
    await HiveService.clearCurrentUser();
    await HiveService.deleteSetting('access_token');
    await HiveService.deleteSetting('refresh_token');
    HttpService.removeAuthToken();
  }

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      // Return the specific error message from the server
      return error.message;
    }

    // Handle DioException if it somehow gets through
    if (error is DioException) {
      if (error.response?.statusCode == 409) {
        return 'Email already registered. Please use a different email or try logging in.';
      } else if (error.response?.statusCode == 401) {
        return 'Invalid email or password. Please check your credentials.';
      } else if (error.response?.statusCode == 422) {
        return 'Please check your input and try again.';
      }
    }

    return 'An unexpected error occurred. Please try again.';
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(httpServiceProvider);
  return AuthNotifier(apiService);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
