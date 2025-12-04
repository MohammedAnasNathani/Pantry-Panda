import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../widgets/animated_gradient.dart';
import '../config/app_text_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.eco, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text('Pantry Panda', textAlign: TextAlign.center, style: AppTextStyles.h1.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              const Text('Turn Leftovers into Luxury.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () => AuthService().signInWithGoogle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
