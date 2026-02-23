import 'package:flutter/foundation.dart';

import 'addon_model.dart';
import 'addon_type.dart';
import 'addon_service.dart';

/// Controller for add-on state. Use with ValueNotifier or similar.
class AddonController extends ChangeNotifier {
  AddonController() {
    _load();
  }

  final _service = AddonService();
  List<AddonEntitlement> _entitlements = [];
  bool _loading = false;
  String? _error;

  List<AddonEntitlement> get entitlements => List.unmodifiable(_entitlements);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> _load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _entitlements = await _service.getEntitlements();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Refresh entitlements (e.g. after purchase, pull-to-refresh).
  Future<void> refresh() => _load();

  AddonEntitlement? entitlementFor(AddonType type) {
    try {
      return _entitlements.firstWhere((e) => e.addonType == type);
    } catch (_) {
      return null;
    }
  }

  bool canUse(AddonType type) {
    final ent = entitlementFor(type);
    return ent?.canUse ?? false;
  }

  int remainingCount(AddonType type) {
    final ent = entitlementFor(type);
    if (ent == null) return 0;
    if (!type.isConsumable) return ent.isActive ? 1 : 0;
    return ent.remainingCount;
  }

  Future<bool> useAddon(AddonType type, {Map<String, dynamic>? metadata}) async {
    if (!canUse(type)) return false;
    try {
      await _service.useAddon(type, metadata: metadata);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}
