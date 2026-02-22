import '../../../core/network/api_client.dart';

class AuthApi {
  static Future<void> sendOtp(String phone) async {
    await ApiClient.dio.post('/auth/otp/send', data: {'phone': phone});
  }

  static Future<String> verifyOtp(String phone, String code) async {
    final res = await ApiClient.dio.post(
      '/auth/otp/verify',
      data: {'phone': phone, 'code': code},
    );
    return res.data['access_token'];
  }
}
