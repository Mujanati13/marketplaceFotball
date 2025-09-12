import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing.dart';
import '../core/services/http_service.dart';
import '../core/services/api_service.dart';
import '../core/services/logger_service.dart';

// Listings state notifier
class ListingsNotifier extends StateNotifier<AsyncValue<List<Listing>>> {
  ListingsNotifier() : super(const AsyncValue.loading());

  Future<void> loadListings({
    String? search,
    String? type,
    String? position,
    String? experienceLevel,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      state = const AsyncValue.loading();

      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (search != null) queryParams['search'] = search;
      if (type != null) queryParams['type'] = type;
      if (position != null) queryParams['position'] = position;
      if (experienceLevel != null)
        queryParams['experience_level'] = experienceLevel;
      if (location != null) queryParams['location'] = location;

      final response = await HttpService.apiService.getListings(
        page: page,
        limit: limit,
        search: search,
        type: type,
        location: location,
      );

      state = AsyncValue.data(response.listings);
      LoggerService.info('Loaded ${response.listings.length} listings');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load listings', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createListing({
    required String type,
    required String title,
    required String description,
    String? location,
    double? hourlyRate,
    List<String>? skills,
    String? availability,
  }) async {
    try {
      final request = CreateListingRequest(
        type: type,
        title: title,
        description: description,
        location: location,
        price: hourlyRate,
        skills: skills,
        availability: availability,
      );

      await HttpService.apiService.createListing(request);
      LoggerService.info('Listing created successfully');
      // Reload listings to include the new one
      await loadListings();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create listing', e, stackTrace);
      rethrow;
    }
  }

  Future<void> submitRequest({
    required String listingId,
    required String targetUserId,
    required String message,
  }) async {
    try {
      LoggerService.debug('Creating request with:');
      LoggerService.debug('  listingId: $listingId');
      LoggerService.debug('  targetUserId: $targetUserId');
      LoggerService.debug('  message: $message');

      final request = CreateRequestRequest(
        listingId: listingId,
        targetUserId: targetUserId,
        type: 'hire', // Default to 'hire' for listings
        message: message,
      );

      final response = await HttpService.apiService.createRequest(request);
      LoggerService.info('Request submitted successfully: ${response.message}');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to submit request', e, stackTrace);
      rethrow;
    }
  }
}

// Current listing state notifier
class CurrentListingNotifier extends StateNotifier<AsyncValue<Listing?>> {
  CurrentListingNotifier() : super(const AsyncValue.data(null));

  Future<void> loadListing(String listingId) async {
    print('=== PROVIDER LOAD LISTING START ===');
    print('loadListing called with ID: $listingId');
    print('=== PROVIDER LOAD LISTING START END ===');

    try {
      print('=== LOAD LISTING DEBUG ===');
      print('Loading listing with ID: $listingId');
      print('=== LOAD LISTING DEBUG END ===');

      state = const AsyncValue.loading();

      print('=== CALLING API SERVICE ===');
      final listingResponse = await HttpService.apiService.getListing(
        listingId,
      );
      final listing = listingResponse.listing;
      print('=== API SERVICE RETURNED ===');

      print('=== LISTING LOADED DEBUG ===');
      print('Loaded listing: $listing');
      print('Listing ID: ${listing.id}');
      print('Listing UserID: ${listing.userId}');
      print('=== LISTING LOADED DEBUG END ===');

      state = AsyncValue.data(listing);
      LoggerService.info('Loaded listing: $listingId');
    } catch (e, stackTrace) {
      print('=== LOAD LISTING ERROR ===');
      print('Error loading listing: $e');
      print('StackTrace: $stackTrace');
      print('=== LOAD LISTING ERROR END ===');

      LoggerService.error('Failed to load listing', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearListing() {
    state = const AsyncValue.data(null);
  }
}

// Providers
final listingsProvider =
    StateNotifierProvider<ListingsNotifier, AsyncValue<List<Listing>>>(
      (ref) => ListingsNotifier(),
    );

final currentListingProvider =
    StateNotifierProvider<CurrentListingNotifier, AsyncValue<Listing?>>(
      (ref) => CurrentListingNotifier(),
    );
