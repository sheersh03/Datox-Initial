// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get paywallClose => 'Cerrar paywall';

  @override
  String get paywallTitle => 'Mejorar';

  @override
  String get paywallHeroGeneralTitle => 'Desbloquea tus mejores matches';

  @override
  String get paywallHeroGeneralSubtitle => 'Mira quién te dio like, obtén likes ilimitados y destaca con herramientas premium.';

  @override
  String get paywallHeroLikeLimitTitle => 'Ya usaste tus likes gratis';

  @override
  String get paywallHeroLikeLimitSubtitle => 'Mejora ahora para seguir dando like sin esperar al reinicio de mañana.';

  @override
  String get paywallHeroLikedYouTitle => 'Mira quién te dio like';

  @override
  String get paywallHeroLikedYouSubtitle => 'Mejora para revelar a quienes ya están interesados en ti y hacer match más rápido.';

  @override
  String get paywallBestValue => 'MEJOR VALOR';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'Todas las funciones Premium más visibilidad prioritaria y ventajas exclusivas.';

  @override
  String get paywallPremiumDescription => 'Likes ilimitados, ver quién te dio like y herramientas de match más inteligentes.';

  @override
  String get paywallBoostDescription => 'Haz que más personas te vean ahora mismo y aumenta tus posibilidades de match.';

  @override
  String paywallSubscribe(Object price) {
    return 'Suscribirse · $price';
  }

  @override
  String get paywallActive => 'Activo';

  @override
  String get paywallProductsTitle => 'Elige tu plan';

  @override
  String get paywallProductsUnavailable => 'Las opciones de suscripción aparecerán cuando estén disponibles. Inténtalo de nuevo pronto.';

  @override
  String get paywallDevPlaceholder => 'RevenueCat aún no está configurado en esta compilación. Los precios aparecerán cuando configures tu clave API.';

  @override
  String get paywallRetry => 'Reintentar';

  @override
  String get paywallFeaturesTitle => 'Lo que obtienes';

  @override
  String get paywallFeatureUnlimitedLikes => 'Likes ilimitados para que no pierdas impulso.';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'Mira quién ya te dio like y haz match al instante.';

  @override
  String get paywallFeatureBoostVisibility => 'Impulsa tu perfil para destacar en feeds concurridos.';

  @override
  String get paywallFeatureAdvancedFilters => 'Usa filtros avanzados para encontrar personas más relevantes.';

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallRestoreSuccess => 'Compras restauradas';

  @override
  String get paywallPurchaseSuccess => 'Compra realizada con éxito';

  @override
  String get paywallPurchaseFailed => 'La compra falló. Inténtalo de nuevo.';

  @override
  String get paywallTermsOfService => 'Términos del servicio';

  @override
  String get paywallPrivacyPolicy => 'Política de privacidad';

  @override
  String get paywallSupport => 'Soporte';

  @override
  String get paywallSubscriptionTerms => 'Las suscripciones se renuevan automáticamente a menos que las canceles antes del final del período actual. Puedes administrar o cancelar tu suscripción en la configuración de App Store o Play Store.';

  @override
  String get paywallSecurePayments => 'Pagos seguros por Apple / Google';

  @override
  String get paywallCancelAnytime => 'Cancela cuando quieras';

  @override
  String get paywallLinkFailed => 'No se puede abrir el enlace ahora mismo.';
}
