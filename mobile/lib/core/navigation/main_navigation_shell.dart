import 'package:flutter/material.dart';
import '../../features/chat/ui/chat_list_screen.dart';
import '../../features/cypher/ui/cypher_screen.dart';
import '../../features/discovery/ui/discovery_screen.dart';
import '../../features/likes/ui/likes_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import 'bottom_nav_bar.dart';

/// Main navigation shell with bottom bar and IndexedStack.
/// Preserves screen state when switching tabs. No route stacking.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.currentIndex,
    this.skipLocationRedirect = false,
  });

  final int currentIndex;

  /// When true, discovery screens show error instead of redirecting to location.
  final bool skipLocationRedirect;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;
  late final PageController _pageController;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pageController = PageController(initialPage: widget.currentIndex);
    _screens = [
      DiscoveryScreen(skipLocationRedirect: widget.skipLocationRedirect),
      const LikesScreen(),
      const CypherScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void didUpdateWidget(covariant MainNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex = widget.currentIndex;
      _pageController.jumpToPage(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onTabTapped(int index) async {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  static const _bg = Color(0xFFF4F8FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
