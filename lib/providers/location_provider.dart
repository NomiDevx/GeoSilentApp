import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';
import '../models/zone_model.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  bool _isInSilentZone = false;
  SilentZone? _currentSilentZone;
  StreamSubscription<Position>? _locationSubscription;
  String _locationName = 'Locating...';

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get isInSilentZone => _isInSilentZone;
  SilentZone? get currentSilentZone => _currentSilentZone;

  // Start location tracking
  Future<void> startTracking(BuildContext context) async {
    if (_isTracking) return;

    final hasPermission = await LocationService.requestLocationPermission(context);
    if (!hasPermission) {
      throw Exception('Location permission not granted');
    }

    _isTracking = true;
    notifyListeners();

    _locationSubscription = LocationService.getLocationStream().listen(
      (position) {
        _currentPosition = position;
        _updateLocationName(position);
        notifyListeners();
      },
      onError: (error) {
        print('Location stream error: $error');
        stopTracking();
      },
    );
  }

  // Stop location tracking
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  // Check if in any silent zone
  void checkZones(List<SilentZone> zones) {
    if (_currentPosition == null) return;

    for (var zone in zones) {
      if (zone.isActive &&
          LocationService.isInZone(
            lat: _currentPosition!.latitude,
            lng: _currentPosition!.longitude,
            zone: zone,
          )) {
        _isInSilentZone = true;
        _currentSilentZone = zone;
        notifyListeners();
        return;
      }
    }

    _isInSilentZone = false;
    _currentSilentZone = null;
    notifyListeners();
  }

  // Get formatted location string
  String get formattedLocation {
    if (_currentPosition == null) return 'Unknown';
    return '${_currentPosition!.latitude.toStringAsFixed(4)}, '
        '${_currentPosition!.longitude.toStringAsFixed(4)}';
  }

  // Update location name via reverse geocoding
  Future<void> _updateLocationName(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final name = [place.street, place.subLocality, place.locality]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        
        _locationName = name.isNotEmpty ? name : 'Unknown Location';
        notifyListeners();
      }
    } catch (e) {
      _locationName = '${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)}';
      notifyListeners();
    }
  }

  // Get location name (address or coordinates)
  String get locationName {
    if (_currentPosition == null) return 'No Location';
    return _locationName;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
