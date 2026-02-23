/// App configuration. Override via --dart-define or environment.
class Env {
  static const revenueCatApiKey =
      String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');

  static const premiumPlusProductId =
      String.fromEnvironment('PREMIUM_PLUS_PRODUCT_ID', defaultValue: 'premium_plus');
  static const premiumProductId =
      String.fromEnvironment('PREMIUM_PRODUCT_ID', defaultValue: 'premium');
  static const boostProductId =
      String.fromEnvironment('BOOST_PRODUCT_ID', defaultValue: 'boost');

  // Add-on product IDs
  static const spotlightProductId =
      String.fromEnvironment('SPOTLIGHT_PRODUCT_ID', defaultValue: 'spotlight');
  static const superSwipeProductId =
      String.fromEnvironment('SUPERSWIPE_PRODUCT_ID', defaultValue: 'super_swipe');
  static const complimentProductId =
      String.fromEnvironment('COMPLIMENT_PRODUCT_ID', defaultValue: 'compliment');
  static const extendProductId =
      String.fromEnvironment('EXTEND_PRODUCT_ID', defaultValue: 'extend');
  static const rematchProductId =
      String.fromEnvironment('REMATCH_PRODUCT_ID', defaultValue: 'rematch');
  static const backtrackProductId =
      String.fromEnvironment('BACKTRACK_PRODUCT_ID', defaultValue: 'backtrack');
  static const travelModeProductId =
      String.fromEnvironment('TRAVEL_MODE_PRODUCT_ID', defaultValue: 'travel_mode');
  static const incognitoProductId =
      String.fromEnvironment('INCOGNITO_PRODUCT_ID', defaultValue: 'incognito');
}
