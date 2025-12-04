import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/primary_button.dart';
import '../widgets/animated_gradient.dart';
import '../config/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'email': user.email,
        'totalMoneySaved': 0.0,
        'ecoPoints': 0,
        'streakDays': 0,
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    // AuthGate will automatically redirect to MainContainer now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.waving_hand, size: 60, color: Colors.white),
                const SizedBox(height: 20),
                Text("Welcome to Pantry Panda!", style: AppTextStyles.h1.copyWith(color: Colors.white)),
                const SizedBox(height: 10),
                const Text("What should we call you, Chef?", style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : PrimaryButton(label: "Start Cooking", onTap: _saveProfile)
              ],
            ),
          ),
        ),
      ),
    );
  }
}