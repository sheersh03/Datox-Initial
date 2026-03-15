import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('zh')
  ];

  /// No description provided for @paywallClose.
  ///
  /// In en, this message translates to:
  /// **'Close paywall'**
  String get paywallClose;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get paywallTitle;

  /// No description provided for @paywallHeroGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock your best matches'**
  String get paywallHeroGeneralTitle;

  /// No description provided for @paywallHeroGeneralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See who liked you, get unlimited likes, and stand out with premium tools.'**
  String get paywallHeroGeneralSubtitle;

  /// No description provided for @paywallHeroLikeLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'You’ve used your free likes'**
  String get paywallHeroLikeLimitTitle;

  /// No description provided for @paywallHeroLikeLimitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade now to keep liking without waiting for tomorrow’s reset.'**
  String get paywallHeroLikeLimitSubtitle;

  /// No description provided for @paywallHeroLikedYouTitle.
  ///
  /// In en, this message translates to:
  /// **'See who liked you'**
  String get paywallHeroLikedYouTitle;

  /// No description provided for @paywallHeroLikedYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to reveal your admirers and match faster with people already interested.'**
  String get paywallHeroLikedYouSubtitle;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get paywallBestValue;

  /// No description provided for @paywallPremiumPlusBadge.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM+'**
  String get paywallPremiumPlusBadge;

  /// No description provided for @paywallPremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get paywallPremiumBadge;

  /// No description provided for @paywallBoostBadge.
  ///
  /// In en, this message translates to:
  /// **'BOOST'**
  String get paywallBoostBadge;

  /// No description provided for @paywallPremiumPlusDescription.
  ///
  /// In en, this message translates to:
  /// **'All Premium features plus priority visibility and exclusive perks.'**
  String get paywallPremiumPlusDescription;

  /// No description provided for @paywallPremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlimited likes, see who liked you, and unlock smarter matching tools.'**
  String get paywallPremiumDescription;

  /// No description provided for @paywallBoostDescription.
  ///
  /// In en, this message translates to:
  /// **'Get seen by more people right now and increase your match chances.'**
  String get paywallBoostDescription;

  /// No description provided for @paywallSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe · {price}'**
  String paywallSubscribe(Object price);

  /// No description provided for @paywallActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get paywallActive;

  /// No description provided for @paywallProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get paywallProductsTitle;

  /// No description provided for @paywallProductsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Subscription options will appear when available. Please try again soon.'**
  String get paywallProductsUnavailable;

  /// No description provided for @paywallDevPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'RevenueCat is not configured in this build yet. Product prices will appear once your API key is set.'**
  String get paywallDevPlaceholder;

  /// No description provided for @paywallRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get paywallRetry;

  /// No description provided for @paywallFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get paywallFeaturesTitle;

  /// No description provided for @paywallFeatureUnlimitedLikes.
  ///
  /// In en, this message translates to:
  /// **'Unlimited likes so you never lose momentum.'**
  String get paywallFeatureUnlimitedLikes;

  /// No description provided for @paywallFeatureSeeWhoLikedYou.
  ///
  /// In en, this message translates to:
  /// **'See who already liked you and match instantly.'**
  String get paywallFeatureSeeWhoLikedYou;

  /// No description provided for @paywallFeatureBoostVisibility.
  ///
  /// In en, this message translates to:
  /// **'Boost your profile to stand out in busy feeds.'**
  String get paywallFeatureBoostVisibility;

  /// No description provided for @paywallFeatureAdvancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Use advanced filters to find more relevant people.'**
  String get paywallFeatureAdvancedFilters;

  /// No description provided for @paywallRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestorePurchases;

  /// No description provided for @paywallRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get paywallRestoreSuccess;

  /// No description provided for @paywallPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful'**
  String get paywallPurchaseSuccess;

  /// No description provided for @paywallPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get paywallPurchaseFailed;

  /// No description provided for @paywallTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get paywallTermsOfService;

  /// No description provided for @paywallPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get paywallPrivacyPolicy;

  /// No description provided for @paywallSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get paywallSupport;

  /// No description provided for @paywallSubscriptionTerms.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions renew automatically unless cancelled before the end of the current billing period. You can manage or cancel your subscription in your App Store or Play Store settings.'**
  String get paywallSubscriptionTerms;

  /// No description provided for @paywallSecurePayments.
  ///
  /// In en, this message translates to:
  /// **'Payments secured by Apple / Google'**
  String get paywallSecurePayments;

  /// No description provided for @paywallCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get paywallCancelAnytime;

  /// No description provided for @paywallLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open link right now.'**
  String get paywallLinkFailed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'hi', 'ja', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'ja': return AppLocalizationsJa();
    case 'pt': return AppLocalizationsPt();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
