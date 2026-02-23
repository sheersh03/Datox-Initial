import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../config/env.dart';
import '../../paywall/data/subscription_repository.dart';
import '../addon_type.dart';

const _primaryBlue = Color(0xFF3A86FF);
const _cardBg = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);

/// Modal for purchasing an add-on via RevenueCat.
class AddonPurchaseModal extends StatefulWidget {
  const AddonPurchaseModal({
    super.key,
    required this.addonType,
    required this.onSuccess,
    this.onCancel,
  });

  final AddonType addonType;
  final VoidCallback onSuccess;
  final VoidCallback? onCancel;

  @override
  State<AddonPurchaseModal> createState() => _AddonPurchaseModalState();
}

class _AddonPurchaseModalState extends State<AddonPurchaseModal> {
  final _repo = SubscriptionRepository();
  StoreProduct? _product;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  static String _productIdFor(AddonType type) {
    switch (type) {
      case AddonType.spotlight:
        return Env.spotlightProductId;
      case AddonType.superSwipe:
        return Env.superSwipeProductId;
      case AddonType.boost:
        return Env.boostProductId;
      case AddonType.compliment:
        return Env.complimentProductId;
      case AddonType.extend:
        return Env.extendProductId;
      case AddonType.rematch:
        return Env.rematchProductId;
      case AddonType.backtrack:
        return Env.backtrackProductId;
      case AddonType.travelMode:
        return Env.travelModeProductId;
      case AddonType.incognito:
        return Env.incognitoProductId;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await _repo.getAddonProducts();
      final id = _productIdFor(widget.addonType);
      final p = products.where((x) => x.identifier == id).firstOrNull;
      if (mounted) {
        setState(() {
          _product = p;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load';
        });
      }
    }
  }

  Future<void> _purchase() async {
    if (_product == null || _purchasing) return;
    setState(() => _purchasing = true);
    try {
      final result = await _repo.purchase(_product!);
      if (!mounted) return;
      switch (result) {
        case PurchaseResult.success:
          Navigator.of(context).pop();
          widget.onSuccess();
          break;
        case PurchaseResult.cancelled:
          break;
        case PurchaseResult.error:
          setState(() => _error = 'Purchase failed');
          break;
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.addonType.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_product == null)
              const Text(
                'Product not available',
                style: TextStyle(color: _subtext),
              )
            else ...[
              Text(
                _product!.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: _subtext,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _purchasing ? null : _purchase,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _purchasing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Buy · ${_product!.priceString}'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel?.call();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
