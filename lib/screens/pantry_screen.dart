import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';
import '../widgets/glass_card.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});
  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _filter = "All";
  // Defined strict categories to prevent dropdown errors
  final List<String> _filters = ["All", "Veg", "Fruit", "Dairy", "Meat", "Grain", "Other"];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PantryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Digital Fridge", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add_circle, color: Color(0xFF2ECC71), size: 36),
                  )
                ],
              ),
            ),

            // 2. FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: _filters.map((cat) {
                  final isSelected = _filter == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = cat),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2ECC71) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
                      ),
                      child: Text(
                          cat,
                          style: TextStyle(
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 3. PANTRY LIST
            Expanded(
              child: StreamBuilder<List<PantryItem>>(
                stream: provider.pantryStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  var items = snapshot.data!;
                  // Robust Filtering Logic
                  if (_filter != "All") {
                    items = items.where((item) {
                      final cat = item.category.toLowerCase();
                      final filter = _filter.toLowerCase();
                      return cat == filter || (filter == 'other' && !['veg','fruit','dairy','meat','grain'].contains(cat));
                    }).toList();
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text("No $_filter Items", style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Tap + to add manually", style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    itemCount: items.length,
                    separatorBuilder: (_,__) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final days = item.expiryDate.difference(DateTime.now()).inDays;
                      final progress = (days / 10).clamp(0.0, 1.0);

                      Color color = days < 3 ? Colors.red : (days < 6 ? Colors.orange : Colors.green);
                      String status = days < 0 ? "Expired" : (days == 0 ? "Expires Today" : "$days days left");

                      return Dismissible(
                        key: Key(item.id),
                        onDismissed: (_) => provider.removeItem(item.id),
                        background: Container(
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(_getIcon(item.category), color: color),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[200],
                                        color: color,
                                        minHeight: 4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideX(begin: 0.1, delay: (index * 30).ms);
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

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    // 🛠️ CRITICAL FIX: Default value MUST match one of the items exactly.
    String cat = 'Other';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text("Add to Pantry"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "Item Name (e.g. Milk)", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: cat,
                // Only show valid categories (excluding "All")
                items: _filters.where((f) => f != "All").map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) => setState(() => cat = v!),
                decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    final item = PantryItem(id: const Uuid().v4(), name: nameCtrl.text, expiryDate: DateTime.now().add(const Duration(days: 7)), category: cat);
                    FirebaseFirestore.instance.collection('users').doc(uid).collection('pantry').doc(item.id).set(item.toJson());
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Add"),
            )
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String cat) {
    cat = cat.toLowerCase();
    if (cat.contains('veg')) return Icons.eco;
    if (cat.contains('fruit')) return Icons.apple;
    if (cat.contains('dairy')) return Icons.egg;
    if (cat.contains('meat')) return Icons.restaurant;
    if (cat.contains('grain')) return Icons.breakfast_dining;
    return Icons.fastfood;
  }
}