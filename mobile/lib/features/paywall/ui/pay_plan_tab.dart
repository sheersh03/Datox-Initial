import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../config/env.dart';
import '../../addons/addon_controller.dart';
import '../../addons/addon_type.dart';
import '../../addons/ui/addon_purchase_modal.dart';
import '../../addons/ui/addons_section.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_service.dart';
import 'widgets/feature_card.dart';
import 'widgets/feature_row.dart';
import 'widgets/subscription_card.dart';

const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);

void _showAddonModal(
  BuildContext context,
  AddonController controller,
  AddonType type,
) {
  showDialog(
    context: context,
    builder: (_) => AddonPurchaseModal(
      addonType: type,
      onSuccess: () => controller.refresh(),
    ),
  );
}

/// Pay plan tab content with subscription cards and feature comparison.
class PayPlanTab extends StatefulWidget {
  const PayPlanTab({super.key, required this.addonController});

  final AddonController addonController;

  @override
  State<PayPlanTab> createState() => _PayPlanTabState();
}

class _PayPlanTabState extends State<PayPlanTab> {
  final _service = SubscriptionService();
  List<StoreProduct> _products = [];
  CustomerInfo? _customerInfo;
  bool _loading = true;
  String? _purchasingProductId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _products = [];
      _customerInfo = null;
    });
    try {
      final results = await Future.wait([
        _service.getProducts(),
        _service.getCustomerInfo(),
      ]);
      if (mounted) {
        setState(() {
          _products = results[0] as List<StoreProduct>;
          _customerInfo = results[1] as CustomerInfo?;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  StoreProduct? _productById(String id) {
    try {
      return _products.firstWhere((p) => p.identifier == id);
    } catch (_) {
      return null;
    }
  }

  bool _hasEntitlement(String id) {
    return _customerInfo?.entitlements.active.containsKey(id) ?? false;
  }

  Future<void> _purchase(StoreProduct product) async {
    if (_purchasingProductId != null) return;
    setState(() => _purchasingProductId = product.identifier);
    try {
      final result = await _service.purchase(product);
      if (!mounted) return;
      switch (result) {
        case PurchaseResult.success:
          await _load();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Purchase successful')),
            );
          }
          break;
        case PurchaseResult.cancelled:
          break;
        case PurchaseResult.error:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Purchase failed. Please try again.')),
            );
          }
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _purchasingProductId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final premiumPlus = _productById(Env.premiumPlusProductId);
    final premium = _productById(Env.premiumProductId);
    final boost = _productById(Env.boostProductId);

    return RefreshIndicator(
      onRefresh: () async {
        await _load();
        widget.addonController.refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FeatureCard(
                  title: 'Spotlight',
                  description: 'Get more visibility',
                  onTap: () => _showAddonModal(context, widget.addonController, AddonType.spotlight),
                ),
                FeatureCard(
                  title: 'SuperSwipe',
                  description: 'Stand out with a super like',
                  onTap: () => _showAddonModal(context, widget.addonController, AddonType.superSwipe),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AddonsSection(controller: widget.addonController),
          const SizedBox(height: 24),
          const Text(
            'Choose your plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (premiumPlus != null)
            SubscriptionCard(
              badge: 'PREMIUM+',
              description: 'All Premium features plus exclusive perks.',
              price: premiumPlus.priceString,
              isSelected: _hasEntitlement(Env.premiumPlusProductId),
              isActive: _hasEntitlement(Env.premiumPlusProductId),
              isLoading: _purchasingProductId == premiumPlus.identifier,
              onTap: () => _purchase(premiumPlus),
            ),
          if (premium != null)
            SubscriptionCard(
              badge: 'PREMIUM',
              description: 'Unlimited likes, see who liked you, and more.',
              price: premium.priceString,
              isSelected: _hasEntitlement(Env.premiumProductId),
              isActive: _hasEntitlement(Env.premiumProductId),
              isLoading: _purchasingProductId == premium.identifier,
              onTap: () => _purchase(premium),
            ),
          if (boost != null)
            SubscriptionCard(
              badge: 'BOOST',
              description: 'Get seen by more people right now.',
              price: boost.priceString,
              isSelected: _hasEntitlement(Env.boostProductId),
              isActive: _hasEntitlement(Env.boostProductId),
              isLoading: _purchasingProductId == boost.identifier,
              onTap: () => _purchase(boost),
            ),
          if (_products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Subscription options will appear here.',
                style: TextStyle(color: _subtext),
              ),
            ),
          const SizedBox(height: 32),
          const Text(
            'What you get',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _FeatureComparisonTable(),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () async {
              final info = await _service.restorePurchases();
              if (mounted && info != null) {
                await _load();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchases restored')),
                );
              }
            },
            child: const Text('Restore purchases'),
          ),
        ],
        ),
      ),
    );
  }
}

class _FeatureComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Premium+',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _subtext,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _subtext,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Boost',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _subtext,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const FeatureRow(
            label: 'Exclusive photo insights',
            premiumPlus: true,
            premium: false,
            boost: false,
          ),
          const FeatureRow(
            label: 'Fast track your likes',
            premiumPlus: true,
            premium: true,
            boost: false,
          ),
          const FeatureRow(
            label: 'Stand out every day',
            premiumPlus: true,
            premium: true,
            boost: true,
          ),
          const FeatureRow(
            label: 'Unlimited likes',
            premiumPlus: true,
            premium: true,
            boost: false,
          ),
          const FeatureRow(
            label: 'See who liked you',
            premiumPlus: true,
            premium: true,
            boost: false,
          ),
          const FeatureRow(
            label: 'Advanced filters',
            premiumPlus: true,
            premium: true,
            boost: false,
          ),
          const FeatureRow(
            label: 'Incognito mode',
            premiumPlus: true,
            premium: false,
            boost: false,
          ),
        ],
      ),
    );
  }
}
