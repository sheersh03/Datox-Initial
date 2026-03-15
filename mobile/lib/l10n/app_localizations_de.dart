// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get paywallClose => 'Paywall schließen';

  @override
  String get paywallTitle => 'Upgrade';

  @override
  String get paywallHeroGeneralTitle => 'Schalte deine besten Matches frei';

  @override
  String get paywallHeroGeneralSubtitle => 'Sieh, wer dich gelikt hat, erhalte unbegrenzte Likes und stich mit Premium-Tools heraus.';

  @override
  String get paywallHeroLikeLimitTitle => 'Du hast deine kostenlosen Likes verbraucht';

  @override
  String get paywallHeroLikeLimitSubtitle => 'Upgrade jetzt, um ohne Warten auf das morgige Reset weiterzuliken.';

  @override
  String get paywallHeroLikedYouTitle => 'Sieh, wer dich gelikt hat';

  @override
  String get paywallHeroLikedYouSubtitle => 'Upgrade, um zu sehen, wer bereits Interesse an dir hat, und matche schneller.';

  @override
  String get paywallBestValue => 'BESTER WERT';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'Alle Premium-Funktionen plus bevorzugte Sichtbarkeit und exklusive Vorteile.';

  @override
  String get paywallPremiumDescription => 'Unbegrenzte Likes, sehen wer dich gelikt hat und intelligentere Matching-Tools.';

  @override
  String get paywallBoostDescription => 'Werde jetzt von mehr Menschen gesehen und erhöhe deine Match-Chancen.';

  @override
  String paywallSubscribe(Object price) {
    return 'Abonnieren · $price';
  }

  @override
  String get paywallActive => 'Aktiv';

  @override
  String get paywallProductsTitle => 'Wähle deinen Plan';

  @override
  String get paywallProductsUnavailable => 'Abo-Optionen werden angezeigt, sobald sie verfügbar sind. Bitte versuche es bald erneut.';

  @override
  String get paywallDevPlaceholder => 'RevenueCat ist in diesem Build noch nicht konfiguriert. Preise erscheinen, sobald dein API-Schlüssel gesetzt ist.';

  @override
  String get paywallRetry => 'Erneut versuchen';

  @override
  String get paywallFeaturesTitle => 'Was du bekommst';

  @override
  String get paywallFeatureUnlimitedLikes => 'Unbegrenzte Likes, damit du nie an Schwung verlierst.';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'Sieh, wer dich bereits gelikt hat, und matche sofort.';

  @override
  String get paywallFeatureBoostVisibility => 'Booste dein Profil, um in vollen Feeds herauszustechen.';

  @override
  String get paywallFeatureAdvancedFilters => 'Nutze erweiterte Filter, um passendere Menschen zu finden.';

  @override
  String get paywallRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get paywallRestoreSuccess => 'Käufe wiederhergestellt';

  @override
  String get paywallPurchaseSuccess => 'Kauf erfolgreich';

  @override
  String get paywallPurchaseFailed => 'Kauf fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get paywallTermsOfService => 'Nutzungsbedingungen';

  @override
  String get paywallPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get paywallSupport => 'Support';

  @override
  String get paywallSubscriptionTerms => 'Abonnements verlängern sich automatisch, sofern sie nicht vor Ende des aktuellen Abrechnungszeitraums gekündigt werden. Du kannst dein Abo in den Einstellungen des App Store oder Play Store verwalten oder kündigen.';

  @override
  String get paywallSecurePayments => 'Zahlungen gesichert durch Apple / Google';

  @override
  String get paywallCancelAnytime => 'Jederzeit kündbar';

  @override
  String get paywallLinkFailed => 'Link kann derzeit nicht geöffnet werden.';
}
