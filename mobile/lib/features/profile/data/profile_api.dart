import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ProfileApi {
  static Future<Map<String, dynamic>?> getMe() async {
    try {
      final res = await ApiClient.dio.get('/profile/me');
      final data = res.data;
      if (data is Map && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  static Future<bool> exists() async {
    try {
      await ApiClient.dio.get('/profile/me');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  static Future<void> upsertBasic({
    required String name,
    required int birthYear,
    required String gender,
    required String intent,
    String? bio,
    String? city,
  }) async {
    await ApiClient.dio.post('/profile', data: {
      'name': name,
      'birth_year': birthYear,
      'gender': gender,
      'intent': intent,
      'bio': bio,
      'city': city,
      'age_min': 18,
      'age_max': 40,
      'distance_km': 20,
    });
  }

  static Future<void> updateLocation(double lat, double lng) async {
    await ApiClient.dio.patch('/profile/location', data: {'lat': lat, 'lng': lng});
  }
}
