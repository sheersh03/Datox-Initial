// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get paywallClose => 'ペイウォールを閉じる';

  @override
  String get paywallTitle => 'アップグレード';

  @override
  String get paywallHeroGeneralTitle => '最高のマッチを解放しよう';

  @override
  String get paywallHeroGeneralSubtitle => 'あなたにいいねした人を確認し、無制限いいねとプレミアム機能でさらに目立てます。';

  @override
  String get paywallHeroLikeLimitTitle => '本日の無料いいねを使い切りました';

  @override
  String get paywallHeroLikeLimitSubtitle => '今すぐアップグレードして、明日のリセットを待たずにいいねを続けましょう。';

  @override
  String get paywallHeroLikedYouTitle => 'あなたをいいねした相手を確認';

  @override
  String get paywallHeroLikedYouSubtitle => 'アップグレードして、すでに興味を持っている相手を表示し、より早くマッチしましょう。';

  @override
  String get paywallBestValue => 'おすすめ';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'Premiumの全機能に加え、優先表示と限定特典が利用できます。';

  @override
  String get paywallPremiumDescription => '無制限いいね、いいねした相手の表示、より賢いマッチング機能を利用できます。';

  @override
  String get paywallBoostDescription => '今すぐより多くの人に表示され、マッチの可能性を高めます。';

  @override
  String paywallSubscribe(Object price) {
    return '登録する · $price';
  }

  @override
  String get paywallActive => '利用中';

  @override
  String get paywallProductsTitle => 'プランを選択';

  @override
  String get paywallProductsUnavailable => 'サブスクリプションオプションは利用可能になり次第表示されます。しばらくしてからお試しください。';

  @override
  String get paywallDevPlaceholder => 'このビルドではRevenueCatがまだ設定されていません。APIキーを設定すると価格が表示されます。';

  @override
  String get paywallRetry => '再試行';

  @override
  String get paywallFeaturesTitle => '利用できる特典';

  @override
  String get paywallFeatureUnlimitedLikes => '勢いを止めない無制限いいね。';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'すでにあなたにいいねした人を見て、すぐにマッチできます。';

  @override
  String get paywallFeatureBoostVisibility => '混み合うフィードでもプロフィールを目立たせます。';

  @override
  String get paywallFeatureAdvancedFilters => '高度なフィルターでより相性の良い相手を探せます。';

  @override
  String get paywallRestorePurchases => '購入を復元';

  @override
  String get paywallRestoreSuccess => '購入を復元しました';

  @override
  String get paywallPurchaseSuccess => '購入が完了しました';

  @override
  String get paywallPurchaseFailed => '購入に失敗しました。もう一度お試しください。';

  @override
  String get paywallTermsOfService => '利用規約';

  @override
  String get paywallPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get paywallSupport => 'サポート';

  @override
  String get paywallSubscriptionTerms => 'サブスクリプションは現在の請求期間が終了する前にキャンセルしない限り自動更新されます。App StoreまたはPlay Storeの設定で管理・解約できます。';

  @override
  String get paywallSecurePayments => 'Apple / Google による安全な決済';

  @override
  String get paywallCancelAnytime => 'いつでも解約可能';

  @override
  String get paywallLinkFailed => '現在リンクを開けません。';
}
