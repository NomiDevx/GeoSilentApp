import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/zone_model.dart';

/// Platform-channel wrapper that controls the Android ringer mode and
/// manages the background foreground service.
class RingerService {
  static const MethodChannel _ringerChannel =
      MethodChannel('com.geo_silent/ringer');
  static const MethodChannel _serviceChannel =
      MethodChannel('com.geo_silent/service');

  // ── Ringer mode control ───────────────────────────────────────────────

  /// Silences the phone ringer completely.
  static Future<bool> setSilentMode() async {
    try {
      await _ringerChannel.invokeMethod('setSilentMode');
      return true;
    } on PlatformException catch (e) {
      print('RingerService.setSilentMode error: ${e.message}');
      return false;
    }
  }

  /// Sets the phone to vibrate-only mode.
  static Future<bool> setVibrateMode() async {
    try {
      await _ringerChannel.invokeMethod('setVibrateMode');
      return true;
    } on PlatformException catch (e) {
      print('RingerService.setVibrateMode error: ${e.message}');
      return false;
    }
  }

  /// Restores normal ringer mode.
  static Future<bool> setNormalMode() async {
    try {
      await _ringerChannel.invokeMethod('setNormalMode');
      return true;
    } on PlatformException catch (e) {
      print('RingerService.setNormalMode error: ${e.message}');
      return false;
    }
  }

  /// Gets the current ringer mode (0=silent, 1=vibrate, 2=normal).
  static Future<int> getCurrentMode() async {
    try {
      final mode = await _ringerChannel.invokeMethod<int>('getCurrentMode');
      return mode ?? 2;
    } catch (_) {
      return 2;
    }
  }

  /// Returns true if Do Not Disturb permission is granted.
  static Future<bool> hasDndPermission() async {
    try {
      final result = await _ringerChannel.invokeMethod<bool>('hasDndPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens Android DND settings so the user can grant permission.
  static Future<void> requestDndPermission() async {
    try {
      await _ringerChannel.invokeMethod('requestDndPermission');
    } catch (_) {}
  }

  /// Applies the correct ringer mode for the given [SoundProfile].
  static Future<void> applyProfile(SoundProfile profile) async {
    switch (profile) {
      case SoundProfile.silent:
        await setSilentMode();
        break;
      case SoundProfile.vibration:
        await setVibrateMode();
        break;
      case SoundProfile.normal:
        await setNormalMode();
        break;
    }
  }

  // ── Background foreground service ─────────────────────────────────────

  /// Starts the Android foreground service with the current zone list.
  static Future<void> startService(List<SilentZone> zones) async {
    try {
      final zonesJson = jsonEncode(zones.map((z) => z.toJson()).toList());
      await _serviceChannel.invokeMethod('startService', {'zones': zonesJson});
    } catch (e) {
      print('RingerService.startService error: $e');
    }
  }

  /// Stops the background foreground service.
  static Future<void> stopService() async {
    try {
      await _serviceChannel.invokeMethod('stopService');
    } catch (e) {
      print('RingerService.stopService error: $e');
    }
  }

  /// Pushes an updated zone list to the running service.
  static Future<void> updateZones(List<SilentZone> zones) async {
    try {
      final zonesJson = jsonEncode(zones.map((z) => z.toJson()).toList());
      await _serviceChannel.invokeMethod('updateZones', {'zones': zonesJson});
    } catch (e) {
      print('RingerService.updateZones error: $e');
    }
  }

  /// Returns whether the background service is currently running.
  static Future<bool> isServiceRunning() async {
    try {
      final result = await _serviceChannel.invokeMethod<bool>('isRunning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
