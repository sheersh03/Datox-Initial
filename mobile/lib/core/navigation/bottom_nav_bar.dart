import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Theme colors for bottom nav (premium light blue + pink).
const _bg = Color(0xFFF4F8FF);
const _activeIcon = Color(0xFF3A86FF);
const _inactiveIcon = Color(0xFF9CA3AF);
const _pinkAccent = Color(0xFFFFE6F0);
const _textPrimary = Color(0xFF1A1A1A);

enum NavTab {
  profile,
  discover,
  people,
  likedYou,
  chats,
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const int _profileIndex = 0;
  static const int _discoverIndex = 1;
  static const int _peopleIndex = 2;
  static const int _likedYouIndex = 3;
  static const int _chatsIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: FontAwesomeIcons.user,
                label: 'Profile',
                isSelected: currentIndex == _profileIndex,
                onTap: () => onTap(_profileIndex),
              ),
              _NavItem(
                icon: FontAwesomeIcons.compass,
                label: 'Discover',
                isSelected: currentIndex == _discoverIndex,
                onTap: () => onTap(_discoverIndex),
              ),
              _NavItem(
                icon: FontAwesomeIcons.heart,
                label: 'People',
                isSelected: currentIndex == _peopleIndex,
                isCenter: true,
                onTap: () => onTap(_peopleIndex),
              ),
              _NavItem(
                icon: FontAwesomeIcons.solidHeart,
                label: 'Liked You',
                isSelected: currentIndex == _likedYouIndex,
                onTap: () => onTap(_likedYouIndex),
              ),
              _NavItem(
                icon: FontAwesomeIcons.comment,
                label: 'Chats',
                isSelected: currentIndex == _chatsIndex,
                onTap: () => onTap(_chatsIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCenter = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _activeIcon : _inactiveIcon;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCenter && isSelected)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _pinkAccent.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(icon, size: 22, color: _activeIcon),
                  )
                else
                  FaIcon(
                    icon,
                    size: isCenter ? 24 : 22,
                    color: color,
                  ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? _textPrimary : _inactiveIcon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
