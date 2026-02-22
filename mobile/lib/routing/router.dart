import 'package:go_router/go_router.dart';
import '../core/navigation/navigation_service.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/phone_entry_screen.dart';
import '../features/auth/ui/otp_verify_screen.dart';
import '../features/passkey/ui/create_passkey_screen.dart';
import '../features/discovery/ui/discovery_screen.dart';
import '../features/chat/ui/chat_screen.dart';
import '../features/matches/ui/matches_screen.dart';
import '../features/onboarding/ui/profile_setup_screen.dart';
import '../features/location/ui/location_permission_screen.dart';
import '../features/paywall/ui/paywall_screen.dart';

final appRouter = GoRouter(
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/phone-login', builder: (_, __) => const PhoneEntryScreen()),
    GoRoute(
      path: '/create-passkey',
      builder: (_, __) => const CreatePasskeyScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      builder: (_, s) {
        final phone = s.extra as String?;
        if (phone == null || phone.isEmpty) {
          return const PhoneEntryScreen();
        }
        return OtpVerifyScreen(phone: phone);
      },
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (_, __) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/location-permission',
      builder: (_, __) => const LocationPermissionScreen(),
    ),
    GoRoute(
      path: '/discover',
      builder: (_, s) {
        final skip = s.uri.queryParameters['skip_location'] == '1';
        return DiscoveryScreen(skipLocationRedirect: skip);
      },
    ),
    GoRoute(path: '/matches', builder: (_, __) => MatchesScreen()),
    GoRoute(
      path: '/chat/:id',
      builder: (_, s) => ChatScreen(matchId: s.pathParameters['id']!),
    ),
    GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
  ],
);
