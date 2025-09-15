import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'dart:io';

import '../../models/user.dart';
import '../../models/listing.dart';
import '../../models/request.dart';
import '../../models/meeting.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';
import '../../models/event.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication endpoints
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/auth/refresh')
  Future<RefreshResponse> refreshToken(@Body() RefreshRequest request);

  @POST('/auth/logout')
  Future<void> logout();

  @POST('/auth/forgot-password')
  Future<void> forgotPassword(@Body() ForgotPasswordRequest request);

  @POST('/auth/reset-password')
  Future<void> resetPassword(@Body() ResetPasswordRequest request);

  // User endpoints
  @GET('/users/profile')
  Future<User> getCurrentUser();

  @PUT('/users/{id}')
  Future<User> updateProfile(
    @Path('id') String userId,
    @Body() UpdateProfileRequest request,
  );

  @POST('/uploads/single/profile')
  @MultiPart()
  Future<AvatarResponse> uploadAvatar(@Part() File file);

  @DELETE('/uploads/single/profile')
  Future<void> deleteAvatar();

  // Listings endpoints
  @GET('/listings')
  Future<ListingsResponse> getListings({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
    @Query('location') String? location,
    @Query('skills') String? skills,
    @Query('minRate') double? minRate,
    @Query('maxRate') double? maxRate,
    @Query('search') String? search,
  });

  @GET('/listings/{id}')
  Future<ListingResponse> getListing(@Path('id') String id);

  @POST('/listings')
  Future<Listing> createListing(@Body() CreateListingRequest request);

  @PUT('/listings/{id}')
  Future<Listing> updateListing(
    @Path('id') String id,
    @Body() UpdateListingRequest request,
  );

  @DELETE('/listings/{id}')
  Future<void> deleteListing(@Path('id') String id);

  @GET('/listings/my')
  Future<ListingsResponse> getMyListings({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  // Requests endpoints
  @GET('/requests')
  Future<RequestsResponse> getRequests({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('status') String? status,
  });

  @GET('/requests/{id}')
  Future<RequestResponse> getRequest(@Path('id') String id);

  @POST('/requests')
  Future<CreateRequestResponse> createRequest(
    @Body() CreateRequestRequest request,
  );

  @PATCH('/requests/{id}/status')
  Future<UpdateRequestResponse> updateRequestStatus(
    @Path('id') String id,
    @Body() Map<String, dynamic> request,
  );

  @DELETE('/requests/{id}')
  Future<void> cancelRequest(@Path('id') String id);

  @GET('/requests/my/sent')
  Future<RequestsResponse> getMySentRequests({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  @GET('/requests/my/received')
  Future<RequestsResponse> getMyReceivedRequests({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  // Meetings endpoints
  @GET('/meetings')
  Future<MeetingsResponse> getMeetings({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('status') String? status,
    @Query('date') String? date,
  });

  @GET('/meetings/{id}')
  Future<Meeting> getMeeting(@Path('id') String id);

  @POST('/meetings')
  Future<Meeting> createMeeting(@Body() CreateMeetingRequest request);

  @PUT('/meetings/{id}')
  Future<Meeting> updateMeeting(
    @Path('id') String id,
    @Body() UpdateMeetingRequest request,
  );

  @PATCH('/meetings/{id}/cancel')
  Future<void> cancelMeeting(@Path('id') String id);

  @GET('/meetings/my/meetings')
  Future<MeetingsResponse> getMyMeetings({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('status') String? status,
    @Query('upcoming') bool? upcoming,
  });

  // Players and Coaches endpoints
  @GET('/players')
  Future<PlayersResponse> getPlayers({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('skills') String? skills,
    @Query('positions') String? positions,
    @Query('location') String? location,
  });

  @GET('/coaches')
  Future<CoachesResponse> getCoaches({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('skills') String? skills,
    @Query('positions') String? positions,
    @Query('location') String? location,
  });

  // Chat endpoints
  @GET('/chat/conversations')
  Future<ConversationsResponse> getConversations({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  @GET('/chat/conversations/{id}')
  Future<Conversation> getConversation(@Path('id') String id);

  @POST('/chat/conversations')
  Future<Conversation> createConversation(
    @Body() CreateConversationRequest request,
  );

  @GET('/chat/conversations/{id}/messages')
  Future<MessagesResponse> getMessages(
    @Path('id') String conversationId, {
    @Query('page') int page = 1,
    @Query('limit') int limit = 50,
  });

  @POST('/chat/conversations/{id}/messages')
  Future<Message> sendMessage(
    @Path('id') String conversationId,
    @Body() SendMessageRequest request,
  );

  @PUT('/chat/messages/{id}/read')
  Future<void> markMessageAsRead(@Path('id') String messageId);

  // Events endpoints
  @GET('/events')
  Future<EventsResponse> getEvents({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
  });

  @GET('/events/{id}')
  Future<Event> getEvent(@Path('id') String id);

  // Admin endpoints
  @GET('/admin/stats')
  Future<AdminStatsResponse> getAdminStats();

  @GET('/admin/users')
  Future<AdminUsersResponse> getAdminUsers({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  @PUT('/admin/users/{id}/status')
  Future<void> updateUserStatus(
    @Path('id') String userId,
    @Body() UpdateUserStatusRequest request,
  );

  @GET('/admin/listings')
  Future<AdminListingsResponse> getAdminListings({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('status') String? status,
    @Query('type') String? type,
  });

  @GET('/admin/requests')
  Future<AdminRequestsResponse> getAdminRequests({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  @GET('/admin/meetings')
  Future<AdminMeetingsResponse> getAdminMeetings({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('status') String? status,
    @Query('type') String? type,
  });

  // File upload endpoints
  @POST('/uploads/image')
  @MultiPart()
  Future<UploadResponse> uploadImage(@Part() File image);

  @POST('/uploads/file')
  @MultiPart()
  Future<UploadResponse> uploadFile(@Part() File file);
}

// Request/Response models
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': '$firstName ${lastName.isNotEmpty ? lastName : ''}',
    'role': role,
    if (phoneNumber != null) 'phone_number': phoneNumber,
  };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      // Handle both possible field names from server
      accessToken:
          json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

class RefreshRequest {
  final String refreshToken;

  RefreshRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

class RefreshResponse {
  final String accessToken;

  RefreshResponse({required this.accessToken});

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    return RefreshResponse(
      accessToken:
          json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '',
    );
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String token;
  final String password;

  ResetPasswordRequest({required this.token, required this.password});

  Map<String, dynamic> toJson() => {'token': token, 'password': password};
}

class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? bio;
  final String? location;
  final String? position;
  final int? experience;
  final double? hourlyRate;
  final List<String>? skills;
  final List<String>? certifications;
  final String? availability;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.bio,
    this.location,
    this.position,
    this.experience,
    this.hourlyRate,
    this.skills,
    this.certifications,
    this.availability,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Combine first and last name for the server's 'name' field
    if (firstName != null || lastName != null) {
      final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      if (fullName.isNotEmpty) {
        data['name'] = fullName;
      }
    }

    // Map phone_number to phone for server compatibility
    if (phoneNumber != null) data['phone'] = phoneNumber;

    // These fields can be sent as-is for profile updates
    if (bio != null) data['bio'] = bio;
    if (location != null) data['location'] = location;
    if (position != null) data['position'] = position;
    if (experience != null) data['experience'] = experience;
    if (hourlyRate != null) data['hourly_rate'] = hourlyRate;
    if (skills != null) data['skills'] = skills;
    if (certifications != null) data['certifications'] = certifications;
    if (availability != null) data['availability'] = availability;
    return data;
  }
}

class AvatarResponse {
  final String avatarUrl;

  AvatarResponse({required this.avatarUrl});

  factory AvatarResponse.fromJson(Map<String, dynamic> json) {
    // Server returns { message: "...", file: { url: "..." } }
    return AvatarResponse(avatarUrl: json['file']['url']);
  }
}

class ListingsResponse {
  final List<Listing> listings;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  ListingsResponse({
    required this.listings,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory ListingsResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return ListingsResponse(
      listings: (json['listings'] as List)
          .map((item) => Listing.fromJson(item))
          .toList(),
      totalCount: pagination['total'] as int,
      currentPage: pagination['page'] as int,
      totalPages: pagination['pages'] as int,
    );
  }
}

class ListingResponse {
  final Listing listing;

  ListingResponse({required this.listing});

  factory ListingResponse.fromJson(Map<String, dynamic> json) {
    return ListingResponse(listing: Listing.fromJson(json['listing']));
  }
}

class CreateListingRequest {
  final String title;
  final String description;
  final String type;
  final double? price;
  final String? location;
  final List<String>? skills;
  final String? availability;

  CreateListingRequest({
    required this.title,
    required this.description,
    required this.type,
    this.price,
    this.location,
    this.skills,
    this.availability,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'type': type,
    'price': price,
    'location': location,
    'skills': skills,
    'availability': availability,
  };
}

class UpdateListingRequest {
  final String? title;
  final String? description;
  final double? hourlyRate;
  final String? location;
  final List<String>? skills;
  final String? availability;
  final bool? isActive;

  UpdateListingRequest({
    this.title,
    this.description,
    this.hourlyRate,
    this.location,
    this.skills,
    this.availability,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (hourlyRate != null) data['hourly_rate'] = hourlyRate;
    if (location != null) data['location'] = location;
    if (skills != null) data['skills'] = skills;
    if (availability != null) data['availability'] = availability;
    if (isActive != null) data['is_active'] = isActive;
    return data;
  }
}

class RequestsResponse {
  final List<Request> requests;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  RequestsResponse({
    required this.requests,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory RequestsResponse.fromJson(Map<String, dynamic> json) {
    // Handle case where pagination might not be present
    final pagination = json['pagination'] as Map<String, dynamic>?;
    return RequestsResponse(
      requests: (json['requests'] as List)
          .map((item) => Request.fromJson(item))
          .toList(),
      totalCount:
          pagination?['total'] as int? ?? (json['requests'] as List).length,
      currentPage: pagination?['page'] as int? ?? 1,
      totalPages: pagination?['pages'] as int? ?? 1,
    );
  }
}

class CreateRequestRequest {
  final String? listingId;
  final String targetUserId;
  final String type; // 'buy' or 'hire'
  final String? message;

  CreateRequestRequest({
    this.listingId,
    required this.targetUserId,
    required this.type,
    this.message,
  });

  Map<String, dynamic> toJson() => {
    'target_user_id': targetUserId,
    'type': type,
    if (listingId != null) 'listing_id': listingId,
    if (message != null) 'message': message,
  };
}

class RequestResponse {
  final Request request;

  RequestResponse({required this.request});

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    return RequestResponse(request: Request.fromJson(json['request']));
  }
}

class CreateRequestResponse {
  final String message;
  final Request request;
  final int? conversationId;

  CreateRequestResponse({
    required this.message,
    required this.request,
    this.conversationId,
  });

  factory CreateRequestResponse.fromJson(Map<String, dynamic> json) {
    return CreateRequestResponse(
      message: json['message'],
      request: Request.fromJson(json['request']),
      conversationId: json['conversation_id'],
    );
  }
}

class UpdateRequestResponse {
  final String message;
  final Request request;

  UpdateRequestResponse({required this.message, required this.request});

  factory UpdateRequestResponse.fromJson(Map<String, dynamic> json) {
    return UpdateRequestResponse(
      message: json['message'],
      request: Request.fromJson(json['request']),
    );
  }
}

class UpdateRequestRequest {
  final String? status;
  final String? adminNotes;

  UpdateRequestRequest({this.status, this.adminNotes});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (adminNotes != null) data['admin_notes'] = adminNotes;
    return data;
  }
}

class MeetingsResponse {
  final List<Meeting> meetings;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  MeetingsResponse({
    required this.meetings,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory MeetingsResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return MeetingsResponse(
      meetings: (json['meetings'] as List)
          .map((item) => Meeting.fromJson(item))
          .toList(),
      totalCount: pagination['total'] as int,
      currentPage: pagination['page'] as int,
      totalPages: pagination['pages'] as int,
    );
  }
}

class CreateMeetingRequest {
  final String requestId;
  final String coachUserId;
  final String playerUserId;
  final String startAt;
  final String endAt;
  final String? locationUri;
  final String? notes;

  CreateMeetingRequest({
    required this.requestId,
    required this.coachUserId,
    required this.playerUserId,
    required this.startAt,
    required this.endAt,
    this.locationUri,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'coach_user_id': coachUserId,
    'player_user_id': playerUserId,
    'start_at': startAt,
    'end_at': endAt,
    'location_uri': locationUri,
    'notes': notes,
  };
}

class UpdateMeetingRequest {
  final String? startAt;
  final String? endAt;
  final String? locationUri;
  final String? notes;
  final String? status;

  UpdateMeetingRequest({
    this.startAt,
    this.endAt,
    this.locationUri,
    this.notes,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (startAt != null) data['start_at'] = startAt;
    if (endAt != null) data['end_at'] = endAt;
    if (locationUri != null) data['location_uri'] = locationUri;
    if (notes != null) data['notes'] = notes;
    if (status != null) data['status'] = status;
    return data;
  }
}

class ConversationsResponse {
  final List<Conversation> conversations;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  ConversationsResponse({
    required this.conversations,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) {
    // Handle case where pagination might not be present
    final pagination = json['pagination'] as Map<String, dynamic>?;
    return ConversationsResponse(
      conversations: (json['conversations'] as List)
          .map((item) => Conversation.fromJson(item))
          .toList(),
      totalCount:
          pagination?['total'] as int? ??
          (json['conversations'] as List).length,
      currentPage: pagination?['page'] as int? ?? 1,
      totalPages: pagination?['pages'] as int? ?? 1,
    );
  }
}

class CreateConversationRequest {
  final List<String> participantIds;
  final String title;
  final String type;

  CreateConversationRequest({
    required this.participantIds,
    required this.title,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'user_ids': participantIds,
    'title': title,
    'type': type,
  };
}

class MessagesResponse {
  final List<Message> messages;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  MessagesResponse({
    required this.messages,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    // Handle case where pagination might not be present
    final pagination = json['pagination'] as Map<String, dynamic>?;
    return MessagesResponse(
      messages: (json['messages'] as List)
          .map((item) => Message.fromJson(item))
          .toList(),
      totalCount:
          pagination?['total'] as int? ?? (json['messages'] as List).length,
      currentPage: pagination?['page'] as int? ?? 1,
      totalPages: pagination?['pages'] as int? ?? 1,
    );
  }
}

class SendMessageRequest {
  final String body;
  final List<String> attachments;

  SendMessageRequest({required this.body, this.attachments = const []});

  Map<String, dynamic> toJson() => {'body': body, 'attachments': attachments};
}

class UploadResponse {
  final String url;
  final String filename;
  final String mimeType;
  final int size;

  UploadResponse({
    required this.url,
    required this.filename,
    required this.mimeType,
    required this.size,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      url: json['url'],
      filename: json['filename'],
      mimeType: json['mime_type'],
      size: json['size'],
    );
  }
}

// Admin response models
class AdminStatsResponse {
  final int totalUsers;
  final int activeUsers;
  final int totalListings;
  final int activeListings;
  final int totalRequests;
  final int pendingRequests;
  final int totalMeetings;
  final List<Map<String, dynamic>> recentActivity;

  AdminStatsResponse({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalListings,
    required this.activeListings,
    required this.totalRequests,
    required this.pendingRequests,
    required this.totalMeetings,
    required this.recentActivity,
  });

  factory AdminStatsResponse.fromJson(Map<String, dynamic> json) {
    return AdminStatsResponse(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalListings: json['totalListings'] ?? 0,
      activeListings: json['activeListings'] ?? 0,
      totalRequests: json['totalRequests'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      totalMeetings: json['totalMeetings'] ?? 0,
      recentActivity:
          (json['recentActivity'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

class AdminUsersResponse {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> pagination;

  AdminUsersResponse({required this.data, required this.pagination});

  factory AdminUsersResponse.fromJson(Map<String, dynamic> json) {
    return AdminUsersResponse(
      data:
          (json['users'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: json['pagination'] as Map<String, dynamic>? ?? {},
    );
  }
}

class AdminListingsResponse {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> pagination;

  AdminListingsResponse({required this.data, required this.pagination});

  factory AdminListingsResponse.fromJson(Map<String, dynamic> json) {
    return AdminListingsResponse(
      data:
          (json['listings'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: json['pagination'] as Map<String, dynamic>? ?? {},
    );
  }
}

class AdminRequestsResponse {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> pagination;

  AdminRequestsResponse({required this.data, required this.pagination});

  factory AdminRequestsResponse.fromJson(Map<String, dynamic> json) {
    return AdminRequestsResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: json['pagination'] as Map<String, dynamic>? ?? {},
    );
  }
}

class AdminMeetingsResponse {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> pagination;

  AdminMeetingsResponse({required this.data, required this.pagination});

  factory AdminMeetingsResponse.fromJson(Map<String, dynamic> json) {
    return AdminMeetingsResponse(
      data:
          (json['meetings'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: json['pagination'] as Map<String, dynamic>? ?? {},
    );
  }
}

class PlayersResponse {
  final List<Map<String, dynamic>> players;
  final Map<String, dynamic> pagination;

  PlayersResponse({required this.players, required this.pagination});

  factory PlayersResponse.fromJson(Map<String, dynamic> json) {
    return PlayersResponse(
      players:
          (json['players'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: json['pagination'] as Map<String, dynamic>? ?? {},
    );
  }
}

class CoachesResponse {
  final List<Map<String, dynamic>> coaches;
  final Map<String, dynamic> pagination;

  CoachesResponse({required this.coaches, required this.pagination});

  factory CoachesResponse.fromJson(Map<String, dynamic> json) {
    return CoachesResponse(
      coaches:
          (json['coaches'] as List<dynamic>?)
              ?.map((item) => item as Map<String, dynamic>)
              .toList() ??
          [],
      pagination: json['pagination'] as Map<String, dynamic>? ?? {},
    );
  }
}

class UpdateUserStatusRequest {
  final String status;

  UpdateUserStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}
