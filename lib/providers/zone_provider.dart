import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<SilentZone> get zones => _zones;
  SilentZone? get currentZone => _currentZone;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get activeZonesCount => _zones.where((zone) => zone.isActive).length;

  // Initialize zones for user
  Future<void> initializeZones(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestoreService.getUserZones(userId).listen((zones) async {
        _zones = zones;
        
        // Ensure we have DND permissions to silence the phone
        bool hasDnd = await RingerService.hasDndPermission();
        if (!hasDnd) {
          await RingerService.requestDndPermission();
        }

        RingerService.startService(_zones);
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
      _zones.add(zone);
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
  }

  // Check current location against zones
  void checkCurrentLocation(double lat, double lng) {
    for (var zone in _zones) {
      if (zone.isActive && LocationService.isInZone(lat: lat, lng: lng, zone: zone)) {
        _currentZone = zone;
        notifyListeners();
        return;
      }
    }
    _currentZone = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}