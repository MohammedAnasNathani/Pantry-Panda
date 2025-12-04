import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../core/services/auth_service.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'main_container.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. User is NOT Logged In -> Show Login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 3. User IS Logged In -> Check if they have a Profile (Name)
        final user = snapshot.data!;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            // If doc doesn't exist OR name is empty -> Go to Onboarding
            if (!userSnapshot.hasData ||
                !userSnapshot.data!.exists ||
                (userSnapshot.data!.data() as Map)['name'] == null) {
              return const OnboardingScreen();
            }

            // 4. Everything Perfect -> Go to Main App
            return const MainContainer();
          },
        );
      },
    );
  }
}