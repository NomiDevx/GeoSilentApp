import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/zone_model.dart';

class StorageService {
  static const String _zonesKey = 'silent_zones';
  static const String _isAppActiveKey = 'is_app_active';

  // Save zones to SharedPreferences
  static Future<void> saveZones(List<SilentZone> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final zonesJson = zones.map((zone) => zone.toJson()).toList();
    await prefs.setString(_zonesKey, json.encode(zonesJson));
  }

  // Load zones from SharedPreferences
  static Future<List<SilentZone>> loadZones() async {
    final prefs = await SharedPreferences.getInstance();
    final zonesJson = prefs.getString(_zonesKey);
    
    if (zonesJson == null) return [];
    
    final List<dynamic> decoded = json.decode(zonesJson);
    return decoded.map((json) => SilentZone.fromJson(json)).toList();
  }

  // Save app active status
  static Future<void> saveAppStatus(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAppActiveKey, isActive);
  }

  // Load app active status
  static Future<bool> loadAppStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAppActiveKey) ?? true;
  }
}