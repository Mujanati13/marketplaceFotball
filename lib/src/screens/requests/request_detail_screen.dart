import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/requests_provider.dart';
import '../../models/request.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_button.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  final _responseController = TextEditingController();
  bool _isResponding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentRequestProvider.notifier).loadRequest(widget.requestId);
    });
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _updateRequestStatus(String status) async {
    print('DEBUG: _updateRequestStatus called with status: $status');
    setState(() => _isResponding = true);

    try {
      print('DEBUG: About to call updateRequestStatus API');
      await ref
          .read(currentRequestProvider.notifier)
          .updateRequestStatus(
            widget.requestId,
            status,
            _responseController.text.trim().isNotEmpty
                ? _responseController.text.trim()
                : null,
          );

      print('DEBUG: API call successful');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved'
                  ? 'Request approved successfully!'
                  : 'Request rejected successfully!',
            ),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );

        // Refresh the received requests list to show updated status
        ref.read(receivedRequestsProvider.notifier).loadReceivedRequests();

        context.pop(); // Go back to requests list
      }
    } catch (e) {
      print('DEBUG: Error in _updateRequestStatus: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update request: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResponding = false);
      }
    }
  }

  void _showResponseDialog(String action) {
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
              '${action == 'accept' ? 'Accept' : 'Decline'} Request',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Add a note (optional):',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _responseController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: action == 'accept'
                    ? 'Let them know when and where to meet...'
                    : 'Let them know why you can\'t accept this request...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: _isResponding
                        ? null
                        : () {
                            print(
                              'DEBUG: Dialog button pressed, action: $action',
                            );
                            Navigator.of(context).pop();
                            _updateRequestStatus(
                              action == 'accept' ? 'approved' : 'rejected',
                            );
                          },
                    isLoading: _isResponding,
                    text: action == 'accept' ? 'Accept' : 'Decline',
                    backgroundColor: action == 'accept'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(currentRequestProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: requestState.when(
        data: (request) {
          if (request == null) {
            return const CustomErrorWidget(message: 'Request not found');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(request.status),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Request Info
                _InfoSection(
                  title: 'Request Information',
                  children: [
                    _InfoItem(
                      icon: Icons.person,
                      label: 'From',
                      value: request.customer?.fullName ?? 'Unknown Customer',
                    ),
                    _InfoItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: request.customer?.email ?? 'N/A',
                    ),
                    _InfoItem(
                      icon: Icons.access_time,
                      label: 'Submitted',
                      value: _formatDate(request.createdAt),
                    ),
                    if (request.respondedAt != null)
                      _InfoItem(
                        icon: Icons.schedule,
                        label: 'Responded',
                        value: _formatDate(request.respondedAt!),
                      ),
                  ],
                ),

                // Listing Info
                if (request.listing != null)
                  _InfoSection(
                    title: 'Listing Details',
                    children: [
                      _InfoItem(
                        icon: Icons.work,
                        label: 'Title',
                        value: request.listing!.title,
                      ),
                      if (request.listing!.location != null)
                        _InfoItem(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: request.listing!.location!,
                        ),
                    ],
                  ),

                // Message
                if (request.message != null && request.message!.isNotEmpty)
                  _InfoSection(
                    title: 'Message',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          request.message!,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),

                // Admin Notes
                if (request.adminNotes != null &&
                    request.adminNotes!.isNotEmpty)
                  _InfoSection(
                    title: 'Response Note',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          request.adminNotes!,
                          style: const TextStyle(height: 1.5),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Action Buttons (only for pending requests)
                if (request.status == RequestStatus.pending)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            print('DEBUG: Reject button pressed');
                            _showResponseDialog('reject');
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            'Reject',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            print('DEBUG: Accept button pressed');
                            _showResponseDialog('accept');
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Accept',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Status Message (for non-pending requests)
                if (request.status != RequestStatus.pending)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(request.status).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getStatusIcon(request.status),
                          color: _getStatusColor(request.status),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Request ${_getStatusLabel(request.status)}',
                          style: TextStyle(
                            color: _getStatusColor(request.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (request.respondedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Responded on ${_formatDate(request.respondedAt!)}',
                            style: TextStyle(
                              color: _getStatusColor(
                                request.status,
                              ).withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => CustomErrorWidget(
          message: 'Failed to load request details',
          onRetry: () => ref
              .read(currentRequestProvider.notifier)
              .loadRequest(widget.requestId),
        ),
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.cancelled:
        return Colors.grey;
      case RequestStatus.completed:
        return Colors.blue;
    }
  }

  String _getStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.completed:
        return 'Completed';
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_empty;
      case RequestStatus.approved:
        return Icons.check_circle;
      case RequestStatus.rejected:
        return Icons.cancel;
      case RequestStatus.cancelled:
        return Icons.close;
      case RequestStatus.completed:
        return Icons.done_all;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

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

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
