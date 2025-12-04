import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/app_colors.dart';
import '../widgets/animated_gradient.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'pantry_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'leaderboard_screen.dart';

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    PantryScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: AnimatedGradientBackground(
        child: IndexedStack(
          index: nav.currentIndex,
          children: _screens,
        ),
      ),

      // 🚀 THE "GOD MODE" ORB (Scanner Button)
      floatingActionButton: Container(
        height: 75, width: 75,
        margin: const EdgeInsets.only(bottom: 10),
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanScreen()));
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              height: 75, width: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF219150)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2ECC71).withOpacity(0.6), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 8)),
                  BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 5, spreadRadius: 0, offset: const Offset(0, 0)),
                ],
              ),
              child: const Icon(Icons.center_focus_strong, size: 32, color: Colors.white),
            ),
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 1.5.seconds),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 💎 PREMIUM FLOATING GLASS NAVBAR
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        height: 80,
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF121212) : Colors.white).withOpacity(0.8),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(0, Icons.home_rounded, "Home", nav),
                _navItem(1, Icons.kitchen_rounded, "Pantry", nav),
                const SizedBox(width: 60), // Spacer for Orb
                _navItem(2, Icons.leaderboard_rounded, "Rank", nav),
                _navItem(3, Icons.person_rounded, "Profile", nav),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, NavigationProvider nav) {
    final isSelected = nav.currentIndex == index;
    final color = isSelected ? const Color(0xFF2ECC71) : Colors.grey;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        nav.setIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2ECC71).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}