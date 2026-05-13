class SilentZone {
  String id;
  String name;
  double latitude;
  double longitude;
  double radius; // in meters
  bool isActive;
  DateTime createdAt;

  SilentZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SilentZone.fromJson(Map<String, dynamic> json) {
    return SilentZone(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}