import 'package:flutter/material.dart';
import '../../features/chat/ui/chat_list_screen.dart';
import '../../features/discovery/ui/discovery_screen.dart';
import '../../features/likes/ui/likes_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import 'bottom_nav_bar.dart';

/// Main navigation shell with bottom bar and IndexedStack.
/// Preserves screen state when switching tabs. No route stacking.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    this.initialIndex = 2,
    this.skipLocationRedirect = false,
  });

  /// Default to People (center) tab.
  final int initialIndex;

  /// When true, discovery screens show error instead of redirecting to location.
  final bool skipLocationRedirect;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    final skip = widget.skipLocationRedirect;
    _screens = [
      const ProfileScreen(),
      DiscoveryScreen(skipLocationRedirect: skip),
      DiscoveryScreen(skipLocationRedirect: skip),
      const LikesScreen(),
      const ChatListScreen(),
    ];
  }


  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  static const _bg = Color(0xFFF4F8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
