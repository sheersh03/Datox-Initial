// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get paywallClose => 'Fechar paywall';

  @override
  String get paywallTitle => 'Fazer upgrade';

  @override
  String get paywallHeroGeneralTitle => 'Desbloqueie seus melhores matches';

  @override
  String get paywallHeroGeneralSubtitle => 'Veja quem curtiu você, tenha curtidas ilimitadas e ganhe destaque com ferramentas premium.';

  @override
  String get paywallHeroLikeLimitTitle => 'Você usou suas curtidas grátis';

  @override
  String get paywallHeroLikeLimitSubtitle => 'Faça upgrade agora para continuar curtindo sem esperar a renovação de amanhã.';

  @override
  String get paywallHeroLikedYouTitle => 'Veja quem curtiu você';

  @override
  String get paywallHeroLikedYouSubtitle => 'Faça upgrade para revelar quem já está interessado em você e combinar mais rápido.';

  @override
  String get paywallBestValue => 'MELHOR CUSTO-BENEFÍCIO';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'Todos os recursos Premium com visibilidade prioritária e vantagens exclusivas.';

  @override
  String get paywallPremiumDescription => 'Curtidas ilimitadas, ver quem curtiu você e ferramentas de match mais inteligentes.';

  @override
  String get paywallBoostDescription => 'Seja visto por mais pessoas agora e aumente suas chances de match.';

  @override
  String paywallSubscribe(Object price) {
    return 'Assinar · $price';
  }

  @override
  String get paywallActive => 'Ativo';

  @override
  String get paywallProductsTitle => 'Escolha seu plano';

  @override
  String get paywallProductsUnavailable => 'As opções de assinatura aparecerão quando estiverem disponíveis. Tente novamente em breve.';

  @override
  String get paywallDevPlaceholder => 'O RevenueCat ainda não está configurado nesta versão. Os preços aparecerão quando a chave da API for definida.';

  @override
  String get paywallRetry => 'Tentar novamente';

  @override
  String get paywallFeaturesTitle => 'O que você recebe';

  @override
  String get paywallFeatureUnlimitedLikes => 'Curtidas ilimitadas para você não perder o ritmo.';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'Veja quem já curtiu você e dê match instantaneamente.';

  @override
  String get paywallFeatureBoostVisibility => 'Impulsione seu perfil para se destacar em feeds movimentados.';

  @override
  String get paywallFeatureAdvancedFilters => 'Use filtros avançados para encontrar pessoas mais compatíveis.';

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallRestoreSuccess => 'Compras restauradas';

  @override
  String get paywallPurchaseSuccess => 'Compra realizada com sucesso';

  @override
  String get paywallPurchaseFailed => 'A compra falhou. Tente novamente.';

  @override
  String get paywallTermsOfService => 'Termos de serviço';

  @override
  String get paywallPrivacyPolicy => 'Política de privacidade';

  @override
  String get paywallSupport => 'Suporte';

  @override
  String get paywallSubscriptionTerms => 'As assinaturas são renovadas automaticamente, a menos que sejam canceladas antes do fim do período atual. Você pode gerenciar ou cancelar sua assinatura nas configurações da App Store ou Play Store.';

  @override
  String get paywallSecurePayments => 'Pagamentos protegidos por Apple / Google';

  @override
  String get paywallCancelAnytime => 'Cancele quando quiser';

  @override
  String get paywallLinkFailed => 'Não foi possível abrir o link agora.';
}
