import 'addon_model.dart';
import 'addon_type.dart';
import 'data/addon_api.dart';

/// Repository for add-on entitlements. No business logic.
class AddonRepository {
  Future<List<AddonEntitlement>> getEntitlements() async {
    final items = await AddonApi.getEntitlements();
    return items.map((e) => AddonEntitlement.fromJson(e)).toList();
  }

  Future<void> useAddon(AddonType type, {Map<String, dynamic>? metadata}) async {
    await AddonApi.useAddon(type.value, metadata: metadata);
  }
}
