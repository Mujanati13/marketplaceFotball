import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/listings/listings_screen.dart';
import '../../screens/listings/listing_detail_screen.dart';
import '../../screens/listings/create_listing_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/help_screen.dart';
import '../../screens/profile/support_screen.dart';
import '../../screens/requests/requests_screen.dart';
import '../../screens/meetings/meetings_screen.dart';
import '../../screens/meetings/meeting_detail_screen.dart';
import '../../screens/meetings/create_meeting_screen.dart';
import '../../screens/conversations/conversations_screen.dart';
import '../../screens/conversations/conversation_detail_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/requests/request_detail_screen.dart';
import '../../screens/events/events_screen.dart';
import '../../screens/placeholder_screens.dart' as placeholder;
import '../../widgets/navigation/main_navigation_wrapper.dart';

// Route names
class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const listings = '/listings';
  static const listingDetail = '/listings/:id';
  static const createListing = '/create-listing';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const settings = '/settings';
  static const help = '/help';
  static const support = '/support';
  static const requests = '/requests';
  static const requestDetail = '/requests/:id';
  static const meetings = '/meetings';
  static const meetingDetail = '/meetings/:id';
  static const createMeeting = '/meetings/create';
  static const conversations = '/conversations';
  static const chat = '/chat/:id';
  static const events = '/events';
  static const adminDashboard = '/admin';
}

// Enum for easy route access
enum AppRoute {
  splash(Routes.splash),
  onboarding(Routes.onboarding),
  login(Routes.login),
  register(Routes.register),
  forgotPassword(Routes.forgotPassword),
  home(Routes.home),
  listings(Routes.listings),
  listingDetail(Routes.listingDetail),
  createListing(Routes.createListing),
  profile(Routes.profile),
  editProfile(Routes.editProfile),
  settings(Routes.settings),
  help(Routes.help),
  support(Routes.support),
  requests(Routes.requests),
  requestDetail(Routes.requestDetail),
  meetings(Routes.meetings),
  meetingDetail(Routes.meetingDetail),
  createMeeting(Routes.createMeeting),
  conversations(Routes.conversations),
  chat(Routes.chat),
  events(Routes.events),
  adminDashboard(Routes.adminDashboard);

  const AppRoute(this.path);
  final String path;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == Routes.login;
      final isRegistering = state.matchedLocation == Routes.register;
      final isForgotPassword = state.matchedLocation == Routes.forgotPassword;
      final isOnboarding = state.matchedLocation == Routes.onboarding;
      final isSplash = state.matchedLocation == Routes.splash;

      // If not logged in and trying to access protected routes
      if (!isLoggedIn &&
          !isLoggingIn &&
          !isRegistering &&
          !isForgotPassword &&
          !isOnboarding &&
          !isSplash) {
        return Routes.login;
      }

      // If logged in and trying to access auth routes
      if (isLoggedIn && (isLoggingIn || isRegistering || isOnboarding)) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const placeholder.OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const placeholder.ForgotPasswordScreen(),
      ),
      // Protected routes wrapped in shell
      ShellRoute(
        builder: (context, state, child) => MainNavigationWrapper(
          currentLocation: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.listings,
            builder: (context, state) => const ListingsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ListingDetailScreen(listingId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.createListing,
            builder: (context, state) => const CreateListingScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: Routes.editProfile,
            name: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: Routes.help,
            name: 'help',
            builder: (context, state) => const HelpScreen(),
          ),
          GoRoute(
            path: Routes.support,
            name: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: Routes.requests,
            name: 'requests',
            builder: (context, state) => const RequestsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'request-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RequestDetailScreen(requestId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.meetings,
            name: 'meetings',
            builder: (context, state) => const MeetingsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-meeting',
                builder: (context, state) => const CreateMeetingScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'meeting-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MeetingDetailScreen(meetingId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.conversations,
            name: 'conversations',
            builder: (context, state) => const ConversationsScreen(),
          ),
          GoRoute(
            path: '/chat/:id',
            name: 'chat',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ConversationDetailScreen(conversationId: id);
            },
          ),
          GoRoute(
            path: Routes.events,
            name: 'events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: Routes.adminDashboard,
            name: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
