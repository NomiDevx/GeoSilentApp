import 'dart:ui';

import 'package:geo_silent/theme.dart';

enum ZoneType { office, mosque, hospital, classroom, library, cinema, other }
enum SoundProfile { silent, vibration, normal }

class SilentZone {
  String id;
  String userId;
  String name;
  ZoneType type;
  double latitude;
  double longitude;
  double radius; // in meters
  SoundProfile soundProfile;
  bool isActive;
  DateTime createdAt;
  DateTime? updatedAt;
  List<String> schedule; // Days and times for scheduling
  bool isRepeating;

  SilentZone({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.soundProfile = SoundProfile.silent,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.schedule = const [],
    this.isRepeating = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.index,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'soundProfile': soundProfile.index,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'schedule': schedule,
      'isRepeating': isRepeating,
    };
  }

  factory SilentZone.fromJson(Map<String, dynamic> json) {
    return SilentZone(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      type: ZoneType.values[json['type']],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      soundProfile: SoundProfile.values[json['soundProfile']],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      schedule: List<String>.from(json['schedule'] ?? []),
      isRepeating: json['isRepeating'] ?? true,
    );
  }

  String get icon {
    switch (type) {
      case ZoneType.office:
        return '🏢';
      case ZoneType.mosque:
        return '🕌';
      case ZoneType.hospital:
        return '🏥';
      case ZoneType.classroom:
        return '🏫';
      case ZoneType.library:
        return '📚';
      case ZoneType.cinema:
        return '🎬';
      default:
        return '📍';
    }
  }

  Color get color {
    switch (soundProfile) {
      case SoundProfile.silent:
        return AppTheme.silentZoneColor;
      case SoundProfile.vibration:
        return AppTheme.vibrationZoneColor;
      case SoundProfile.normal:
        return AppTheme.normalZoneColor;
    }
  }
}