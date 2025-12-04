import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state_provider.dart';
import '../config/constants.dart';
import 'cooking_screen.dart';

class RecipeResultScreen extends StatefulWidget {
  const RecipeResultScreen({super.key});
  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (_) => setState(() => _isAdLoaded = true), onAdFailedToLoad: (ad,e) => ad.dispose()),
    )..load();
  }

  @override
  void dispose() { _bannerAd?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<AppStateProvider>(context).recipes;

    return Scaffold(
      appBar: AppBar(title: const Text("Panda Picks"), centerTitle: true, backgroundColor: Colors.transparent),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: recipes.length,
        separatorBuilder: (_,__) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          if (index == 1 && _isAdLoaded) {
            return Column(
              children: [
                Container(height: 250, width: 320, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Center(child: AdWidget(ad: _bannerAd!))),
                const SizedBox(height: 24),
                _recipeCard(recipes[index]),
              ],
            );
          }
          return _recipeCard(recipes[index]).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
        },
      ),
    );
  }

  Widget _recipeCard(dynamic recipe) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CookingScreen(recipe: recipe))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE HEADER
            Container(
              height: 140,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF1E8449)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.restaurant_menu, size: 60, color: Colors.white38)),
                  Positioned(
                    top: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text("Save ₹${recipe.moneySaved}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(recipe.description, style: TextStyle(color: Colors.grey[600], height: 1.4)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _badge(Icons.timer, "${recipe.cookingTimeMinutes}m"),
                      _badge(Icons.local_fire_department, "${recipe.calories} kcal"),
                      _badge(Icons.speed, recipe.difficulty),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: null, // Card tap handles action
                      style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.black87, disabledForegroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text("Start Cooking"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(children: [Icon(icon, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey))]);
  }
}