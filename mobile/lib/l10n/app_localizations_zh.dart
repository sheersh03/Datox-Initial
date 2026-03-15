// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get paywallClose => '关闭付费墙';

  @override
  String get paywallTitle => '升级';

  @override
  String get paywallHeroGeneralTitle => '解锁更好的匹配';

  @override
  String get paywallHeroGeneralSubtitle => '查看谁喜欢了你，获得无限点赞，并通过高级功能脱颖而出。';

  @override
  String get paywallHeroLikeLimitTitle => '你今天的免费点赞已用完';

  @override
  String get paywallHeroLikeLimitSubtitle => '立即升级，无需等到明天重置即可继续点赞。';

  @override
  String get paywallHeroLikedYouTitle => '查看谁喜欢了你';

  @override
  String get paywallHeroLikedYouSubtitle => '升级后即可查看已经对你感兴趣的人，并更快匹配。';

  @override
  String get paywallBestValue => '超值推荐';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => '包含所有 Premium 功能，并提供优先曝光和专属权益。';

  @override
  String get paywallPremiumDescription => '无限点赞、查看谁喜欢了你，以及更智能的匹配工具。';

  @override
  String get paywallBoostDescription => '立即被更多人看到，提升你的匹配机会。';

  @override
  String paywallSubscribe(Object price) {
    return '订阅 · $price';
  }

  @override
  String get paywallActive => '已开通';

  @override
  String get paywallProductsTitle => '选择你的方案';

  @override
  String get paywallProductsUnavailable => '订阅选项可用后将显示在这里，请稍后再试。';

  @override
  String get paywallDevPlaceholder => '此构建尚未配置 RevenueCat。设置 API Key 后将显示价格。';

  @override
  String get paywallRetry => '重试';

  @override
  String get paywallFeaturesTitle => '你将获得';

  @override
  String get paywallFeatureUnlimitedLikes => '无限点赞，不错过任何节奏。';

  @override
  String get paywallFeatureSeeWhoLikedYou => '查看谁已经喜欢你，并立即匹配。';

  @override
  String get paywallFeatureBoostVisibility => '提升你的资料曝光，在拥挤的信息流中脱颖而出。';

  @override
  String get paywallFeatureAdvancedFilters => '使用高级筛选找到更合适的人。';

  @override
  String get paywallRestorePurchases => '恢复购买';

  @override
  String get paywallRestoreSuccess => '购买已恢复';

  @override
  String get paywallPurchaseSuccess => '购买成功';

  @override
  String get paywallPurchaseFailed => '购买失败，请重试。';

  @override
  String get paywallTermsOfService => '服务条款';

  @override
  String get paywallPrivacyPolicy => '隐私政策';

  @override
  String get paywallSupport => '支持';

  @override
  String get paywallSubscriptionTerms => '订阅会自动续费，除非你在当前计费周期结束前取消。你可以在 App Store 或 Play Store 设置中管理或取消订阅。';

  @override
  String get paywallSecurePayments => '由 Apple / Google 提供安全支付';

  @override
  String get paywallCancelAnytime => '随时取消';

  @override
  String get paywallLinkFailed => '当前无法打开链接。';
}
