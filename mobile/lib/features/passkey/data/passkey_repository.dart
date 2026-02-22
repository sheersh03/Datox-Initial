import '../../../core/network/api_client.dart';

class PasskeyRepository {
  static Future<Map<String, dynamic>> startRegistration({String? userName}) async {
    final res = await ApiClient.dio.post(
      '/passkey/register/start',
      data: userName != null ? {'user_name': userName} : {},
    );
    return res.data as Map<String, dynamic>;
  }

  static Future<void> finishRegistration(Map<String, dynamic> credential) async {
    await ApiClient.dio.post(
      '/passkey/register/finish',
      data: {'credential': credential},
    );
  }

  static Future<bool> hasPasskey() async {
    final res = await ApiClient.dio.get('/passkey/has');
    return res.data['has_passkey'] as bool? ?? false;
  }
}
