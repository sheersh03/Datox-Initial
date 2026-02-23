import 'package:flutter/material.dart';

import '../addon_controller.dart';
import '../addon_type.dart';
import 'addon_balance_badge.dart';
import 'addon_purchase_modal.dart';

const _primaryBlue = Color(0xFF3A86FF);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);

/// Section displaying add-ons with balance and purchase CTA.
class AddonsSection extends StatefulWidget {
  const AddonsSection({
    super.key,
    required this.controller,
  });

  final AddonController controller;

  @override
  State<AddonsSection> createState() => _AddonsSectionState();
}

class _AddonsSectionState extends State<AddonsSection> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  void _showPurchaseModal(AddonType type) {
    showDialog(
      context: context,
      builder: (_) => AddonPurchaseModal(
        addonType: type,
        onSuccess: () => widget.controller.refresh(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add-ons',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AddonType.values.map((type) {
            final count = widget.controller.remainingCount(type);
            final canUse = widget.controller.canUse(type);
            return _AddonChip(
              addonType: type,
              remainingCount: count,
              canUse: canUse,
              onTap: () => _showPurchaseModal(type),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AddonChip extends StatelessWidget {
  const _AddonChip({
    required this.addonType,
    required this.remainingCount,
    required this.canUse,
    required this.onTap,
  });

  final AddonType addonType;
  final int remainingCount;
  final bool canUse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canUse ? _primaryBlue.withValues(alpha: 0.5) : _subtext.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                addonType.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary,
                ),
              ),
              if (addonType.isConsumable && remainingCount > 0) ...[
                const SizedBox(width: 8),
                AddonBalanceBadge(count: remainingCount, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
