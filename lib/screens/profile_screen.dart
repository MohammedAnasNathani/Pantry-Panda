import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/app_state_provider.dart';
import '../widgets/glass_card.dart';
import 'auth_gate.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2ECC71), width: 3)),
                    child: CircleAvatar(radius: 60, backgroundColor: Theme.of(context).cardColor, child: Icon(Icons.person, size: 60, color: textColor)),
                  ),
                  const SizedBox(height: 16),
                  Text(provider.userName, style: Theme.of(context).textTheme.displayMedium),
                  const Text("Level 5 Waste Warrior", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(child: _statBox(context, "Saved", "₹${provider.totalMoneySaved.toInt()}", Icons.savings, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _statBox(context, "Streak", "${provider.streakDays} Days", Icons.local_fire_department, Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statBox(context, "Points", "${provider.ecoPoints}", Icons.bolt, Colors.amber)),
                const SizedBox(width: 16),
                Expanded(child: _statBox(context, "Recipes", "12", Icons.menu_book, Colors.blue)),
              ],
            ),

            const SizedBox(height: 32),

            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _settingItem(context, "Edit Profile", Icons.edit, null, onTap: () => _showEditName(context, provider)),
                  const Divider(height: 1),
                  _settingItem(context, "Dark Mode", Icons.dark_mode_outlined, Switch(value: provider.isDarkMode, onChanged: (v) => provider.toggleTheme())),
                  const Divider(height: 1),
                  _settingItem(context, "Help & Support", Icons.help_outline, null, onTap: () => _showHelp(context)),
                  const Divider(height: 1),
                  _settingItem(context, "Sign Out", Icons.logout, null, isRed: true, onTap: () async {
                    await GoogleSignIn().signOut();
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _statBox(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _settingItem(BuildContext context, String title, IconData icon, Widget? trailing, {bool isRed = false, VoidCallback? onTap}) {
    final textColor = isRed ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 📝 REAL EDIT DIALOG
  void _showEditName(BuildContext context, AppStateProvider provider) {
    final ctrl = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Edit Name"),
        content: TextField(controller: ctrl, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Display Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () { provider.updateName(ctrl.text); Navigator.pop(c); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white),
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Support"),
        content: const Text("Need help? Contact us at support@pantrypanda.com\n\nVersion: 1.0.0 (Championship Build)"),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Close"))],
      ),
    );
  }
}