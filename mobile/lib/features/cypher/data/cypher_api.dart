import '../../../core/network/api_client.dart';

/// API client for Cypher Mode.
class CypherApi {
  /// Check if user has Cypher access. Throws on 402 (paywall).
  static Future<bool> checkEntitlement() async {
    final res = await ApiClient.dio.get('/cypher/entitlement');
    final data = res.data;
    final d = data is Map ? data['data'] : null;
    if (d is Map) {
      return d['has_access'] == true;
    }
    return false;
  }

  /// Get current user's Cypher profile. Returns null if not created.
  static Future<Map<String, dynamic>?> getProfile() async {
    final res = await ApiClient.dio.get('/cypher/profile');
    final data = res.data;
    if (data is Map && data['data'] != null) {
      final d = data['data'];
      return d is Map ? Map<String, dynamic>.from(d) : null;
    }
    return null;
  }

  /// Create or update Cypher profile.
  static Future<void> upsertProfile({
    required String avatarId,
    required String anonymousUsername,
    List<String> interestTags = const [],
    List<String> fantasyKeywords = const [],
    String? headline,
    String? communicationPreferences,
    String? boundaries,
    String? mood,
    String? curiosityLevel,
    bool discoveryVisible = true,
  }) async {
    await ApiClient.dio.post('/cypher/profile', data: {
      'avatar_id': avatarId,
      'anonymous_username': anonymousUsername,
      'interest_tags': interestTags,
      'fantasy_keywords': fantasyKeywords,
      'headline': headline,
      'communication_preferences': communicationPreferences,
      'boundaries': boundaries,
      'mood': mood,
      'curiosity_level': curiosityLevel,
      'discovery_visible': discoveryVisible,
    });
  }

  /// Get Cypher discovery candidates.
  static Future<List<dynamic>> getCandidates({int limit = 20}) async {
    final res = await ApiClient.dio.get('/cypher/candidates', queryParameters: {'limit': limit});
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      final items = (data['data'] as Map)['items'];
      return items is List ? List<dynamic>.from(items) : [];
    }
    return [];
  }

  /// React to a candidate (like or pass).
  static Future<Map<String, dynamic>> react({
    required String toUserId,
    required bool isLike,
  }) async {
    final res = await ApiClient.dio.post('/cypher/react', data: {
      'to_user_id': toUserId,
      'is_like': isLike,
    });
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return {};
  }

  /// Get Cypher matches.
  static Future<List<dynamic>> getMatches({int limit = 50}) async {
    final res = await ApiClient.dio.get('/cypher/matches', queryParameters: {'limit': limit});
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      final items = (data['data'] as Map)['items'];
      return items is List ? List<dynamic>.from(items) : [];
    }
    return [];
  }
}
