import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryRangeController = TextEditingController();

  String _selectedType = 'player';
  String? _selectedPosition;
  String? _selectedExperience;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _salaryRangeController.dispose();
    super.dispose();
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create a listing')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(listingsProvider.notifier)
          .createListing(
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            hourlyRate: _salaryRangeController.text.trim().isEmpty
                ? null
                : double.tryParse(_salaryRangeController.text.trim()),
            skills: _selectedPosition != null ? [_selectedPosition!] : null,
            availability: _selectedExperience,
          );

      // Refresh admin stats if user is admin
      final currentUser = ref.read(authProvider).user;
      if (currentUser?.role == 'admin') {
        try {
          await ref.read(dashboardProvider.notifier).loadDashboardStats();
        } catch (e) {
          // Don't fail the whole operation if stats refresh fails
          print('Failed to refresh admin stats: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to listings screen instead of just popping
        context.go('/listings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create listing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Listing'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Selection
              Text(
                'Listing Type',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _TypeSelectionGrid(
                selectedType: _selectedType,
                onChanged: (type) => setState(() => _selectedType = type),
              ),
              const SizedBox(height: 24),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Title *',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe what you\'re looking for...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Position (if relevant)
              if (_selectedType == 'player')
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      decoration: InputDecoration(
                        labelText: 'Position',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'goalkeeper',
                          child: Text('Goalkeeper'),
                        ),
                        DropdownMenuItem(
                          value: 'defender',
                          child: Text('Defender'),
                        ),
                        DropdownMenuItem(
                          value: 'midfielder',
                          child: Text('Midfielder'),
                        ),
                        DropdownMenuItem(
                          value: 'forward',
                          child: Text('Forward'),
                        ),
                        DropdownMenuItem(
                          value: 'any',
                          child: Text('Any Position'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedPosition = value),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Experience Level
              DropdownButtonFormField<String>(
                value: _selectedExperience,
                decoration: InputDecoration(
                  labelText: 'Experience Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(value: 'amateur', child: Text('Amateur')),
                  DropdownMenuItem(
                    value: 'semi_professional',
                    child: Text('Semi-Professional'),
                  ),
                  DropdownMenuItem(
                    value: 'professional',
                    child: Text('Professional'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _selectedExperience = value),
              ),
              const SizedBox(height: 16),

              // Location
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                prefixIcon: Icons.location_on,
                hintText: 'e.g., New York, NY',
              ),
              const SizedBox(height: 16),

              // Hourly Rate (for all types)
              Column(
                children: [
                  CustomTextField(
                    controller: _salaryRangeController,
                    label: 'Hourly Rate',
                    prefixIcon: Icons.attach_money,
                    hintText: 'e.g., 50 (dollars per hour)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              // Requirements
              TextFormField(
                controller: _requirementsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Requirements',
                  hintText: 'Any specific requirements or qualifications...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              CustomButton(
                onPressed: _isLoading ? null : _createListing,
                isLoading: _isLoading,
                text: 'Create Listing',
              ),
              const SizedBox(height: 16),

              Text(
                '* Required fields',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSelectionGrid extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const _TypeSelectionGrid({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {
        'value': 'player',
        'label': 'Player',
        'icon': Icons.person_search,
        'description': 'I\'m a player offering services',
      },
      {
        'value': 'coach',
        'label': 'Coach',
        'icon': Icons.groups,
        'description': 'I\'m a coach offering training',
      },
      {
        'value': 'service',
        'label': 'Service',
        'icon': Icons.sports,
        'description': 'Other football-related service',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = selectedType == type['value'];

        return GestureDetector(
          onTap: () => onChanged(type['value'] as String),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.grey[50],
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type['icon'] as IconData,
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  type['description'] as String,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
