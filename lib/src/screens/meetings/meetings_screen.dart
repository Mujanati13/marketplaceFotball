import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/meeting.dart';
import '../../providers/meetings_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';

class MeetingsScreen extends ConsumerStatefulWidget {
  const MeetingsScreen({super.key});

  @override
  ConsumerState<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends ConsumerState<MeetingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load meetings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(upcomingMeetingsProvider.notifier).loadUpcomingMeetings();
      ref.read(pastMeetingsProvider.notifier).loadPastMeetings();
      ref.read(requestedMeetingsProvider.notifier).loadRequestedMeetings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Requested'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UpcomingMeetingsTab(),
          _PastMeetingsTab(),
          _RequestedMeetingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/meetings/create'),
        child: const Icon(Icons.add),
        tooltip: 'Schedule Meeting',
      ),
    );
  }
}

class _UpcomingMeetingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsState = ref.watch(upcomingMeetingsProvider);

    return meetingsState.when(
      data: (meetings) => meetings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Upcoming Meetings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You don\'t have any upcoming meetings scheduled.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref
                    .read(upcomingMeetingsProvider.notifier)
                    .loadUpcomingMeetings();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return _MeetingCard(
                    meeting: meeting,
                    onTap: () => context.push('/meetings/${meeting.id}'),
                  );
                },
              ),
            ),
      loading: () => const LoadingWidget(),
      error: (error, stack) => CustomErrorWidget(
        message: 'Failed to load upcoming meetings: $error',
        onRetry: () =>
            ref.read(upcomingMeetingsProvider.notifier).loadUpcomingMeetings(),
      ),
    );
  }
}

class _PastMeetingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsState = ref.watch(pastMeetingsProvider);

    return meetingsState.when(
      data: (meetings) => meetings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Past Meetings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You haven\'t had any meetings yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref.read(pastMeetingsProvider.notifier).loadPastMeetings();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return _MeetingCard(
                    meeting: meeting,
                    onTap: () => context.push('/meetings/${meeting.id}'),
                  );
                },
              ),
            ),
      loading: () => const LoadingWidget(),
      error: (error, stack) => CustomErrorWidget(
        message: 'Failed to load past meetings: $error',
        onRetry: () =>
            ref.read(pastMeetingsProvider.notifier).loadPastMeetings(),
      ),
    );
  }
}

class _RequestedMeetingsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsState = ref.watch(requestedMeetingsProvider);

    return meetingsState.when(
      data: (meetings) => meetings.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Meeting Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You don\'t have any pending meeting requests.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ref
                    .read(requestedMeetingsProvider.notifier)
                    .loadRequestedMeetings();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: meetings.length,
                itemBuilder: (context, index) {
                  final meeting = meetings[index];
                  return _MeetingCard(
                    meeting: meeting,
                    onTap: () => context.push('/meetings/${meeting.id}'),
                    showActions: true,
                  );
                },
              ),
            ),
      loading: () => const LoadingWidget(),
      error: (error, stack) => CustomErrorWidget(
        message: 'Failed to load meeting requests: $error',
        onRetry: () => ref
            .read(requestedMeetingsProvider.notifier)
            .loadRequestedMeetings(),
      ),
    );
  }
}

class _MeetingCard extends ConsumerWidget {
  final Meeting meeting;
  final VoidCallback onTap;
  final bool showActions;

  const _MeetingCard({
    required this.meeting,
    required this.onTap,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _MeetingStatusChip(status: meeting.status),
                ],
              ),
              const SizedBox(height: 8),
              if (meeting.description != null) ...[
                Text(
                  meeting.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDateTime(meeting.scheduledAt)} • ${meeting.duration} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (meeting.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meeting.location!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (meeting.meetingLink != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.videocam, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Video call available',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              if (showActions && meeting.status == MeetingStatus.scheduled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: () => _acceptMeeting(ref, meeting.id),
                        text: 'Accept',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => _rejectMeeting(ref, meeting.id),
                        text: 'Reject',
                        isSecondary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptMeeting(WidgetRef ref, String meetingId) async {
    try {
      await ref
          .read(meetingsProvider.notifier)
          .updateMeetingStatus(meetingId, MeetingStatus.inProgress);
      // Refresh the lists
      ref.read(requestedMeetingsProvider.notifier).loadRequestedMeetings();
      ref.read(upcomingMeetingsProvider.notifier).loadUpcomingMeetings();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _rejectMeeting(WidgetRef ref, String meetingId) async {
    try {
      await ref
          .read(meetingsProvider.notifier)
          .updateMeetingStatus(meetingId, MeetingStatus.cancelled);
      // Refresh the lists
      ref.read(requestedMeetingsProvider.notifier).loadRequestedMeetings();
    } catch (e) {
      // Handle error
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${_formatDayOfWeek(dateTime)} ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDayOfWeek(DateTime dateTime) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dateTime.weekday - 1];
  }
}

class _MeetingStatusChip extends StatelessWidget {
  final MeetingStatus status;

  const _MeetingStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case MeetingStatus.scheduled:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        text = 'Scheduled';
        break;
      case MeetingStatus.inProgress:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = 'In Progress';
        break;
      case MeetingStatus.completed:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        text = 'Completed';
        break;
      case MeetingStatus.cancelled:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
