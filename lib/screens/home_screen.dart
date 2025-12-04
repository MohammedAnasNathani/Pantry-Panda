import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/glass_card.dart';
import '../config/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Map<String, String>> _todaysTips;

  @override
  void initState() {
    super.initState();
    // Randomize tips on init so they stay consistent for the session
    final tips = List<Map<String, String>>.from(AppConstants.kitchenTips);
    tips.shuffle();
    _todaysTips = tips.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🐼 PREMIUM AVATAR LOGIC
    String emoji = "🐼";
    if (provider.streakDays > 2) emoji = "👨‍🍳";
    if (provider.streakDays > 7) emoji = "🔥";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PREMIUM HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Evening,', style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(provider.userName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => nav.setIndex(3),
                    child: Container(
                      height: 56, width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF219150)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        boxShadow: [BoxShadow(color: const Color(0xFF2ECC71).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 32),

              // 2. LIFETIME SAVINGS CARD (Credit Card Look)
              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF2C3E50)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 15))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: const Text("IMPACT CARD", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                        const Icon(Icons.blur_on, color: Colors.white54, size: 30),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("₹${provider.totalMoneySaved.toInt()}", style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 52, fontWeight: FontWeight.w900, height: 1.0)),
                        const SizedBox(height: 8),
                        Text("≈ ${(provider.totalMoneySaved / 150).toStringAsFixed(0)} Meals Rescued", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                        const SizedBox(width: 8),
                        Text("${provider.streakDays} Day Streak", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

              const SizedBox(height: 36),

              // 3. CHEF'S WISDOM (Popups)
              Text("Chef's Wisdom 💡", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _todaysTips.length,
                  itemBuilder: (ctx, i) {
                    final tip = _todaysTips[i];
                    return _tipCard(context, tip['emoji']!, tip['title']!, tip['desc']!);
                  },
                ),
              ),

              const SizedBox(height: 36),

              // 4. DAILY QUEST (Clickable)
              Text("Daily Quest", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showQuestDialog(context);
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        height: 64, width: 64,
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                        child: const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Zero Waste Hero", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 6),
                            Text("Cook a meal with 0g waste.", style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text("+100", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipCard(BuildContext context, String emoji, String title, String fullText) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showDialog(
          context: context,
          builder: (c) => Dialog(
            backgroundColor: Colors.transparent,
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(fullText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(c),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
                    child: const Text("Got it!"),
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text("Tap to read", style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showQuestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              const Text("Zero Waste Hero", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text("Cook a meal today using 100% of the edible parts of your vegetables (stems, skins).", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(c),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text("Accept Challenge"),
              )
            ],
          ),
        ),
      ),
    );
  }
}