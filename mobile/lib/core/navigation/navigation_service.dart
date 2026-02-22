import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static void goToProfileSetup() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final router = GoRouter.of(context);
    final currentPath = router.routeInformationProvider.value.uri.path;
    if (currentPath == '/profile-setup') return;
    router.go('/profile-setup');
  }
}
