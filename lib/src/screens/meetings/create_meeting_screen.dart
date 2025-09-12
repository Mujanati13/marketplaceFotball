import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/meetings_provider.dart';
import '../../providers/requests_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/request.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_button.dart';

class CreateMeetingScreen extends ConsumerStatefulWidget {
  final String? requestId;

  const CreateMeetingScreen({super.key, this.requestId});

  @override
  ConsumerState<CreateMeetingScreen> createState() =>
      _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends ConsumerState<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  Request? _selectedRequest;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Load requests when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.requestId != null) {
        ref
            .read(currentRequestProvider.notifier)
            .loadRequest(widget.requestId!);
      } else {
        // Load received requests for selection
        ref.read(receivedRequestsProvider.notifier).loadReceivedRequests();
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.requestId != null) {
      return _buildWithSpecificRequest();
    }
    return _buildWithRequestSelection();
  }

  Widget _buildWithSpecificRequest() {
    final requestState = ref.watch(currentRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Meeting'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: requestState.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Request not found'));
          }
          _selectedRequest = request;
          return _buildForm();
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) =>
            Center(child: Text('Error loading request: $error')),
      ),
    );
  }

  Widget _buildWithRequestSelection() {
    final receivedRequestsState = ref.watch(receivedRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Meeting'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: receivedRequestsState.when(
        data: (requests) {
          // Filter for approved requests that don't have meetings yet
          final availableRequests = requests
              .where((request) => request.status == RequestStatus.approved)
              .toList();

          if (availableRequests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No approved requests available for scheduling',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_selectedRequest == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select a Request to Schedule',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose from your approved coaching requests:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: availableRequests.length,
                    itemBuilder: (context, index) {
                      final request = availableRequests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              request.customer != null
                                  ? '${request.customer!.firstName.substring(0, 1)}${request.customer!.lastName.substring(0, 1)}'
                                        .toUpperCase()
                                  : 'U',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            request.customer != null
                                ? '${request.customer!.firstName} ${request.customer!.lastName}'
                                : 'Unknown Player',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.message ?? 'No message'),
                              const SizedBox(height: 4),
                              Text(
                                'Requested: ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            setState(() {
                              _selectedRequest = request;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(child: _buildForm()),
              ],
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading requests: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(receivedRequestsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedRequest != null && widget.requestId == null) ...[
              // Back button to request selection
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedRequest = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Request Selection'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedRequest != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Request Details',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Player: ${_selectedRequest!.customer != null ? "${_selectedRequest!.customer!.firstName} ${_selectedRequest!.customer!.lastName}" : "Unknown"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.message,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Message: ${_selectedRequest!.message ?? 'No message provided'}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else if (widget.requestId == null) ...[
              // Show message when no request is selected and we're in general create mode
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Please select a request first to schedule a meeting.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Start Date & Time
            Text(
              'Start Date & Time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Select Date',
                        style: TextStyle(
                          color: _startDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _startTime != null
                            ? _startTime!.format(context)
                            : 'Select Time',
                        style: TextStyle(
                          color: _startTime != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // End Date & Time
            Text(
              'End Date & Time',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickEndDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Select Date',
                        style: TextStyle(
                          color: _endDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickEndTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _endTime != null
                            ? _endTime!.format(context)
                            : 'Select Time',
                        style: TextStyle(
                          color: _endTime != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Meeting Location',
                hintText: 'Enter meeting location or video call link',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a meeting location';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Meeting Notes (Optional)',
                hintText: 'Add any additional notes for the meeting',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            // Create Button
            CustomButton(
              onPressed: (_isCreating || _selectedRequest == null)
                  ? null
                  : _createMeeting,
              isLoading: _isCreating,
              text: _selectedRequest == null
                  ? 'Select a Request First'
                  : 'Schedule Meeting',
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _pickStartTime() async {
    // Default to at least 15 minutes in the future to avoid "past" issues
    final now = DateTime.now();
    final futureTime = now.add(const Duration(minutes: 15));
    final initialTime = TimeOfDay(
      hour: futureTime.hour,
      minute: futureTime.minute,
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
        // Auto-set end time to 1 hour later if not already set
        if (_endTime == null) {
          final endHour = (time.hour + 1) % 24;
          _endTime = TimeOfDay(hour: endHour, minute: time.minute);
          // If end date is not set, set it to the same as start date
          if (_endDate == null && _startDate != null) {
            _endDate = _startDate;
          }
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _pickEndTime() async {
    // Calculate a reasonable initial time (1 hour after start time or current time)
    TimeOfDay initialTime = TimeOfDay.now();
    if (_startTime != null) {
      final endHour = (_startTime!.hour + 1) % 24;
      initialTime = TimeOfDay(hour: endHour, minute: _startTime!.minute);
    }

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time != null) {
      setState(() => _endTime = time);
    }
  }

  Future<void> _createMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date and time')),
      );
      return;
    }

    if (_endDate == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select end date and time')),
      );
      return;
    }

    if (_selectedRequest == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No request selected')));
      return;
    }

    setState(() => _isCreating = true);

    try {
      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      print('Debug: Start date: $_startDate, Start time: $_startTime');
      print('Debug: End date: $_endDate, End time: $_endTime');
      print('Debug: Start DateTime: $startDateTime');
      print('Debug: End DateTime: $endDateTime');

      // Check if the meeting is scheduled in the past
      final now = DateTime.now();
      if (startDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting cannot be scheduled in the past'),
          ),
        );
        return;
      }

      if (endDateTime.isBefore(startDateTime) ||
          endDateTime.isAtSameMomentAs(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
        return;
      }

      // Debug: Check user ID
      final currentUser = ref.read(authProvider).user;
      final userId = currentUser?.id ?? '';
      print('Debug: Current user ID: $userId');
      print('Debug: Current user: $currentUser');

      // Temporary: Use hardcoded admin user ID from JWT token
      final coachUserId = userId.isNotEmpty ? userId : '1';

      if (coachUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error: User ID not found'),
          ),
        );
        return;
      }

      await ref
          .read(meetingsProvider.notifier)
          .createMeeting(
            requestId: _selectedRequest!.id,
            coachUserId: coachUserId,
            playerUserId: _selectedRequest!.customerId,
            startAt: startDateTime,
            endAt: endDateTime,
            locationUri: _locationController.text.trim(),
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting scheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule meeting: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
