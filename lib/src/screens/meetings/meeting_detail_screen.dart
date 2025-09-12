import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/meeting.dart';
import '../../providers/meetings_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';

class MeetingDetailScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const MeetingDetailScreen({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingDetailScreen> createState() =>
      _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final meetingState = ref.watch(meetingProvider(widget.meetingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(meetingProvider(widget.meetingId));
            },
          ),
        ],
      ),
      body: meetingState.when(
        data: (meeting) => _buildMeetingDetails(meeting),
        loading: () => const LoadingWidget(),
        error: (error, stack) => CustomErrorWidget(
          message: 'Failed to load meeting details: $error',
          onRetry: () => ref.invalidate(meetingProvider(widget.meetingId)),
        ),
      ),
    );
  }

  Widget _buildMeetingDetails(Meeting meeting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting Status Card
          _buildStatusCard(meeting),

          const SizedBox(height: 16),

          // Basic Info Card
          _buildBasicInfoCard(meeting),

          const SizedBox(height: 16),

          // Participants Card
          _buildParticipantsCard(meeting),

          const SizedBox(height: 16),

          // Location Card
          if (meeting.location != null || meeting.meetingLink != null)
            _buildLocationCard(meeting),

          const SizedBox(height: 16),

          // Notes Card
          if (meeting.description != null || meeting.adminNotes != null)
            _buildNotesCard(meeting),

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(meeting),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Meeting meeting) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (meeting.status) {
      case MeetingStatus.scheduled:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        statusText = 'Scheduled';
        break;
      case MeetingStatus.inProgress:
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle;
        statusText = 'In Progress';
        break;
      case MeetingStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case MeetingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    meeting.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(Meeting meeting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              DateFormat('EEEE, MMMM d, yyyy').format(meeting.scheduledAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Time',
              '${DateFormat('h:mm a').format(meeting.scheduledAt)} - ${DateFormat('h:mm a').format(meeting.endTime)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.timer,
              'Duration',
              '${meeting.duration} minutes',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.event_note,
              'Created',
              DateFormat('MMM d, yyyy at h:mm a').format(meeting.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsCard(Meeting meeting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participants',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Coach Info
            if (meeting.provider != null)
              _buildParticipantRow(
                'Coach',
                meeting.provider!.fullName,
                meeting.provider!.avatar,
                Icons.sports_soccer,
              ),

            const SizedBox(height: 8),

            // Player Info
            if (meeting.customer != null)
              _buildParticipantRow(
                'Player',
                meeting.customer!.fullName,
                meeting.customer!.avatar,
                Icons.person,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantRow(
    String role,
    String name,
    String? avatar,
    IconData fallbackIcon,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: avatar != null ? NetworkImage(avatar) : null,
          child: avatar == null ? Icon(fallbackIcon) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                role,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Meeting meeting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (meeting.location != null)
              _buildInfoRow(Icons.location_on, 'Venue', meeting.location!),
            if (meeting.meetingLink != null) ...[
              if (meeting.location != null) const SizedBox(height: 8),
              _buildInfoRow(
                Icons.videocam,
                'Video Call',
                meeting.meetingLink!,
                onTap: () {
                  // TODO: Open video call link
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(Meeting meeting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (meeting.description != null) ...[
              Text(
                'Meeting Notes:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                meeting.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (meeting.adminNotes != null) ...[
              if (meeting.description != null) const SizedBox(height: 12),
              Text(
                'Admin Notes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meeting.adminNotes!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.orange[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    final row = Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: row);
    }

    return row;
  }

  Widget _buildActionButtons(Meeting meeting) {
    List<Widget> buttons = [];

    if (meeting.status == MeetingStatus.scheduled) {
      buttons.addAll([
        Expanded(
          child: CustomButton(
            onPressed: _isUpdating ? null : () => _startMeeting(meeting),
            isLoading: _isUpdating,
            text: 'Start Meeting',
            backgroundColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            onPressed: _isUpdating ? null : () => _cancelMeeting(meeting),
            text: 'Cancel',
            isSecondary: true,
          ),
        ),
      ]);
    } else if (meeting.status == MeetingStatus.inProgress) {
      buttons.add(
        Expanded(
          child: CustomButton(
            onPressed: _isUpdating ? null : () => _completeMeeting(meeting),
            isLoading: _isUpdating,
            text: 'Mark Complete',
            backgroundColor: Colors.blue,
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: buttons);
  }

  Future<void> _startMeeting(Meeting meeting) async {
    setState(() => _isUpdating = true);
    try {
      await ref
          .read(meetingsProvider.notifier)
          .updateMeetingStatus(meeting.id, MeetingStatus.inProgress);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting started successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(meetingProvider(widget.meetingId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _completeMeeting(Meeting meeting) async {
    setState(() => _isUpdating = true);
    try {
      await ref
          .read(meetingsProvider.notifier)
          .updateMeetingStatus(meeting.id, MeetingStatus.completed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(meetingProvider(widget.meetingId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _cancelMeeting(Meeting meeting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Meeting'),
        content: const Text(
          'Are you sure you want to cancel this meeting? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);
    try {
      await ref.read(meetingsProvider.notifier).cancelMeeting(meeting.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting cancelled successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
        context.pop(); // Go back to meetings list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}
