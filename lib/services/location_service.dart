import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/zone_model.dart';

class LocationService {
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    // On web, permission_handler does not support locationWhenInUse.
    // The browser handles the location prompt automatically via geolocator.
    if (kIsWeb) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          final requested = await Geolocator.requestPermission();
          return requested == LocationPermission.whileInUse ||
              requested == LocationPermission.always;
        }
        return permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      } catch (e) {
        return false;
      }
    }

    // Native platforms: use permission_handler
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Check if location is within a zone
  static bool isInZone({
    required double lat,
    required double lng,
    required SilentZone zone,
  }) {
    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      zone.latitude,
      zone.longitude,
    );
    return distance <= zone.radius;
  }

  // Get distance to zone
  static double getDistanceToZone({
    required double lat,
    required double lng,
    required SilentZone zone,
  }) {
    return Geolocator.distanceBetween(
      lat,
      lng,
      zone.latitude,
      zone.longitude,
    );
  }

  // Start location updates
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10 meters
      ),
    );
  }
}