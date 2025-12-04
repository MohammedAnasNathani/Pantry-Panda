import 'package:flutter/material.dart';
import '../models/pantry_item.dart';
import '../core/services/firestore_service.dart';
import '../core/services/auth_service.dart';

class PantryProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final AuthService _auth = AuthService();

  Stream<List<PantryItem>> get pantryStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db.streamPantry(uid);
  }

  Future<void> removeItem(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _db.deleteItem(uid, id);
  }
}
