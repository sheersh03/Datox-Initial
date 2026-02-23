import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);
const _primaryBlue = Color(0xFF3A86FF);

/// Single row in the feature comparison table.
class FeatureRow extends StatelessWidget {
  const FeatureRow({
    super.key,
    required this.label,
    required this.premiumPlus,
    required this.premium,
    required this.boost,
  });

  final String label;
  final bool premiumPlus;
  final bool premium;
  final bool boost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: _textPrimary,
              ),
            ),
          ),
          _CheckCell(hasAccess: premiumPlus),
          _CheckCell(hasAccess: premium),
          _CheckCell(hasAccess: boost),
        ],
      ),
    );
  }
}

class _CheckCell extends StatelessWidget {
  const _CheckCell({required this.hasAccess});

  final bool hasAccess;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: hasAccess
            ? const FaIcon(
                FontAwesomeIcons.circleCheck,
                size: 18,
                color: _primaryBlue,
              )
            : Icon(
                Icons.remove,
                size: 18,
                color: _subtext.withValues(alpha: 0.5),
              ),
      ),
    );
  }
}
