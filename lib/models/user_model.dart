class UserModel {
  String uid;
  String email;
  String? name;
  String? phone;
  String? address;
  String? profileImage;
  DateTime createdAt;
  DateTime? lastLogin;
  List<String>? preferences;
  Map<String, dynamic>? locationHistory;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phone,
    this.address,
    this.profileImage,
    required this.createdAt,
    this.lastLogin,
    this.preferences,
    this.locationHistory,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'preferences': preferences,
      'locationHistory': locationHistory,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      preferences: List<String>.from(json['preferences'] ?? []),
      locationHistory: Map<String, dynamic>.from(json['locationHistory'] ?? {}),
    );
  }
}