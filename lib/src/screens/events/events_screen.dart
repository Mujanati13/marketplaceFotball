import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load events when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsProvider.notifier).loadEvents(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more events when reaching the bottom
      final currentTab = _tabController.index;
      final eventType = _getEventTypeForTab(currentTab);

      if (eventType == null) {
        ref.read(eventsProvider.notifier).loadEvents();
      } else {
        ref
            .read(eventsFilterProvider(eventType).notifier)
            .loadEventsByType(eventType);
      }
    }
  }

  String? _getEventTypeForTab(int index) {
    switch (index) {
      case 0:
        return null; // All events
      case 1:
        return 'announcement';
      case 2:
        return 'match';
      case 3:
        return 'training';
      case 4:
        return 'meeting';
      case 5:
        return 'tournament';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Announcements', icon: Icon(Icons.campaign)),
            Tab(text: 'Matches', icon: Icon(Icons.sports_soccer)),
            Tab(text: 'Training', icon: Icon(Icons.fitness_center)),
            Tab(text: 'Meetings', icon: Icon(Icons.meeting_room)),
            Tab(text: 'Tournaments', icon: Icon(Icons.emoji_events)),
          ],
          onTap: (index) {
            final eventType = _getEventTypeForTab(index);
            if (eventType == null) {
              ref.read(eventsProvider.notifier).loadEvents(refresh: true);
            } else {
              ref
                  .read(eventsFilterProvider(eventType).notifier)
                  .loadEventsByType(eventType, refresh: true);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCurrentTab,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(null), // All events
          _buildEventsTab('announcement'),
          _buildEventsTab('match'),
          _buildEventsTab('training'),
          _buildEventsTab('meeting'),
          _buildEventsTab('tournament'),
        ],
      ),
    );
  }

  void _refreshCurrentTab() {
    final currentTab = _tabController.index;
    final eventType = _getEventTypeForTab(currentTab);

    if (eventType == null) {
      ref.read(eventsProvider.notifier).loadEvents(refresh: true);
    } else {
      ref
          .read(eventsFilterProvider(eventType).notifier)
          .loadEventsByType(eventType, refresh: true);
    }
  }

  Widget _buildEventsTab(String? eventType) {
    return Consumer(
      builder: (context, ref, child) {
        final eventsState = eventType == null
            ? ref.watch(eventsProvider)
            : ref.watch(eventsFilterProvider(eventType));

        return RefreshIndicator(
          onRefresh: () async {
            if (eventType == null) {
              await ref.read(eventsProvider.notifier).loadEvents(refresh: true);
            } else {
              await ref
                  .read(eventsFilterProvider(eventType).notifier)
                  .loadEventsByType(eventType, refresh: true);
            }
          },
          child: _buildEventsList(eventsState),
        );
      },
    );
  }

  Widget _buildEventsList(EventsState state) {
    if (state.isLoading && state.events.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load events',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshCurrentTab,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for upcoming events',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.events.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.events.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final event = state.events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    final now = DateTime.now();
    final isUpcoming = event.eventDate.isAfter(now);
    final timeUntilEvent = event.eventDate.difference(now);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getEventTypeColor(event.eventType),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.eventTypeIcon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.eventTypeDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isUpcoming)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatTimeUntil(timeUntilEvent),
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatEventDate(event.eventDate),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              if (event.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'By ${event.creatorName}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'match':
        return Colors.green;
      case 'training':
        return Colors.blue;
      case 'meeting':
        return Colors.orange;
      case 'tournament':
        return Colors.purple;
      case 'announcement':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatEventDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[date.weekday - 1]} at ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getEventTypeColor(event.eventType),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.eventTypeIcon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.eventTypeDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (event.description != null) ...[
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(event.description!),
                const SizedBox(height: 16),
              ],
              Text(
                'Date & Time',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(_formatEventDate(event.eventDate)),
              const SizedBox(height: 16),
              if (event.location != null) ...[
                Text('Location', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(event.location!),
                const SizedBox(height: 16),
              ],
              Text(
                'Organized by',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(event.creatorName),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
