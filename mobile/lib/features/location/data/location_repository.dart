import '../../profile/data/profile_api.dart';

/// Saves location to backend. No permission or device logic.
class LocationRepository {
  Future<void> saveLocation(double lat, double lng) async {
    await ProfileApi.updateLocation(lat, lng);
  }
}
