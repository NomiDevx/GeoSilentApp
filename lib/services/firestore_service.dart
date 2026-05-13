import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/zone_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Zones Collection
  CollectionReference get zonesCollection => _firestore.collection('zones');

  // Add zone
  Future<void> addZone(SilentZone zone) async {
    await zonesCollection.doc(zone.id).set(zone.toJson());
  }

  // Update zone
  Future<void> updateZone(SilentZone zone) async {
    await zonesCollection.doc(zone.id).update(zone.toJson());
  }

  // Delete zone
  Future<void> deleteZone(String zoneId) async {
    await zonesCollection.doc(zoneId).delete();
  }

  // Get user zones
  Stream<List<SilentZone>> getUserZones(String userId) {
    return zonesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SilentZone.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Add location history
  Future<void> addLocationHistory({
    required String userId,
    required Map<String, dynamic> locationData,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('locationHistory')
        .add({
      ...locationData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Get location history
  Stream<QuerySnapshot> getLocationHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('locationHistory')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }
}