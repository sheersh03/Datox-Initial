// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get paywallClose => 'पेवल बंद करें';

  @override
  String get paywallTitle => 'अपग्रेड करें';

  @override
  String get paywallHeroGeneralTitle => 'अपने बेहतरीन मैच अनलॉक करें';

  @override
  String get paywallHeroGeneralSubtitle => 'देखें किसने आपको लाइक किया, अनलिमिटेड लाइक्स पाएं और प्रीमियम टूल्स से अलग दिखें।';

  @override
  String get paywallHeroLikeLimitTitle => 'आपने आज के मुफ्त लाइक्स इस्तेमाल कर लिए हैं';

  @override
  String get paywallHeroLikeLimitSubtitle => 'अभी अपग्रेड करें ताकि आप कल के रीसेट का इंतज़ार किए बिना लाइक कर सकें।';

  @override
  String get paywallHeroLikedYouTitle => 'देखें किसने आपको लाइक किया';

  @override
  String get paywallHeroLikedYouSubtitle => 'अपग्रेड करके उन लोगों को देखें जो पहले से आपमें रुचि रखते हैं और जल्दी मैच करें।';

  @override
  String get paywallBestValue => 'सबसे बेहतर मूल्य';

  @override
  String get paywallPremiumPlusBadge => 'PREMIUM+';

  @override
  String get paywallPremiumBadge => 'PREMIUM';

  @override
  String get paywallBoostBadge => 'BOOST';

  @override
  String get paywallPremiumPlusDescription => 'सभी Premium फीचर्स के साथ प्राथमिक दृश्यता और एक्सक्लूसिव फायदे।';

  @override
  String get paywallPremiumDescription => 'अनलिमिटेड लाइक्स, किसने आपको लाइक किया यह देखना, और बेहतर मैचिंग टूल्स।';

  @override
  String get paywallBoostDescription => 'अभी ज्यादा लोगों तक पहुंचें और अपने मैच की संभावना बढ़ाएं।';

  @override
  String paywallSubscribe(Object price) {
    return 'सब्सक्राइब करें · $price';
  }

  @override
  String get paywallActive => 'सक्रिय';

  @override
  String get paywallProductsTitle => 'अपना प्लान चुनें';

  @override
  String get paywallProductsUnavailable => 'सब्सक्रिप्शन विकल्प उपलब्ध होने पर यहां दिखेंगे। कृपया थोड़ी देर बाद फिर कोशिश करें।';

  @override
  String get paywallDevPlaceholder => 'इस बिल्ड में RevenueCat अभी कॉन्फ़िगर नहीं है। API key सेट होने पर कीमतें दिखेंगी।';

  @override
  String get paywallRetry => 'फिर प्रयास करें';

  @override
  String get paywallFeaturesTitle => 'आपको क्या मिलेगा';

  @override
  String get paywallFeatureUnlimitedLikes => 'अनलिमिटेड लाइक्स ताकि आपका मोमेंटम बना रहे।';

  @override
  String get paywallFeatureSeeWhoLikedYou => 'देखें किसने पहले ही आपको लाइक किया और तुरंत मैच करें।';

  @override
  String get paywallFeatureBoostVisibility => 'भीड़भाड़ वाले फ़ीड में अलग दिखने के लिए अपना प्रोफ़ाइल बूस्ट करें।';

  @override
  String get paywallFeatureAdvancedFilters => 'और अधिक प्रासंगिक लोगों को खोजने के लिए एडवांस फ़िल्टर्स इस्तेमाल करें।';

  @override
  String get paywallRestorePurchases => 'खरीदारी बहाल करें';

  @override
  String get paywallRestoreSuccess => 'खरीदारी बहाल हो गई';

  @override
  String get paywallPurchaseSuccess => 'खरीदारी सफल रही';

  @override
  String get paywallPurchaseFailed => 'खरीदारी विफल रही। कृपया फिर प्रयास करें।';

  @override
  String get paywallTermsOfService => 'सेवा की शर्तें';

  @override
  String get paywallPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get paywallSupport => 'सहायता';

  @override
  String get paywallSubscriptionTerms => 'जब तक आप वर्तमान बिलिंग अवधि के समाप्त होने से पहले रद्द नहीं करते, सब्सक्रिप्शन अपने आप नवीनीकृत होगा। आप App Store या Play Store सेटिंग्स में अपनी सदस्यता प्रबंधित या रद्द कर सकते हैं।';

  @override
  String get paywallSecurePayments => 'भुगतान Apple / Google द्वारा सुरक्षित';

  @override
  String get paywallCancelAnytime => 'कभी भी रद्द करें';

  @override
  String get paywallLinkFailed => 'अभी लिंक नहीं खुल सका।';
}
