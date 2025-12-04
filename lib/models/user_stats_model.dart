import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final String uid;
  final String name;
  final double totalMoneySaved;
  final int streakDays;
  final int ecoPoints;

  UserStats({
    required this.uid,
    required this.name,
    required this.totalMoneySaved,
    required this.streakDays,
    required this.ecoPoints,
  });

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStats(
      uid: doc.id,
      name: data['name'] ?? 'Chef',
      totalMoneySaved: (data['totalMoneySaved'] ?? 0).toDouble(),
      streakDays: data['streakDays'] ?? 0,
      ecoPoints: data['ecoPoints'] ?? 0,
    );
  }
}
