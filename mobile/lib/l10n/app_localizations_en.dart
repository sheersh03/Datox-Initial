// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get paywallClose => 'Close paywall';

  @override
  String get paywallTitle => 'Upgrade';

  @override
  String get paywallHeroGeneralTitle => 'Unlock your best matches';

  @override
  String get paywallHeroGeneralSubtitle => 'See who liked you, get unlimited likes, and stand out with premium tools.';

  @override
  String get paywallHeroLikeLimitTitle => 'You’ve used your free likes';

  @override
  String get paywallHeroLikeLimitSubtitle => 'Upgrade now to keep liking without waiting for tomorrow’s reset.';

  @override
  String get paywallHeroLikedYouTitle => 'See who liked you';

  @override
  String get paywallHeroLikedYouSubtitle => 'Upgrade to reveal your admirers and match faster with people already interested.';

  @override
  String get paywallBestValue => 'BEST VALUE';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'All Premium features plus priority visibility and exclusive perks.';

  @override
  String get paywallPremiumDescription => 'Unlimited likes, see who liked you, and unlock smarter matching tools.';

  @override
  String get paywallBoostDescription => 'Get seen by more people right now and increase your match chances.';

  @override
  String paywallSubscribe(Object price) {
    return 'Subscribe · $price';
  }

  @override
  String get paywallActive => 'Active';

  @override
  String get paywallProductsTitle => 'Choose your plan';

  @override
  String get paywallProductsUnavailable => 'Subscription options will appear when available. Please try again soon.';

  @override
  String get paywallDevPlaceholder => 'RevenueCat is not configured in this build yet. Product prices will appear once your API key is set.';

  @override
  String get paywallRetry => 'Retry';

  @override
  String get paywallFeaturesTitle => 'What you get';

  @override
  String get paywallFeatureUnlimitedLikes => 'Unlimited likes so you never lose momentum.';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'See who already liked you and match instantly.';

  @override
  String get paywallFeatureBoostVisibility => 'Boost your profile to stand out in busy feeds.';

  @override
  String get paywallFeatureAdvancedFilters => 'Use advanced filters to find more relevant people.';

  @override
  String get paywallRestorePurchases => 'Restore purchases';

  @override
  String get paywallRestoreSuccess => 'Purchases restored';

  @override
  String get paywallPurchaseSuccess => 'Purchase successful';

  @override
  String get paywallPurchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get paywallTermsOfService => 'Terms of Service';

  @override
  String get paywallPrivacyPolicy => 'Privacy Policy';

  @override
  String get paywallSupport => 'Support';

  @override
  String get paywallSubscriptionTerms => 'Subscriptions renew automatically unless cancelled before the end of the current billing period. You can manage or cancel your subscription in your App Store or Play Store settings.';

  @override
  String get paywallSecurePayments => 'Payments secured by Apple / Google';

  @override
  String get paywallCancelAnytime => 'Cancel anytime';

  @override
  String get paywallLinkFailed => 'Unable to open link right now.';
}
