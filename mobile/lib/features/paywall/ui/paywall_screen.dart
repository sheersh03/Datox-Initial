import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/env.dart';
import '../../../l10n/app_localizations.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_service.dart';
import 'widgets/subscription_card.dart';

const _bg = Color(0xFFF4F8FF);
const _cardBg = Colors.white;
const _primaryBlue = Color(0xFF3A86FF);
const _accentPink = Color(0xFFFFE6F0);
const _textPrimary = Color(0xFF1A1A1A);
const _subtext = Color(0xFF6B7280);

enum PaywallContext {
  general,
  likeLimit,
  likedYou,
}

extension PaywallContextX on PaywallContext {
  static PaywallContext fromQuery(String? value) {
    switch (value) {
      case 'like_limit':
        return PaywallContext.likeLimit;
      case 'liked_you':
        return PaywallContext.likedYou;
      default:
        return PaywallContext.general;
    }
  }
}

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    super.key,
    this.contextType = PaywallContext.general,
  });

  final PaywallContext contextType;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _service = SubscriptionService();
  List<StoreProduct> _products = [];
  CustomerInfo? _customerInfo;
  bool _loading = true;
  bool _restoring = false;
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
    });
    try {
      final results = await Future.wait([
        _service.getProducts(),
        _service.getCustomerInfo(),
      ]);
      if (!mounted) return;
      setState(() {
        _products = _sortProducts(results[0] as List<StoreProduct>);
        _customerInfo = results[1] as CustomerInfo?;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<StoreProduct> _sortProducts(List<StoreProduct> products) {
    final rank = {
      Env.premiumPlusProductId: 0,
      Env.premiumProductId: 1,
      Env.boostProductId: 2,
    };
    final sorted = [...products];
    sorted.sort((a, b) {
      final ra = rank[a.identifier] ?? 99;
      final rb = rank[b.identifier] ?? 99;
      return ra.compareTo(rb);
    });
    return sorted;
  }

  bool _isActive(String productId) {
    return _customerInfo?.entitlements.active.containsKey(productId) ?? false;
  }

  Future<void> _purchase(StoreProduct product) async {
    if (_purchasingProductId != null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _purchasingProductId = product.identifier);
    try {
      final result = await _service.purchase(product);
      if (!mounted) return;
      switch (result) {
        case PurchaseResult.success:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.paywallPurchaseSuccess)),
          );
          Navigator.of(context).maybePop();
          break;
        case PurchaseResult.cancelled:
          break;
        case PurchaseResult.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.paywallPurchaseFailed)),
          );
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _purchasingProductId = null);
      }
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _restoring = true);
    try {
      final info = await _service.restorePurchases();
      if (!mounted) return;
      if (info != null) {
        setState(() => _customerInfo = info);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paywallRestoreSuccess)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _restoring = false);
      }
    }
  }

  Future<void> _openUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.paywallLinkFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hero = _heroCopy(l10n, widget.contextType);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _textPrimary,
                          ),
                          tooltip: l10n.paywallClose,
                        ),
                        const Spacer(),
                        Text(
                          l10n.paywallTitle,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _HeroCard(
                      title: hero.$1,
                      subtitle: hero.$2,
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : _buildProductSection(l10n),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paywallFeaturesTitle,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FeatureBullet(
                            icon: FontAwesomeIcons.heartCircleBolt,
                            label: l10n.paywallFeatureUnlimitedLikes,
                          ),
                          _FeatureBullet(
                            icon: FontAwesomeIcons.eye,
                            label: l10n.paywallFeatureSeeWhoLikedYou,
                          ),
                          _FeatureBullet(
                            icon: FontAwesomeIcons.rocket,
                            label: l10n.paywallFeatureBoostVisibility,
                          ),
                          _FeatureBullet(
                            icon: FontAwesomeIcons.sliders,
                            label: l10n.paywallFeatureAdvancedFilters,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegalRow(
                            label: l10n.paywallRestorePurchases,
                            onTap: _restoring ? null : _restore,
                            trailing: _restoring
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : null,
                          ),
                          const Divider(height: 28, color: _borderSubtle),
                          _LegalRow(
                            label: l10n.paywallTermsOfService,
                            onTap: () => _openUrl(Env.termsUrl),
                          ),
                          const Divider(height: 28, color: _borderSubtle),
                          _LegalRow(
                            label: l10n.paywallPrivacyPolicy,
                            onTap: () => _openUrl(Env.privacyUrl),
                          ),
                          const Divider(height: 28, color: _borderSubtle),
                          _LegalRow(
                            label: l10n.paywallSupport,
                            onTap: () => _openUrl(Env.supportUrl),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.paywallSubscriptionTerms,
                            style: const TextStyle(
                              color: _subtext,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _accentPink.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.paywallSecurePayments,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.paywallCancelAnytime,
                            style: const TextStyle(
                              color: _subtext,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(AppLocalizations l10n) {
    if (_products.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.paywallProductsTitle,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            kDebugMode && Env.revenueCatApiKey.isEmpty
                ? l10n.paywallDevPlaceholder
                : l10n.paywallProductsUnavailable,
            style: const TextStyle(
              color: _subtext,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.paywallRetry),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.paywallProductsTitle,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        for (final product in _products)
          SubscriptionCard(
            badge: _badgeFor(l10n, product.identifier),
            description: _descriptionFor(l10n, product.identifier),
            price: product.priceString,
            buttonLabel: _buttonLabelFor(
              l10n,
              product.priceString,
              _isActive(product.identifier),
            ),
            highlightLabel: product.identifier == Env.premiumPlusProductId
                ? l10n.paywallBestValue
                : null,
            isSelected: product.identifier == Env.premiumPlusProductId,
            isActive: _isActive(product.identifier),
            isLoading: _purchasingProductId == product.identifier,
            onTap: () => _purchase(product),
          ),
      ],
    );
  }

  String _badgeFor(AppLocalizations l10n, String id) {
    if (id == Env.premiumPlusProductId) return l10n.paywallPremiumPlusBadge;
    if (id == Env.premiumProductId) return l10n.paywallPremiumBadge;
    if (id == Env.boostProductId) return l10n.paywallBoostBadge;
    return id.toUpperCase();
  }

  String _descriptionFor(AppLocalizations l10n, String id) {
    if (id == Env.premiumPlusProductId) {
      return l10n.paywallPremiumPlusDescription;
    }
    if (id == Env.premiumProductId) {
      return l10n.paywallPremiumDescription;
    }
    if (id == Env.boostProductId) {
      return l10n.paywallBoostDescription;
    }
    return l10n.paywallPremiumDescription;
  }

  String _buttonLabelFor(AppLocalizations l10n, String price, bool isActive) {
    if (isActive) return l10n.paywallActive;
    return l10n.paywallSubscribe(price);
  }

  (String, String) _heroCopy(AppLocalizations l10n, PaywallContext contextType) {
    switch (contextType) {
      case PaywallContext.likeLimit:
        return (
          l10n.paywallHeroLikeLimitTitle,
          l10n.paywallHeroLikeLimitSubtitle,
        );
      case PaywallContext.likedYou:
        return (
          l10n.paywallHeroLikedYouTitle,
          l10n.paywallHeroLikedYouSubtitle,
        );
      case PaywallContext.general:
        return (
          l10n.paywallHeroGeneralTitle,
          l10n.paywallHeroGeneralSubtitle,
        );
    }
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3A86FF),
            Color(0xFF6EA8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            icon,
            size: 18,
            color: _primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: _subtext,
                ),
          ],
        ),
      ),
    );
  }
}

const _borderSubtle = Color(0xFFEDEDED);
