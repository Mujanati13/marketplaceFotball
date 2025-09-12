import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/listings/listings_screen.dart';
import '../../screens/conversations/conversations_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';

// Provider for bottom navigation index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationWrapper extends ConsumerWidget {
  final Widget child;
  final String currentLocation;

  const MainNavigationWrapper({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currentIndex = _getCurrentIndex(currentLocation);

    // Update the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bottomNavIndexProvider.notifier).state = currentIndex;
    });

    // Don't show bottom navigation for certain screens
    if (_shouldHideBottomNav(currentLocation)) {
      return child;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref,
        currentIndex,
        user?.role == 'admin',
      ),
    );
  }

  bool _shouldHideBottomNav(String location) {
    final hiddenRoutes = [
      '/',
      '/login',
      '/register',
      '/onboarding',
      '/forgot-password',
    ];

    // Hide for auth routes and specific chat detail routes
    return hiddenRoutes.contains(location) ||
        location.startsWith('/chat/') ||
        location.startsWith('/listings/') && location.split('/').length > 2;
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/listings')) return 1;
    if (location.startsWith('/conversations') || location.startsWith('/chat'))
      return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/admin')) return 4;
    return 0;
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    bool isAdmin,
  ) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Browse',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: 'Messages',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    // Add admin tab for admin users
    if (isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex >= items.length ? 0 : currentIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      showUnselectedLabels: true,
      items: items,
      onTap: (index) => _onTabTapped(context, index, isAdmin),
    );
  }

  void _onTabTapped(BuildContext context, int index, bool isAdmin) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/listings');
        break;
      case 2:
        context.go('/conversations');
        break;
      case 3:
        context.go('/profile');
        break;
      case 4:
        if (isAdmin) {
          context.go('/admin');
        }
        break;
    }
  }
}
