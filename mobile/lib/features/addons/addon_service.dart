import 'addon_model.dart';
import 'addon_type.dart';
import 'addon_repository.dart';

/// Service layer for add-on logic.
/// UI → Controller → AddonService → Repository
class AddonService {
  final _repo = AddonRepository();

  Future<List<AddonEntitlement>> getEntitlements() =>
      _repo.getEntitlements();

  Future<void> useAddon(AddonType type, {Map<String, dynamic>? metadata}) =>
      _repo.useAddon(type, metadata: metadata);

  /// Get entitlement for a specific add-on type.
  Future<AddonEntitlement?> getEntitlement(AddonType type) async {
    final list = await getEntitlements();
    try {
      return list.firstWhere((e) => e.addonType == type);
    } catch (_) {
      return null;
    }
  }

  /// Check if user can use this add-on.
  Future<bool> canUse(AddonType type) async {
    final ent = await getEntitlement(type);
    return ent?.canUse ?? false;
  }

  /// Get remaining count for consumable add-on.
  Future<int> getRemainingCount(AddonType type) async {
    final ent = await getEntitlement(type);
    if (ent == null) return 0;
    if (!type.isConsumable) return ent.isActive ? 1 : 0;
    return ent.remainingCount;
  }
}
