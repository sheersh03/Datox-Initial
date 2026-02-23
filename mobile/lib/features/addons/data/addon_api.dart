import '../../../core/network/api_client.dart';

/// API client for add-on entitlements.
class AddonApi {
  static Future<List<Map<String, dynamic>>> getEntitlements() async {
    final res = await ApiClient.dio.get('/addons/entitlements');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      final items = data['data']['items'];
      if (items is List) {
        return items
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
    return [];
  }

  static Future<void> useAddon(String addonType, {Map<String, dynamic>? metadata}) async {
    await ApiClient.dio.post('/addons/use', data: {
      'addon_type': addonType,
      'metadata': metadata,
    });
  }
}
