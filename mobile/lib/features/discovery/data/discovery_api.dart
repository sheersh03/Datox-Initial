import '../../../core/network/api_client.dart';

class DiscoveryApi {
  static Future<List<dynamic>> candidates() async {
    final res = await ApiClient.dio.get('/discovery/candidates');
    return res.data['data']['items'];
  }

  static Future<void> swipe(String userId, bool like) async {
    await ApiClient.dio.post('/discovery/swipe', data: {
      'to_user_id': userId,
      'action': like ? 'like' : 'pass',
    });
  }
}
