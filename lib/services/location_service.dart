import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/zone_model.dart';

class LocationService {
  // Request location permission
  static Future<bool> requestLocationPermission(BuildContext context) async {
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

    // Check current permission status
    final hasForeground = await Permission.locationWhenInUse.status.isGranted;
    final hasBackground = await Permission.locationAlways.status.isGranted;

    if (hasForeground && hasBackground) {
      return true; // Already fully authorized, bypass disclosures and popups!
    }

    // 1. Show Prominent Disclosure Dialog for background location (only if foreground is not yet granted)
    if (!hasForeground) {
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildLocationDisclosureDialog(context),
      );

      if (accepted != true) return false;

      // 2. Request Foreground Location Permission
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    }

    // 3. Request Background Location Permission for background monitoring (only if not yet granted)
    final alwaysStatus = await Permission.locationAlways.status;
    if (!alwaysStatus.isGranted) {
      final proceedToAlways = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildBackgroundGuidanceDialog(context),
      );

      if (proceedToAlways == true) {
        final alwaysStatusRequest = await Permission.locationAlways.request();
        return alwaysStatusRequest.isGranted;
      }
    }

    return true;
  }

  static Widget _buildLocationDisclosureDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: Colors.blue.shade800,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Location Access Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Geo Silent collects location data to monitor proximity to your configured silent zones and automatically adjust your phone\'s sound profiles (Silent, Vibrate, or Normal).\n\nThis data is collected in the background, even when the app is closed, running in the background, or not in use, to ensure the ringer is adjusted instantly when you arrive.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Deny',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildBackgroundGuidanceDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security_rounded,
              color: Colors.amber.shade800,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Configure Background Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'To automatically silence your phone even when your screen is off or the app is closed, please select "Allow all the time" on the next Android settings page.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Not Now',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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