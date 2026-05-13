import 'package:flutter/material.dart';
import 'package:geo_silent/services/location_service.dart';
import '../services/firestore_service.dart';
import '../models/zone_model.dart';
import '../services/ringer_service.dart';

class ZoneProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<SilentZone> _zones = [];
  SilentZone? _currentZone;
  bool _isLoading = false;
  String? _errorMessage;
  // Track last known position to re-check after zone changes
  double? _lastLat;
  double? _lastLng;

  List<SilentZone> get zones => _zones;
  SilentZone? get currentZone => _currentZone;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get activeZonesCount => _zones.where((zone) => zone.isActive).length;
  bool _dndChecked = false; // Ensures DND prompt only shows once

  // Initialize zones for user
  Future<void> initializeZones(String userId) async {
    _isLoading = true;
    notifyListeners();

    // Request DND permission once per app session (not inside stream)
    if (!_dndChecked) {
      _dndChecked = true;
      final hasDnd = await RingerService.hasDndPermission();
      if (!hasDnd) {
        await RingerService.requestDndPermission();
      }
    }

    try {
      _firestoreService.getUserZones(userId).listen((zones) async {
        _zones = zones;
        RingerService.startService(_zones);
        
        // Immediately re-evaluate location against the newly fetched zones
        if (_lastLat != null && _lastLng != null) {
          checkCurrentLocation(_lastLat!, _lastLng!);
        }
        
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add zone
  Future<bool> addZone(SilentZone zone) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.addZone(zone);
      // Note: the firestore stream will also update _zones shortly, but we update locally for instant feedback
      _zones.add(zone);
      await RingerService.updateZones(_zones);
      
      // Immediately check if we are already inside the newly added zone
      if (_lastLat != null && _lastLng != null) {
        checkCurrentLocation(_lastLat!, _lastLng!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update zone
  Future<bool> updateZone(SilentZone zone) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateZone(zone);
      final index = _zones.indexWhere((z) => z.id == zone.id);
      if (index != -1) {
        _zones[index] = zone;
      }
      // Push updated zones to the background service
      await RingerService.updateZones(_zones);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete zone
  Future<bool> deleteZone(String zoneId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.deleteZone(zoneId);
      _zones.removeWhere((zone) => zone.id == zoneId);
      await RingerService.updateZones(_zones);

      // If the deleted zone was the current active one, clear it
      if (_currentZone?.id == zoneId) {
        _currentZone = null;
        await RingerService.setNormalMode();
      }

      // Re-evaluate location just in case
      if (_lastLat != null && _lastLng != null) {
        checkCurrentLocation(_lastLat!, _lastLng!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle zone active status
  Future<void> toggleZoneActive(String zoneId) async {
    final zone = _zones.firstWhere((z) => z.id == zoneId);
    final updatedZone = SilentZone(
      id: zone.id,
      userId: zone.userId,
      name: zone.name,
      type: zone.type,
      latitude: zone.latitude,
      longitude: zone.longitude,
      radius: zone.radius,
      soundProfile: zone.soundProfile,
      isActive: !zone.isActive,
      createdAt: zone.createdAt,
      updatedAt: DateTime.now(),
      schedule: zone.schedule,
      isRepeating: zone.isRepeating,
    );
    await updateZone(updatedZone);

    // If the deactivated zone was the current zone, clear it and restore ringer
    if (_currentZone?.id == zoneId && !updatedZone.isActive) {
      _currentZone = null;
      await RingerService.setNormalMode();
      notifyListeners();
    }

    // Re-check location with updated zones
    if (_lastLat != null && _lastLng != null) {
      checkCurrentLocation(_lastLat!, _lastLng!);
    }
  }

  // Check current location against zones and apply appropriate ringer mode
  void checkCurrentLocation(double lat, double lng) {
    _lastLat = lat;
    _lastLng = lng;

    SilentZone? matchedZone;
    for (var zone in _zones) {
      if (zone.isActive && LocationService.isInZone(lat: lat, lng: lng, zone: zone)) {
        matchedZone = zone;
        break;
      }
    }

    if (matchedZone != null && _currentZone?.id != matchedZone.id) {
      // Entered a new zone — apply its sound profile
      _currentZone = matchedZone;
      RingerService.applyProfile(matchedZone.soundProfile);
      notifyListeners();
    } else if (matchedZone == null && _currentZone != null) {
      // Left all zones — restore normal mode
      _currentZone = null;
      RingerService.setNormalMode();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}