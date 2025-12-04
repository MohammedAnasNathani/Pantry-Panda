import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/services/firestore_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Adaptive text color for Dark/Light mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // 1. BIG TROPHY HEADER
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded, size: 80, color: Color(0xFFFFD700)),
                  const SizedBox(height: 10),
                  Text("Hall of Fame", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
                  Text("Top Savers This Week", style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            ),

            // 2. THE LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService().streamLeaderboard(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text("No Data"));

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: docs.length,
                    separatorBuilder: (_,__) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final rank = index + 1;

                      // PREMIUM CARD STYLING
                      return _userCard(context, rank, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard(BuildContext context, int rank, Map<String, dynamic> data) {
    Color bgColor;
    Color textColor;
    Color iconColor;
    double scale = 1.0;

    // GOLD / SILVER / BRONZE LOGIC
    if (rank == 1) {
      bgColor = const Color(0xFFFFD700); // Gold
      textColor = Colors.black;
      iconColor = Colors.black;
      scale = 1.05; // Slightly larger
    } else if (rank == 2) {
      bgColor = const Color(0xFFC0C0C0); // Silver
      textColor = Colors.black;
      iconColor = Colors.black54;
    } else if (rank == 3) {
      bgColor = const Color(0xFFCD7F32); // Bronze
      textColor = Colors.white;
      iconColor = Colors.white70;
    } else {
      // Standard Glass Card
      bgColor = Theme.of(context).cardColor;
      textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
      iconColor = Colors.grey;
    }

    return Transform.scale(
      scale: scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: rank > 3 ? Border.all(color: Colors.grey.withOpacity(0.2)) : null,
        ),
        child: Row(
          children: [
            // RANK BADGE
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Text(
                "#$rank",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: iconColor),
              ),
            ),
            const SizedBox(width: 16),

            // AVATAR & NAME
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(Icons.person, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? "Unknown Chef",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (rank == 1)
                    Text("👑 Current Champion", style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7), fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // MONEY SAVED
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "₹${(data['totalMoneySaved'] ?? 0).toInt()}",
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.1, delay: (rank * 50).ms).fadeIn();
  }
}