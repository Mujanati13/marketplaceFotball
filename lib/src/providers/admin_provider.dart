import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../core/services/http_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return HttpService.apiService;
});

// Dashboard Statistics Model
class DashboardStats {
  final int totalUsers;
  final int totalListings;
  final int totalRequests;
  final int totalMeetings;
  final int activeUsers;
  final int pendingRequests;
  final List<ActivityLog> recentActivity;

  const DashboardStats({
    required this.totalUsers,
    required this.totalListings,
    required this.totalRequests,
    required this.totalMeetings,
    required this.activeUsers,
    required this.pendingRequests,
    required this.recentActivity,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalListings: json['totalListings'] ?? 0,
      totalRequests: json['totalRequests'] ?? 0,
      totalMeetings: json['totalMeetings'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      recentActivity:
          (json['recentActivity'] as List<dynamic>?)
              ?.map((item) => ActivityLog.fromJson(item))
              .toList() ??
          [],
    );
  }
}

// Activity Log Model
class ActivityLog {
  final String id;
  final String action;
  final String description;
  final String userId;
  final String? userName;
  final DateTime createdAt;

  const ActivityLog({
    required this.id,
    required this.action,
    required this.description,
    required this.userId,
    this.userName,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'].toString(),
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'].toString(),
      userName: json['userName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Dashboard State
class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;

  const DashboardState({this.stats, this.isLoading = false, this.error});

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Dashboard Provider
class DashboardNotifier extends StateNotifier<DashboardState> {
  final ApiService _apiService;

  DashboardNotifier(this._apiService) : super(const DashboardState());

  Future<void> loadDashboardStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getAdminStats();

      final stats = DashboardStats(
        totalUsers: response.totalUsers,
        totalListings: response.totalListings,
        totalRequests: response.totalRequests,
        totalMeetings: response.totalMeetings,
        activeUsers: response.activeUsers,
        pendingRequests: response.pendingRequests,
        recentActivity: response.recentActivity.map((item) {
          return ActivityLog(
            id: item['id']?.toString() ?? '',
            action: item['action']?.toString() ?? '',
            description: item['description']?.toString() ?? '',
            userId: item['userId']?.toString() ?? '',
            userName: item['userName']?.toString() ?? 'Unknown',
            createdAt:
                DateTime.tryParse(item['created_at']?.toString() ?? '') ??
                DateTime.now(),
          );
        }).toList(),
      );

      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshStats() async {
    await loadDashboardStats();
  }
}

// Dashboard Provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return DashboardNotifier(apiService);
    });

// Users Management State
class UsersManagementState {
  final List<AdminUser> users;
  final bool isLoading;
  final String? error;

  const UsersManagementState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UsersManagementState copyWith({
    List<AdminUser>? users,
    bool? isLoading,
    String? error,
  }) {
    return UsersManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Admin User Model
class AdminUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
    );
  }
}

// Users Management Provider
class UsersManagementNotifier extends StateNotifier<UsersManagementState> {
  // ignore: unused_field
  final Ref _ref;

  UsersManagementNotifier(this._ref) : super(const UsersManagementState());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final users = [
        AdminUser(
          id: '1',
          email: 'john.doe@example.com',
          name: 'John Doe',
          role: 'player',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AdminUser(
          id: '2',
          email: 'jane.smith@example.com',
          name: 'Jane Smith',
          role: 'coach',
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AdminUser(
          id: '3',
          email: 'mike.johnson@example.com',
          name: 'Mike Johnson',
          role: 'player',
          status: 'inactive',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          lastLoginAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUserStatus(String userId, String newStatus) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return AdminUser(
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            status: newStatus,
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt,
          );
        }
        return user;
      }).toList();

      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Admin Listing Model
class AdminListing {
  final String id;
  final String title;
  final String description;
  final String type;
  final double price;
  final String currency;
  final String? position;
  final String? experienceLevel;
  final String? location;
  final String status;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;
  final String userEmail;
  final String userName;

  const AdminListing({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.price,
    required this.currency,
    this.position,
    this.experienceLevel,
    this.location,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
    required this.userEmail,
    required this.userName,
  });

  factory AdminListing.fromJson(Map<String, dynamic> json) {
    return AdminListing(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'USD',
      position: json['position'],
      experienceLevel: json['experience_level'],
      location: json['location'],
      status: json['status'] ?? '',
      isActive: json['is_active'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      userEmail: json['user_email'] ?? '',
      userName: json['user_name'] ?? '',
    );
  }
}

// Admin Meeting Model
class AdminMeeting {
  final String id;
  final String? title;
  final String? description;
  final String meetingType;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final String? location;
  final String? locationUri;
  final int durationMinutes;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coachEmail;
  final String? coachName;
  final String? playerEmail;
  final String? playerName;
  final String? createdByEmail;
  final String? createdByName;
  final String? requestId;
  final String? requestMessage;

  const AdminMeeting({
    required this.id,
    this.title,
    this.description,
    required this.meetingType,
    required this.status,
    required this.startAt,
    required this.endAt,
    this.location,
    this.locationUri,
    required this.durationMinutes,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.coachEmail,
    this.coachName,
    this.playerEmail,
    this.playerName,
    this.createdByEmail,
    this.createdByName,
    this.requestId,
    this.requestMessage,
  });

  factory AdminMeeting.fromJson(Map<String, dynamic> json) {
    return AdminMeeting(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      meetingType: json['meeting_type'] ?? '',
      status: json['status'] ?? '',
      startAt: DateTime.parse(json['start_at']),
      endAt: DateTime.parse(json['end_at']),
      location: json['location'],
      locationUri: json['location_uri'],
      durationMinutes: json['duration_minutes'] ?? 0,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      coachEmail: json['coach_email'],
      coachName: json['coach_name'],
      playerEmail: json['player_email'],
      playerName: json['player_name'],
      createdByEmail: json['created_by_email'],
      createdByName: json['created_by_name'],
      requestId: json['request_id']?.toString(),
      requestMessage: json['request_message'],
    );
  }
}

// Admin Listings State
class AdminListingsState {
  final List<AdminListing> listings;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const AdminListingsState({
    this.listings = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 0,
    this.totalCount = 0,
  });

  AdminListingsState copyWith({
    List<AdminListing>? listings,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
  }) {
    return AdminListingsState(
      listings: listings ?? this.listings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// Admin Meetings State
class AdminMeetingsState {
  final List<AdminMeeting> meetings;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const AdminMeetingsState({
    this.meetings = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 0,
    this.totalCount = 0,
  });

  AdminMeetingsState copyWith({
    List<AdminMeeting>? meetings,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalCount,
  }) {
    return AdminMeetingsState(
      meetings: meetings ?? this.meetings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// Admin Listings Notifier
class AdminListingsNotifier extends StateNotifier<AdminListingsState> {
  final Ref ref;

  AdminListingsNotifier(this.ref) : super(const AdminListingsState());

  Future<void> loadListings({
    int page = 1,
    String? status,
    String? type,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getAdminListings(
        page: page,
        limit: 20,
        status: status,
        type: type,
      );

      final listings = response.data
          .map((json) => AdminListing.fromJson(json))
          .toList();

      state = state.copyWith(
        listings: listings,
        isLoading: false,
        currentPage: response.pagination['page'] ?? 1,
        totalPages: response.pagination['pages'] ?? 0,
        totalCount: response.pagination['total'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshListings() async {
    await loadListings(page: 1);
  }
}

// Admin Meetings Notifier
class AdminMeetingsNotifier extends StateNotifier<AdminMeetingsState> {
  final Ref ref;

  AdminMeetingsNotifier(this.ref) : super(const AdminMeetingsState());

  Future<void> loadMeetings({
    int page = 1,
    String? status,
    String? type,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getAdminMeetings(
        page: page,
        limit: 20,
        status: status,
        type: type,
      );

      final meetings = response.data
          .map((json) => AdminMeeting.fromJson(json))
          .toList();

      state = state.copyWith(
        meetings: meetings,
        isLoading: false,
        currentPage: response.pagination['page'] ?? 1,
        totalPages: response.pagination['pages'] ?? 0,
        totalCount: response.pagination['total'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshMeetings() async {
    await loadMeetings(page: 1);
  }
}

// Users Management Provider
final usersManagementProvider =
    StateNotifierProvider<UsersManagementNotifier, UsersManagementState>((ref) {
      return UsersManagementNotifier(ref);
    });

// Admin Listings Provider
final adminListingsProvider =
    StateNotifierProvider<AdminListingsNotifier, AdminListingsState>((ref) {
      return AdminListingsNotifier(ref);
    });

// Admin Meetings Provider
final adminMeetingsProvider =
    StateNotifierProvider<AdminMeetingsNotifier, AdminMeetingsState>((ref) {
      return AdminMeetingsNotifier(ref);
    });
