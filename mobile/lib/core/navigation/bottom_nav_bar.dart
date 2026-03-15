import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _dockBg = Color(0xFFF7F9FD);
const _inactiveButton = Color(0xFFE5E7EB);
const _activeBubble = Color(0xFFFFFFFF);
const _inactiveIcon = Color(0xFFFFFFFF);
const _activeIcon = Color(0xFF7D828D);
const _track = Color(0xFF9A9A9A);

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavItemData>[
    _NavItemData(
      materialIcon: Icons.search_rounded,
      semanticsLabel: 'Discovery',
    ),
    _NavItemData(
      icon: FontAwesomeIcons.solidHeart,
      semanticsLabel: 'Liked You',
    ),
    _NavItemData(
      materialIcon: Icons.layers_rounded,
      semanticsLabel: 'Cypher',
    ),
    _NavItemData(
      icon: FontAwesomeIcons.comment,
      semanticsLabel: 'Chats',
    ),
    _NavItemData(
      icon: FontAwesomeIcons.user,
      semanticsLabel: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: _dockBg,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 110,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const bubbleSize = 82.0;
              const buttonSize = 54.0;
              final slotWidth = constraints.maxWidth / _items.length;
              final bubbleLeft =
                  (slotWidth * currentIndex) + ((slotWidth - bubbleSize) / 2);

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: bubbleLeft,
                    top: 12,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      width: bubbleSize,
                      height: bubbleSize,
                      decoration: BoxDecoration(
                        color: _activeBubble,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.92, end: 1),
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: _NavGlyph(
                          item: _items[currentIndex],
                          color: _activeIcon,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      children: List.generate(_items.length, (index) {
                        final isSelected = index == currentIndex;
                        return Expanded(
                          child: Center(
                            child: _NavTapTarget(
                              onTap: () => onTap(index),
                              semanticsLabel: _items[index].semanticsLabel,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                opacity: isSelected ? 0 : 1,
                                child: IgnorePointer(
                                  ignoring: isSelected,
                                  child: Container(
                                    width: buttonSize,
                                    height: buttonSize,
                                    decoration: const BoxDecoration(
                                      color: _inactiveButton,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: _NavGlyph(
                                      item: _items[index],
                                      color: _inactiveIcon,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.92),
                    child: Container(
                      width: 300,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _track,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavTapTarget extends StatelessWidget {
  const _NavTapTarget({
    required this.child,
    required this.onTap,
    required this.semanticsLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _NavGlyph extends StatelessWidget {
  const _NavGlyph({
    required this.item,
    required this.color,
    required this.size,
  });

  final _NavItemData item;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (item.materialIcon != null) {
      return Icon(
        item.materialIcon,
        size: size,
        color: color,
      );
    }

    return FaIcon(
      item.icon!,
      size: size,
      color: color,
    );
  }
}

class _NavItemData {
  const _NavItemData({
    this.icon,
    this.materialIcon,
    required this.semanticsLabel,
  }) : assert(
         icon != null || materialIcon != null,
         'Either icon or materialIcon must be provided.',
       );

  final IconData? icon;
  final IconData? materialIcon;
  final String semanticsLabel;
}
