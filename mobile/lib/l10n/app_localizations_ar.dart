// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get paywallClose => 'إغلاق شاشة الاشتراك';

  @override
  String get paywallTitle => 'الترقية';

  @override
  String get paywallHeroGeneralTitle => 'افتح أفضل المطابقات لك';

  @override
  String get paywallHeroGeneralSubtitle => 'اعرف من أعجب بك، واحصل على إعجابات غير محدودة، وتميّز بأدوات مميزة.';

  @override
  String get paywallHeroLikeLimitTitle => 'لقد استخدمت إعجاباتك المجانية';

  @override
  String get paywallHeroLikeLimitSubtitle => 'قم بالترقية الآن لتستمر في الإعجاب دون انتظار إعادة الضبط غداً.';

  @override
  String get paywallHeroLikedYouTitle => 'اعرف من أعجب بك';

  @override
  String get paywallHeroLikedYouSubtitle => 'قم بالترقية لرؤية الأشخاص المهتمين بك بالفعل والحصول على تطابق أسرع.';

  @override
  String get paywallBestValue => 'أفضل قيمة';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'كل مزايا Premium مع ظهور أولوية ومزايا حصرية إضافية.';

  @override
  String get paywallPremiumDescription => 'إعجابات غير محدودة، ومعرفة من أعجب بك، وأدوات مطابقة أكثر ذكاءً.';

  @override
  String get paywallBoostDescription => 'اجعل المزيد من الأشخاص يرونك الآن وزد فرص المطابقة.';

  @override
  String paywallSubscribe(Object price) {
    return 'اشترك · $price';
  }

  @override
  String get paywallActive => 'نشط';

  @override
  String get paywallProductsTitle => 'اختر خطتك';

  @override
  String get paywallProductsUnavailable => 'ستظهر خيارات الاشتراك عند توفرها. يرجى المحاولة مرة أخرى قريباً.';

  @override
  String get paywallDevPlaceholder => 'لم يتم إعداد RevenueCat في هذا الإصدار بعد. ستظهر الأسعار بعد ضبط مفتاح API.';

  @override
  String get paywallRetry => 'إعادة المحاولة';

  @override
  String get paywallFeaturesTitle => 'ما الذي ستحصل عليه';

  @override
  String get paywallFeatureUnlimitedLikes => 'إعجابات غير محدودة حتى لا تفقد الزخم.';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'اعرف من أعجب بك بالفعل وطابق فوراً.';

  @override
  String get paywallFeatureBoostVisibility => 'عزّز ملفك الشخصي لتبرز في القوائم المزدحمة.';

  @override
  String get paywallFeatureAdvancedFilters => 'استخدم فلاتر متقدمة للعثور على أشخاص أكثر ملاءمة.';

  @override
  String get paywallRestorePurchases => 'استعادة المشتريات';

  @override
  String get paywallRestoreSuccess => 'تمت استعادة المشتريات';

  @override
  String get paywallPurchaseSuccess => 'تم الشراء بنجاح';

  @override
  String get paywallPurchaseFailed => 'فشل الشراء. يرجى المحاولة مرة أخرى.';

  @override
  String get paywallTermsOfService => 'شروط الخدمة';

  @override
  String get paywallPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get paywallSupport => 'الدعم';

  @override
  String get paywallSubscriptionTerms => 'يتم تجديد الاشتراكات تلقائياً ما لم يتم إلغاؤها قبل نهاية فترة الفوترة الحالية. يمكنك إدارة اشتراكك أو إلغاؤه من إعدادات App Store أو Play Store.';

  @override
  String get paywallSecurePayments => 'المدفوعات مؤمنة بواسطة Apple / Google';

  @override
  String get paywallCancelAnytime => 'يمكن الإلغاء في أي وقت';

  @override
  String get paywallLinkFailed => 'تعذر فتح الرابط الآن.';
}
