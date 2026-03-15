// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get paywallClose => 'Fermer le paywall';

  @override
  String get paywallTitle => 'Passer à l’offre supérieure';

  @override
  String get paywallHeroGeneralTitle => 'Débloquez vos meilleurs matchs';

  @override
  String get paywallHeroGeneralSubtitle => 'Découvrez qui vous a liké, obtenez des likes illimités et démarquez-vous avec des outils premium.';

  @override
  String get paywallHeroLikeLimitTitle => 'Vous avez utilisé vos likes gratuits';

  @override
  String get paywallHeroLikeLimitSubtitle => 'Passez à l’offre supérieure pour continuer à liker sans attendre la réinitialisation de demain.';

  @override
  String get paywallHeroLikedYouTitle => 'Découvrez qui vous a liké';

  @override
  String get paywallHeroLikedYouSubtitle => 'Passez à l’offre supérieure pour voir qui s’intéresse déjà à vous et matcher plus vite.';

  @override
  String get paywallBestValue => 'MEILLEURE OFFRE';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'Toutes les fonctionnalités Premium avec visibilité prioritaire et avantages exclusifs.';

  @override
  String get paywallPremiumDescription => 'Likes illimités, voir qui vous a liké et outils de matching avancés.';

  @override
  String get paywallBoostDescription => 'Soyez vu par plus de personnes dès maintenant et augmentez vos chances de match.';

  @override
  String paywallSubscribe(Object price) {
    return 'S’abonner · $price';
  }

  @override
  String get paywallActive => 'Actif';

  @override
  String get paywallProductsTitle => 'Choisissez votre formule';

  @override
  String get paywallProductsUnavailable => 'Les options d’abonnement apparaîtront dès qu’elles seront disponibles. Réessayez bientôt.';

  @override
  String get paywallDevPlaceholder => 'RevenueCat n’est pas encore configuré sur cette build. Les prix apparaîtront une fois la clé API définie.';

  @override
  String get paywallRetry => 'Réessayer';

  @override
  String get paywallFeaturesTitle => 'Ce que vous obtenez';

  @override
  String get paywallFeatureUnlimitedLikes => 'Des likes illimités pour ne jamais perdre votre élan.';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'Voyez qui vous a déjà liké et matchez instantanément.';

  @override
  String get paywallFeatureBoostVisibility => 'Boostez votre profil pour ressortir dans les flux chargés.';

  @override
  String get paywallFeatureAdvancedFilters => 'Utilisez des filtres avancés pour trouver des personnes plus pertinentes.';

  @override
  String get paywallRestorePurchases => 'Restaurer les achats';

  @override
  String get paywallRestoreSuccess => 'Achats restaurés';

  @override
  String get paywallPurchaseSuccess => 'Achat réussi';

  @override
  String get paywallPurchaseFailed => 'L’achat a échoué. Veuillez réessayer.';

  @override
  String get paywallTermsOfService => 'Conditions d’utilisation';

  @override
  String get paywallPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get paywallSupport => 'Assistance';

  @override
  String get paywallSubscriptionTerms => 'Les abonnements se renouvellent automatiquement sauf annulation avant la fin de la période en cours. Vous pouvez gérer ou annuler votre abonnement dans les réglages de l’App Store ou du Play Store.';

  @override
  String get paywallSecurePayments => 'Paiements sécurisés par Apple / Google';

  @override
  String get paywallCancelAnytime => 'Résiliable à tout moment';

  @override
  String get paywallLinkFailed => 'Impossible d’ouvrir le lien pour le moment.';
}
