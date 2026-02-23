import 'package:purchases_flutter/purchases_flutter.dart';

import '../data/subscription_repository.dart';

/// Subscription tier for UI display.
enum SubscriptionPlan {
  premiumPlus,
  premium,
  boost,
}

/// Service layer for subscription logic.
/// UI → Controller → SubscriptionService → Repository
class SubscriptionService {
  final _repo = SubscriptionRepository();

  Future<List<StoreProduct>> getProducts() => _repo.getProducts();

  Future<CustomerInfo?> getCustomerInfo() => _repo.getCustomerInfo();

  Future<PurchaseResult> purchase(StoreProduct product) =>
      _repo.purchase(product);

  Future<CustomerInfo?> restorePurchases() => _repo.restorePurchases();

  /// Returns true if user has any premium entitlement.
  Future<bool> hasPremiumEntitlement() async {
    final info = await getCustomerInfo();
    if (info == null) return false;
    return info.entitlements.active.isNotEmpty;
  }

  /// Returns true if user has the given product/entitlement.
  Future<bool> hasEntitlement(String entitlementId) async {
    final info = await getCustomerInfo();
    if (info == null) return false;
    return info.entitlements.active.containsKey(entitlementId);
  }
}
