import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../data/location_repository.dart';

enum LocationResult {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  timeout,
  unknown,
}

class LocationService {
  final _repo = LocationRepository();

  Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  Future<bool> isServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Fetches current position with timeout and fallback to last known position.
  /// Call only from controller/button handler, not from build().
  Future<LocationResult> requestAndSaveLocation({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // 1. Check location services enabled first
    final enabled = await isServiceEnabled();
    if (!enabled) {
      return LocationResult.serviceDisabled;
    }

    // 2. Permission flow: check → request if denied → handle deniedForever
    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return LocationResult.denied;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationResult.permanentlyDenied;
    }

    // 3. Fetch position with timeout + fallback
    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: timeout,
          ),
        );
      } on TimeoutException {
        // Fallback to last known (cached) position
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return LocationResult.timeout;
      }

      await _repo.saveLocation(position.latitude, position.longitude);
      return LocationResult.granted;
    } on LocationServiceDisabledException {
      return LocationResult.serviceDisabled;
    } on TimeoutException {
      return LocationResult.timeout;
    } on PermissionDeniedException {
      return LocationResult.denied;
    } catch (_) {
      return LocationResult.unknown;
    }
  }
}
