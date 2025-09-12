import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/http_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(profileProvider.notifier).loadProfile();
      }
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go(AppRoute.login.path);
      }
    }
  }

  Future<void> _showAvatarOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (ref.read(authProvider).user?.avatar != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeAvatar();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadAvatar(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    try {
      await HttpService.apiService.uploadAvatar(imageFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    try {
      await HttpService.apiService.deleteAvatar();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo removed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final user = userState.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: user == null
          ? const Center(child: Text('Please log in to view your profile'))
          : CustomScrollView(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _showAvatarOptions,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  child: user.avatar != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            40,
                                          ),
                                          child: Image.network(
                                            user.avatar!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.person,
                                                      size: 40,
                                                    ),
                                          ),
                                        )
                                      : const Icon(Icons.person, size: 40),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getRoleLabel(user.role),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Info Section
                        _ProfileSection(
                          title: 'Basic Information',
                          children: [
                            _InfoItem(
                              icon: Icons.email,
                              label: 'Email',
                              value: user.email,
                            ),
                            if (user.phoneNumber != null)
                              _InfoItem(
                                icon: Icons.phone,
                                label: 'Phone',
                                value: user.phoneNumber!,
                              ),
                          ],
                        ),

                        // Profile Details Section
                        profileState.when(
                          data: (profileData) {
                            final profile = profileData;
                            if (profile == null) {
                              return _ProfileSection(
                                title: 'Profile Details',
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Complete your profile',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () => context.push(
                                            AppRoute.editProfile.path,
                                          ),
                                          child: const Text(
                                            'Add Profile Details',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }

                            return _ProfileSection(
                              title: 'Profile Details',
                              children: [
                                if (profile.location != null)
                                  _InfoItem(
                                    icon: Icons.location_on,
                                    label: 'Location',
                                    value: profile.location!,
                                  ),
                                if (profile.position != null)
                                  _InfoItem(
                                    icon: Icons.sports_soccer,
                                    label: 'Position',
                                    value: profile.position!,
                                  ),
                                if (profile.experience != null)
                                  _InfoItem(
                                    icon: Icons.star,
                                    label: 'Experience Level',
                                    value: _getExperienceLabel(
                                      profile.experience.toString(),
                                    ),
                                  ),
                                if (profile.hourlyRate != null)
                                  _InfoItem(
                                    icon: Icons.attach_money,
                                    label: 'Hourly Rate',
                                    value: '\$${profile.hourlyRate}/hour',
                                  ),
                                if (profile.availability != null)
                                  _InfoItem(
                                    icon: Icons.schedule,
                                    label: 'Availability',
                                    value: profile.availability!,
                                  ),
                                if (profile.skills != null &&
                                    profile.skills!.isNotEmpty)
                                  _InfoItem(
                                    icon: Icons.sports,
                                    label: 'Skills',
                                    value: profile.skills!.join(', '),
                                  ),
                                if (profile.certifications != null &&
                                    profile.certifications!.isNotEmpty)
                                  _InfoItem(
                                    icon: Icons.verified,
                                    label: 'Certifications',
                                    value: profile.certifications!.join(', '),
                                  ),
                                if (profile.rating != null)
                                  _InfoItem(
                                    icon: Icons.star_rate,
                                    label: 'Rating',
                                    value:
                                        '${profile.rating}/5.0 (${profile.totalReviews ?? 0} reviews)',
                                  ),
                              ],
                            );
                          },
                          loading: () => const LoadingWidget(),
                          error: (error, stack) => CustomErrorWidget(
                            message: 'Failed to load profile details',
                            onRetry: () => ref
                                .read(profileProvider.notifier)
                                .loadProfile(),
                          ),
                        ),

                        // Bio Section
                        profileState.when(
                          data: (profileData) {
                            final profile = profileData;
                            if (profile?.bio != null &&
                                profile!.bio!.isNotEmpty) {
                              return _ProfileSection(
                                title: 'About Me',
                                children: [
                                  Text(
                                    profile.bio!,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                        ),

                        // Skills Section
                        profileState.when(
                          data: (profileData) {
                            final profile = profileData;
                            if (profile?.skills != null &&
                                profile!.skills!.isNotEmpty) {
                              return _ProfileSection(
                                title: 'Skills',
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    children: profile.skills!
                                        .map(
                                          (skill) => Chip(label: Text(skill)),
                                        )
                                        .toList(),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                        ),

                        // Account Actions
                        _ProfileSection(
                          title: 'Account',
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () =>
                                  context.push(AppRoute.editProfile.path),
                            ),
                            ListTile(
                              leading: const Icon(Icons.help),
                              title: const Text('Help & Support'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                context.push('/help');
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                              title: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: _handleLogout,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'player':
        return 'Player';
      case 'coach':
        return 'Coach';
      case 'club_representative':
        return 'Club Representative';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }

  String _getExperienceLabel(String experience) {
    switch (experience) {
      case 'beginner':
        return 'Beginner';
      case 'amateur':
        return 'Amateur';
      case 'semi_professional':
        return 'Semi-Professional';
      case 'professional':
        return 'Professional';
      default:
        return experience;
    }
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
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
