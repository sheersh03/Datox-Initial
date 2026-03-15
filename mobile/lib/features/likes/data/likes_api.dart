import '../../../core/network/api_client.dart';

class LikesApi {
  /// Fetches users who liked the current user.
  static Future<List<dynamic>> whoLikedMe() async {
    final res = await ApiClient.dio.get('/likes/who-liked-me');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      final items = (data['data'] as Map)['items'];
      return items is List ? List<dynamic>.from(items) : [];
    }
    return [];
  }
}
