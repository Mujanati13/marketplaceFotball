import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/logger_service.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/listing.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final _messageController = TextEditingController();
  bool _isSubmittingRequest = false;

  @override
  void initState() {
    super.initState();
    print('=== INIT STATE DEBUG ===');
    print('ListingDetailScreen initState - listingId: ${widget.listingId}');
    print('=== INIT STATE DEBUG END ===');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=== POST FRAME CALLBACK DEBUG ===');
      print('About to call loadListing with ID: ${widget.listingId}');
      print('=== POST FRAME CALLBACK DEBUG END ===');

      ref.read(currentListingProvider.notifier).loadListing(widget.listingId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest(Listing listing) async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a request')),
      );
      return;
    }

    // Debug logging using both LoggerService and print
    print('=== DEBUG START ===');
    print('Debug - Listing ID: ${listing.id}');
    print('Debug - Listing userId: ${listing.userId}');
    print('Debug - Message: ${_messageController.text.trim()}');
    print('Debug - Listing title: ${listing.title}');
    print('Debug - Listing type: ${listing.type}');
    print('=== DEBUG END ===');

    LoggerService.debug('Debug - Listing ID: ${listing.id}');
    LoggerService.debug('Debug - Listing userId: ${listing.userId}');
    LoggerService.debug('Debug - Message: ${_messageController.text.trim()}');
    LoggerService.debug('Debug - Listing object: ${listing.toString()}');

    setState(() => _isSubmittingRequest = true);

    try {
      await ref
          .read(listingsProvider.notifier)
          .submitRequest(
            listingId: listing.id,
            targetUserId: listing.userId,
            message: _messageController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Close bottom sheet
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to submit request';

        // Check for specific error messages
        if (e.toString().contains('pending request already exists')) {
          errorMessage =
              'You already have a pending request for this listing. Please wait for a response.';
        } else if (e.toString().contains('Target user not found')) {
          errorMessage = 'The listing owner could not be found.';
        } else if (e.toString().contains('Listing not found')) {
          errorMessage = 'This listing is no longer available.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingRequest = false);
      }
    }
  }

  void _showRequestDialog(Listing listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Submit Request',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Send a message to ${listing.user?.fullName ?? 'the listing owner'}:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell them why you\'re interested...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: _isSubmittingRequest
                  ? null
                  : () => _submitRequest(listing),
              isLoading: _isSubmittingRequest,
              text: 'Submit Request',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingState = ref.watch(currentListingProvider);

    // Debug logging to see listing state
    print('=== BUILD DEBUG START ===');
    print('ListingDetailScreen build - listingState: $listingState');
    print(
      'ListingDetailScreen build - listingId from widget: ${widget.listingId}',
    );
    print('=== BUILD DEBUG END ===');

    LoggerService.debug(
      'ListingDetailScreen build - listingState: $listingState',
    );
    LoggerService.debug(
      'ListingDetailScreen build - listingId from widget: ${widget.listingId}',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: listingState.when(
        data: (listing) {
          print('=== LISTING DATA RECEIVED ===');
          print('Listing object: $listing');
          print('Listing id: ${listing?.id}');
          print('Listing userId: ${listing?.userId}');
          print('Listing title: ${listing?.title}');
          print('=== LISTING DATA RECEIVED END ===');

          LoggerService.debug(
            'Listing data received - id: ${listing?.id}, userId: ${listing?.userId}',
          );

          if (listing == null) {
            return const CustomErrorWidget(message: 'Listing not found');
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sports_soccer,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(listing.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getTypeLabel(listing.type),
                          style: TextStyle(
                            color: _getTypeColor(listing.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        listing.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Owner Info
                      if (listing.user != null)
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              child: Icon(Icons.person, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Posted by ${listing.user!.fullName}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Details Section
                      _DetailSection(
                        title: 'Details',
                        children: [
                          if (listing.location != null)
                            _DetailItem(
                              icon: Icons.location_on,
                              label: 'Location',
                              value: listing.location!,
                            ),
                          if (listing.hourlyRate != null)
                            _DetailItem(
                              icon: Icons.attach_money,
                              label: 'Hourly Rate',
                              value: '\$${listing.hourlyRate}/hour',
                            ),
                          if (listing.availability != null)
                            _DetailItem(
                              icon: Icons.schedule,
                              label: 'Availability',
                              value: listing.availability!,
                            ),
                          if (listing.skills != null &&
                              listing.skills!.isNotEmpty)
                            _DetailItem(
                              icon: Icons.sports,
                              label: 'Skills',
                              value: listing.skills!.join(', '),
                            ),
                        ],
                      ),

                      // Description Section
                      _DetailSection(
                        title: 'Description',
                        children: [
                          Text(
                            listing.description,
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100), // Space for floating button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Scaffold(body: LoadingWidget()),
        error: (error, stack) => Scaffold(
          body: CustomErrorWidget(
            message: 'Failed to load listing',
            onRetry: () => ref
                .read(currentListingProvider.notifier)
                .loadListing(widget.listingId),
          ),
        ),
      ),
      floatingActionButton: listingState.when(
        data: (listing) {
          if (listing == null) return null;

          final user = ref.watch(authProvider).user;
          if (user?.id == listing.userId)
            return null; // Can't request own listing

          return FloatingActionButton.extended(
            onPressed: () => _showRequestDialog(listing),
            icon: const Icon(Icons.send),
            label: const Text('Send Request'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          );
        },
        loading: () => null,
        error: (error, stack) => null,
      ),
    );
  }

  Color _getTypeColor(ListingType type) {
    switch (type) {
      case ListingType.player:
        return Colors.blue;
      case ListingType.coach:
        return Colors.green;
      case ListingType.service:
        return Colors.orange;
    }
  }

  String _getTypeLabel(ListingType type) {
    switch (type) {
      case ListingType.player:
        return 'Player';
      case ListingType.coach:
        return 'Coach';
      case ListingType.service:
        return 'Service';
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
