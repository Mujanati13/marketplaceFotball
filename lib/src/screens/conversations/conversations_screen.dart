import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/conversations_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/conversation.dart';
import '../../core/services/api_service.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load conversations when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsState = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateConversationDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(conversationsProvider.notifier).loadConversations(),
          ),
        ],
      ),
      body: _buildBody(conversationsState),
    );
  }

  Widget _buildBody(ConversationsState state) {
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load conversations',
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
              onPressed: () =>
                  ref.read(conversationsProvider.notifier).loadConversations(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with someone',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCreateConversationDialog(context),
              child: const Text('Start Conversation'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(conversationsProvider.notifier).loadConversations(),
      child: ListView.builder(
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return _buildConversationTile(conversation);
        },
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            conversation.title.isNotEmpty
                ? conversation.title[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          conversation.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.lastMessageContent != null)
              Text(
                conversation.lastMessageContent!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            if (conversation.lastMessageAt != null)
              Text(
                _formatDate(conversation.lastMessageAt!),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: conversation.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: () => _openConversation(conversation),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _openConversation(Conversation conversation) {
    context.push('/chat/${conversation.id}');
  }

  void _showCreateConversationDialog(BuildContext context) {
    print('🚀 SHOWING CREATE CONVERSATION DIALOG - NEW VERSION');
    final titleController = TextEditingController();
    String selectedType = 'general'; // Default type
    List<Map<String, dynamic>> selectedUsers = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Start New Conversation'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Conversation Title',
                    hintText: 'Enter a title for this conversation',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Conversation Type',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'deal', child: Text('Deal')),
                    DropdownMenuItem(value: 'support', child: Text('Support')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Participants:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () => _showUserSelectionDialog(
                        context,
                        selectedUsers,
                        (users) {
                          setState(() {
                            selectedUsers = users;
                          });
                        },
                      ),
                      child: const Text('Select Users'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (selectedUsers.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: selectedUsers
                          .map(
                            (user) => Chip(
                              label: Text(
                                user['name'] ?? user['email'] ?? 'Unknown',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                setState(() {
                                  selectedUsers.remove(user);
                                });
                              },
                              deleteIconColor: Colors.grey[600],
                            ),
                          )
                          .toList(),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'No participants selected',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedUsers.isNotEmpty
                  ? () {
                      print(
                        'Create button pressed with ${selectedUsers.length} users',
                      );
                      _createConversation(
                        context,
                        titleController.text,
                        selectedType,
                        selectedUsers,
                      );
                    }
                  : null,
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createConversation(
    BuildContext context,
    String title,
    String type,
    List<Map<String, dynamic>> selectedUsers,
  ) async {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a conversation title')),
      );
      return;
    }

    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one participant')),
      );
      return;
    }

    // Extract user IDs from selected users
    final participantIds = selectedUsers
        .map((user) => user['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    if (participantIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid user selection. Please try again.'),
        ),
      );
      return;
    }

    // Debug print to check what we're sending
    print('Creating conversation with participant IDs: $participantIds');
    print('Title: $title, Type: $type');

    final request = CreateConversationRequest(
      participantIds: participantIds,
      title: title.trim(),
      type: type,
    );

    try {
      final result = await ref
          .read(conversationsProvider.notifier)
          .createConversation(request);

      if (result != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Check the provider state for specific error messages
        final providerState = ref.read(conversationsProvider);
        String errorMessage = 'Unable to create conversation';

        if (providerState.error != null) {
          if (providerState.error!.toLowerCase().contains(
            'insufficient permissions',
          )) {
            errorMessage =
                'You don\'t have permission to create this type of conversation. Please contact support if needed.';
          } else {
            errorMessage = providerState.error!;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Handle any unexpected errors that weren't caught by the provider
      String errorMessage = 'Failed to create conversation';

      // Check if it's a permission error
      if (e.toString().toLowerCase().contains('insufficient permissions') ||
          e.toString().contains('403')) {
        errorMessage =
            'You don\'t have permission to create this type of conversation. Please contact support if needed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showUserSelectionDialog(
    BuildContext context,
    List<Map<String, dynamic>> currentlySelected,
    Function(List<Map<String, dynamic>>) onUsersSelected,
  ) {
    print('Opening user selection dialog...');
    showDialog(
      context: context,
      builder: (context) => _UserSelectionDialog(
        currentlySelected: currentlySelected,
        onUsersSelected: onUsersSelected,
      ),
    );
  }
}

class _UserSelectionDialog extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> currentlySelected;
  final Function(List<Map<String, dynamic>>) onUsersSelected;

  const _UserSelectionDialog({
    required this.currentlySelected,
    required this.onUsersSelected,
  });

  @override
  ConsumerState<_UserSelectionDialog> createState() =>
      _UserSelectionDialogState();
}

class _UserSelectionDialogState extends ConsumerState<_UserSelectionDialog> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> selectedUsers = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedUsers = List.from(widget.currentlySelected);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final apiService = ref.read(apiServiceProvider);
      final currentUser = ref.read(currentUserProvider);

      List<Map<String, dynamic>> allUsers = [];

      // If user is admin, use admin endpoint
      if (currentUser?.role == 'admin') {
        final response = await apiService.getAdminUsers(limit: 100);
        allUsers = response.data;
      } else {
        // For non-admin users, get players and coaches separately
        try {
          final playersResponse = await apiService.getPlayers(limit: 50);
          final coachesResponse = await apiService.getCoaches(limit: 50);

          // Combine and format the data to match expected structure
          allUsers = [
            ...playersResponse.players.map((player) {
              final firstName = player['first_name'] ?? '';
              final lastName = player['last_name'] ?? '';
              final fullName = '$firstName $lastName'.trim();
              final email = player['email'] ?? '';

              return {
                'id': player['user_id'] ?? player['id'],
                'name': fullName.isNotEmpty
                    ? fullName
                    : email.isNotEmpty
                    ? email
                    : 'Unknown Player',
                'email': email,
                'role': 'player',
                'avatar_url': player['avatar_url'],
              };
            }),
            ...coachesResponse.coaches.map((coach) {
              final firstName = coach['first_name'] ?? '';
              final lastName = coach['last_name'] ?? '';
              final fullName = '$firstName $lastName'.trim();
              final email = coach['email'] ?? '';

              return {
                'id': coach['user_id'] ?? coach['id'],
                'name': fullName.isNotEmpty
                    ? fullName
                    : email.isNotEmpty
                    ? email
                    : 'Unknown Coach',
                'email': email,
                'role': 'coach',
                'avatar_url': coach['avatar_url'],
              };
            }),
          ];
        } catch (e) {
          // If player/coach endpoints fail, show empty list
          print('Failed to load users for conversation: $e');
          allUsers = [];
        }
      }

      setState(() {
        users = allUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    return users.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  bool _isUserSelected(Map<String, dynamic> user) {
    return selectedUsers.any((selected) => selected['id'] == user['id']);
  }

  void _toggleUserSelection(Map<String, dynamic> user) {
    setState(() {
      if (_isUserSelected(user)) {
        selectedUsers.removeWhere((selected) => selected['id'] == user['id']);
      } else {
        selectedUsers.add(user);
      }
    });
  }

  String _getInitial(String? name, String? email) {
    // Try to get initial from name first
    if (name != null && name.trim().isNotEmpty) {
      return name.trim()[0].toUpperCase();
    }

    // Fall back to email
    if (email != null && email.trim().isNotEmpty) {
      return email.trim()[0].toUpperCase();
    }

    // Final fallback
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Participants'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Selected users count
            Text(
              '${selectedUsers.length} participant(s) selected',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            // Users list
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUsersSelected(selectedUsers);
            Navigator.pop(context);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load users',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
          ],
        ),
      );
    }

    final filteredUsersList = filteredUsers;

    if (filteredUsersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No users found'
                  : 'No users match your search',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredUsersList.length,
      itemBuilder: (context, index) {
        final user = filteredUsersList[index];
        final isSelected = _isUserSelected(user);

        return CheckboxListTile(
          title: Text(user['name'] ?? 'Unknown User'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user['email'] ?? ''),
              Text(
                'Role: ${user['role'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          secondary: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              _getInitial(user['name'], user['email']),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          value: isSelected,
          onChanged: (value) => _toggleUserSelection(user),
        );
      },
    );
  }
}
