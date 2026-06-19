import 'package:flutter/material.dart';
import 'package:geo_silent/services/location_service.dart';
import '../services/firestore_service.dart';
import '../models/zone_model.dart';
import '../services/ringer_service.dart';
import '../services/storage_service.dart';

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

    // 1. Load from local cache first for offline support and instant startup
    try {
      final cachedZones = await StorageService.loadZones();
      if (cachedZones.isNotEmpty) {
        _zones = cachedZones.where((z) => z.userId == userId).toList();
        await RingerService.startService(_zones);
        
        if (_lastLat != null && _lastLng != null) {
          checkCurrentLocation(_lastLat!, _lastLng!);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached zones: $e');
    }

    // 2. Setup Firestore listener for real-time sync
    try {
      _firestoreService.getUserZones(userId).listen((zones) async {
        _zones = zones;
        await StorageService.saveZones(_zones);
        await RingerService.startService(_zones);
        
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
    // Optimistically add zone locally to avoid any visual lag/spinner
    final previousZones = List<SilentZone>.from(_zones);
    
    if (!_zones.any((z) => z.id == zone.id)) {
      _zones.add(zone);
    }
    await StorageService.saveZones(_zones);
    await RingerService.updateZones(_zones);
    
    // Immediately check location
    if (_lastLat != null && _lastLng != null) {
      checkCurrentLocation(_lastLat!, _lastLng!);
    }
    notifyListeners();

    try {
      await _firestoreService.addZone(zone);
      return true;
    } catch (e) {
      // Rollback on failure
      _zones = previousZones;
      await StorageService.saveZones(_zones);
      await RingerService.updateZones(_zones);
      if (_lastLat != null && _lastLng != null) {
        checkCurrentLocation(_lastLat!, _lastLng!);
      }
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update zone
  Future<bool> updateZone(SilentZone zone) async {
    // Optimistically update zone locally
    final previousZones = List<SilentZone>.from(_zones);
    final index = _zones.indexWhere((z) => z.id == zone.id);
    
    if (index != -1) {
      _zones[index] = zone;
    } else {
      _zones.add(zone);
    }
    await StorageService.saveZones(_zones);
    await RingerService.updateZones(_zones);
    
    // Recheck location in case the radius or coordinates changed
    if (_lastLat != null && _lastLng != null) {
      checkCurrentLocation(_lastLat!, _lastLng!);
    }
    notifyListeners();

    try {
      await _firestoreService.updateZone(zone);
      return true;
    } catch (e) {
      // Rollback on failure
      _zones = previousZones;
      await StorageService.saveZones(_zones);
      await RingerService.updateZones(_zones);
      if (_lastLat != null && _lastLng != null) {
        checkCurrentLocation(_lastLat!, _lastLng!);
      }
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete zone
  Future<bool> deleteZone(String zoneId) async {
    // Optimistically delete zone locally
    final previousZones = List<SilentZone>.from(_zones);
    final previousCurrentZone = _currentZone;
    
    _zones.removeWhere((zone) => zone.id == zoneId);
    await StorageService.saveZones(_zones);
    await RingerService.updateZones(_zones);

    if (_currentZone?.id == zoneId) {
      _currentZone = null;
      await RingerService.setNormalMode();
    }

    if (_lastLat != null && _lastLng != null) {
      checkCurrentLocation(_lastLat!, _lastLng!);
    }
    notifyListeners();

    try {
      await _firestoreService.deleteZone(zoneId);
      return true;
    } catch (e) {
      // Rollback on failure
      _zones = previousZones;
      _currentZone = previousCurrentZone;
      await StorageService.saveZones(_zones);
      await RingerService.updateZones(_zones);
      if (_currentZone != null) {
        await RingerService.applyProfile(_currentZone!.soundProfile);
      } else {
        await RingerService.setNormalMode();
      }
      if (_lastLat != null && _lastLng != null) {
        checkCurrentLocation(_lastLat!, _lastLng!);
      }
      _errorMessage = e.toString();
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