import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pantry_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 👤 USER PROFILE
  Future<void> saveUserStats(String uid, String name, String? email) {
    return _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProfile(String uid, String newName) {
    return _db.collection('users').doc(uid).update({'name': newName});
  }

  // 🛠️ UPDATED: Accepts precise streak number
  Future<void> updateUserStats(String uid, double moneySaved, int points, int newStreak) {
    return _db.collection('users').doc(uid).update({
      'totalMoneySaved': FieldValue.increment(moneySaved),
      'ecoPoints': FieldValue.increment(points),
      'streakDays': newStreak, // Set directly, don't increment blind
      'lastCooked': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> streamUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // 🏆 LEADERBOARD
  Stream<QuerySnapshot> streamLeaderboard() {
    return _db.collection('users')
        .orderBy('totalMoneySaved', descending: true)
        .limit(20)
        .snapshots();
  }

  // 🥕 PANTRY
  Future<void> addPantryItem(String uid, PantryItem item) {
    return _db.collection('users').doc(uid).collection('pantry').doc(item.id).set(item.toJson());
  }

  Stream<List<PantryItem>> streamPantry(String uid) {
    return _db.collection('users').doc(uid).collection('pantry')
        .orderBy('expiryDate')
        .snapshots()
        .map((s) => s.docs.map((d) => PantryItem.fromJson(d.data())).toList());
  }

  Future<void> deleteItem(String uid, String id) {
    return _db.collection('users').doc(uid).collection('pantry').doc(id).delete();
  }
}