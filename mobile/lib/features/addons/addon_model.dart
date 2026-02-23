import 'addon_type.dart';

/// User entitlement for an add-on.
class AddonEntitlement {
  const AddonEntitlement({
    required this.addonType,
    required this.remainingCount,
    this.expiresAt,
    required this.isActive,
  });

  final AddonType addonType;
  final int remainingCount;
  final DateTime? expiresAt;
  final bool isActive;

  factory AddonEntitlement.fromJson(Map<String, dynamic> json) {
    final typeStr = json['addon_type'] as String? ?? '';
    AddonType parseType(String s) {
      for (final t in AddonType.values) {
        if (t.value == s) return t;
      }
      return AddonType.spotlight;
    }

    return AddonEntitlement(
      addonType: parseType(typeStr),
      remainingCount: json['remaining_count'] as int? ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  bool get canUse => isActive && (remainingCount > 0 || !addonType.isConsumable);
}
