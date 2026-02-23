import 'package:flutter/material.dart';

const _primaryBlue = Color(0xFF3A86FF);
const _accentPink = Color(0xFFFFE6F0);

/// Badge showing remaining add-on count.
class AddonBalanceBadge extends StatelessWidget {
  const AddonBalanceBadge({
    super.key,
    required this.count,
    this.size = 20,
  });

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.2,
      ),
      decoration: BoxDecoration(
        color: _accentPink.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: size * 0.7,
          fontWeight: FontWeight.w600,
          color: _primaryBlue,
        ),
      ),
    );
  }
}
