import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/ai_service.dart';
import '../core/services/firestore_service.dart';
import '../models/recipe_model.dart';
import '../models/pantry_item.dart';

class AppStateProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final FirestoreService _db = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Theme
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // 👤 User Data
  String _userName = "Chef";
  double _totalMoneySaved = 0.0;
  int _streakDays = 0;
  int _ecoPoints = 0;
  DateTime? _lastCooked; // Track the date

  String get userName => _userName;
  double get totalMoneySaved => _totalMoneySaved;
  int get streakDays => _streakDays;
  int get ecoPoints => _ecoPoints;

  // Recipe & Pantry
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;
  List<PantryItem> _pantryItems = [];
  List<PantryItem> get pantryItems => _pantryItems;

  String _chefMode = 'Home Cook';
  String get chefMode => _chefMode;
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  final List<String> _unlockedModes = ['Home Cook', 'Dorm Survivor'];

  AppStateProvider() {
    _initUserListener();
  }

  void _initUserListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // 1. Listen to Profile Stats
        _db.streamUserProfile(user.uid).listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            _userName = data['name'] ?? "Chef";
            _totalMoneySaved = (data['totalMoneySaved'] ?? 0).toDouble();
            _ecoPoints = (data['ecoPoints'] ?? 0) as int;
            _streakDays = (data['streakDays'] ?? 0) as int;

            // Parse Timestamp
            if (data['lastCooked'] != null) {
              _lastCooked = (data['lastCooked'] as Timestamp).toDate();
            }
            notifyListeners();
          }
        });

        // 2. Listen to Pantry
        _db.streamPantry(user.uid).listen((items) {
          _pantryItems = items;
          notifyListeners();
        });
      }
    });
  }

  Future<void> updateName(String newName) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _db.updateUserProfile(uid, newName);
  }

  void toggleTheme() { _isDarkMode = !_isDarkMode; notifyListeners(); }
  bool isModeLocked(String mode) => !_unlockedModes.contains(mode);
  void unlockMode(String mode) { if (!_unlockedModes.contains(mode)) { _unlockedModes.add(mode); notifyListeners(); }}
  void setChefMode(String mode) { _chefMode = mode; notifyListeners(); }

  Future<void> scanFood(File image) async {
    _isScanning = true;
    _recipes = [];
    notifyListeners();

    try {
      final response = await _aiService.generateContent(image, _chefMode);
      _recipes = response.recipes;

      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        for (var item in response.detectedItems) {
          _db.addPantryItem(uid, item);
        }
      }
    } catch (e) {
      print("Scan Error: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // 🏆 FIXED STREAK LOGIC
  void completeRecipe(Recipe recipe) {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final now = DateTime.now();
      int newStreak = _streakDays;

      if (_lastCooked == null) {
        // First ever cook
        newStreak = 1;
      } else {
        final today = DateTime(now.year, now.month, now.day);
        final last = DateTime(_lastCooked!.year, _lastCooked!.month, _lastCooked!.day);

        if (today.isAfter(last)) {
          final difference = today.difference(last).inDays;
          if (difference == 1) {
            // Consecutive day
            newStreak++;
          } else {
            // Missed a day, reset (or keep at 1 if generous)
            newStreak = 1;
          }
        }
        // If today == last, do not increment streak (already cooked today)
      }

      // Update Firestore
      _db.updateUserStats(
          uid,
          recipe.moneySaved.toDouble(),
          50, // Points
          newStreak // The calculated streak
      );
    }
  }
}