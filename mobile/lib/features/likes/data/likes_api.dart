import '../../../core/network/api_client.dart';

class LikesApi {
  /// Fetches users who liked the current user.
  /// Throws ApiException with code PAYWALL_REQUIRED (402) if subscription required.
  static Future<List<dynamic>> whoLikedMe() async {
    final res = await ApiClient.dio.get('/discovery/likes');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      final items = (data['data'] as Map)['items'];
      return items is List ? List<dynamic>.from(items) : [];
    }
    return [];
  }
}
