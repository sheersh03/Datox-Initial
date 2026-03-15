import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../config/env.dart';

/// RevenueCat product identifiers.
enum SubscriptionTier {
  premiumPlus,
  premium,
  boost,
}

extension SubscriptionTierExt on SubscriptionTier {
  String get productId {
    switch (this) {
      case SubscriptionTier.premiumPlus:
        return Env.premiumPlusProductId;
      case SubscriptionTier.premium:
        return Env.premiumProductId;
      case SubscriptionTier.boost:
        return Env.boostProductId;
    }
  }
}

/// Result of a purchase attempt.
enum PurchaseResult {
  success,
  cancelled,
  error,
}

/// Repository for RevenueCat subscription operations.
/// No business logic - pure data access.
class SubscriptionRepository {
  static bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    final apiKey = Env.revenueCatApiKey;
    if (apiKey.isEmpty && !kReleaseMode) {
      return;
    }
    if (apiKey.isEmpty) return;

    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (_) {}
  }

  Future<List<StoreProduct>> getProducts() async {
    await _ensureConfigured();
    if (!_configured) return [];

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        final products = <StoreProduct>[];
        final seen = <String>{};
        for (final package in current.availablePackages) {
          final product = package.storeProduct;
          if (seen.add(product.identifier)) {
            products.add(product);
          }
        }
        if (products.isNotEmpty) {
          return products;
        }
      }
    } catch (_) {}

    try {
      final ids = [
        Env.premiumPlusProductId,
        Env.premiumProductId,
        Env.boostProductId,
      ];
      return await Purchases.getProducts(ids);
    } catch (_) {
      return [];
    }
  }

  Future<List<StoreProduct>> getAddonProducts() async {
    await _ensureConfigured();
    if (!_configured) return [];

    try {
      final ids = [
        Env.spotlightProductId,
        Env.superSwipeProductId,
        Env.boostProductId,
        Env.complimentProductId,
        Env.extendProductId,
        Env.rematchProductId,
        Env.backtrackProductId,
        Env.travelModeProductId,
        Env.incognitoProductId,
      ];
      return await Purchases.getProducts(ids);
    } catch (_) {
      return [];
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    await _ensureConfigured();
    if (!_configured) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (_) {
      return null;
    }
  }

  Future<PurchaseResult> purchase(StoreProduct product) async {
    await _ensureConfigured();
    if (!_configured) return PurchaseResult.error;

    try {
      await Purchases.purchaseStoreProduct(product);
      return PurchaseResult.success;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled;
      }
      return PurchaseResult.error;
    } catch (_) {
      return PurchaseResult.error;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    await _ensureConfigured();
    if (!_configured) return null;
    try {
      return await Purchases.restorePurchases();
    } catch (_) {
      return null;
    }
  }
}
