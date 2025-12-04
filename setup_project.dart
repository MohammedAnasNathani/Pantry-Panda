import 'dart:io';

void main() async {
  print('🐼 STARTING PANTRY PANDA V2 GENERATION...');
  print('🚀 Buckle up. We are winning this.');

  // Define the file structure and content
  final Map<String, String> files = {
    // ==========================================
    // CONFIG
    // ==========================================
    'lib/config/app_colors.dart': r'''
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryDark = Color(0xFF27AE60);
  static const Color accent = Color(0xFFFFB74D);
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
''',

    'lib/config/app_text_styles.dart': r'''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold);
  static TextStyle get h2 => GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600);
  static TextStyle get h3 => GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get bodyLarge => GoogleFonts.openSans(fontSize: 16, height: 1.5);
  static TextStyle get button => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
}
''',

    'lib/config/constants.dart': r'''
class AppConstants {
  // 🔑 TODO: PASTE YOUR GEMINI API KEY HERE BEFORE RUNNING
  static const String geminiApiKey = 'YOUR_API_KEY_HERE';

  // 💰 ADMOB TEST IDS (Use these for Dev)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // 🎭 CHEF PERSONAS
  static const Map<String, String> chefPrompts = {
    'Home Cook': 'You are a warm, practical home cook. Suggest quick, comfort food.',
    'Gourmet Chef': 'You are a Michelin-star French Chef. Focus on plating and elegance.',
    'Dorm Survivor': 'You are a broke student. Use microwave, minimal ingredients.',
    'Gym Bro': 'You are a fitness coach. Focus strictly on HIGH PROTEIN and macros.',
  };
}
''',

    'lib/config/theme.dart': r'''
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.surfaceLight,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: Colors.black87),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.black54),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.grey),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
''',

    // ==========================================
    // MODELS
    // ==========================================
    'lib/models/recipe_model.dart': r'''
class Recipe {
  final String id;
  final String title;
  final String description;
  final int cookingTimeMinutes;
  final int calories;
  final String difficulty;
  final int moneySaved;
  final List<String> steps;
  final List<String> ingredients;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookingTimeMinutes,
    required this.calories,
    required this.difficulty,
    required this.moneySaved,
    required this.steps,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json, String generatedId) {
    return Recipe(
      id: generatedId,
      title: json['title'] ?? 'Mystery Meal',
      description: json['description'] ?? 'Delicious sustainable recipe.',
      cookingTimeMinutes: json['cooking_time_minutes'] ?? 20,
      calories: json['calories'] ?? 300,
      difficulty: json['difficulty'] ?? 'Medium',
      moneySaved: json['money_saved_inr'] ?? 150,
      steps: List<String>.from(json['steps'] ?? []),
      ingredients: List<String>.from(json['ingredients_needed'] ?? []),
    );
  }
}
''',

    'lib/models/pantry_item.dart': r'''
class PantryItem {
  final String id;
  final String name;
  final DateTime expiryDate;
  final String category;

  PantryItem({required this.id, required this.name, required this.expiryDate, required this.category});

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'expiryDate': expiryDate.toIso8601String(), 'category': category,
  };

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['id'],
      name: json['name'],
      expiryDate: DateTime.parse(json['expiryDate']),
      category: json['category'],
    );
  }
}
''',

    'lib/models/user_stats_model.dart': r'''
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final String uid;
  final String name;
  final double totalMoneySaved;
  final int streakDays;
  final int ecoPoints;

  UserStats({
    required this.uid,
    required this.name,
    required this.totalMoneySaved,
    required this.streakDays,
    required this.ecoPoints,
  });

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStats(
      uid: doc.id,
      name: data['name'] ?? 'Chef',
      totalMoneySaved: (data['totalMoneySaved'] ?? 0).toDouble(),
      streakDays: data['streakDays'] ?? 0,
      ecoPoints: data['ecoPoints'] ?? 0,
    );
  }
}
''',

    // ==========================================
    // SERVICES
    // ==========================================
    'lib/core/services/ai_service.dart': r'''
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../../config/constants.dart';
import '../../models/recipe_model.dart';
import '../../models/pantry_item.dart';

class AIResponse {
  final List<Recipe> recipes;
  final List<PantryItem> detectedItems;
  AIResponse(this.recipes, this.detectedItems);
}

class AIService {
  final Uuid _uuid = const Uuid();
  // 🔥 WINNING MODEL: Fastest & Cheapest for business model
  final String _modelName = 'gemini-1.5-flash';

  Future<AIResponse> generateContent(File imageFile, String chefMode) async {
    try {
      final model = GenerativeModel(model: _modelName, apiKey: AppConstants.geminiApiKey);
      final imageBytes = await imageFile.readAsBytes();

      final String systemPrompt = """
      You are Pantry Panda ($chefMode).
      1. Identify ingredients in image.
      2. Create 2 recipes.
      3. CALCULATE SAVINGS: Estimate restaurant price (INR) vs home cook cost. Diff is 'money_saved_inr'.
      
      RETURN RAW JSON ONLY:
      {
        "pantry_items": [{"name": "Item", "days_until_expiry": 3, "category": "Veg"}],
        "recipes": [{
          "title": "Title", "description": "Desc", "cooking_time_minutes": 15,
          "calories": 300, "difficulty": "Easy", "money_saved_inr": 200,
          "steps": ["Step 1"], "ingredients_needed": ["Item"]
        }]
      }
      """;

      final content = [Content.multi([TextPart(systemPrompt), DataPart('image/jpeg', imageBytes)])];
      final response = await model.generateContent(content);

      if (response.text == null) throw Exception("Empty AI Response");

      // 🧹 CLEANUP LOGIC
      String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final startIndex = cleanJson.indexOf('{');
      final endIndex = cleanJson.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) cleanJson = cleanJson.substring(startIndex, endIndex + 1);

      final Map<String, dynamic> data = jsonDecode(cleanJson);
      
      List<Recipe> recipes = (data['recipes'] as List).map((j) => Recipe.fromJson(j, _uuid.v4())).toList();
      List<PantryItem> items = (data['pantry_items'] as List).map((j) => PantryItem(
        id: _uuid.v4(), name: j['name'], 
        expiryDate: DateTime.now().add(Duration(days: j['days_until_expiry'] ?? 3)), 
        category: j['category'] ?? 'General'
      )).toList();

      return AIResponse(recipes, items);
    } catch (e) {
      print("❌ AI ERROR: $e");
      rethrow;
    }
  }
}
''',

    'lib/core/services/admob_service.dart': r'''
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../config/constants.dart';

class AdMobService {
  static NativeAd createNativeAd({required Function(Ad) onLoaded}) {
    return NativeAd(
      adUnitId: AppConstants.nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) { ad.dispose(); print('Ad Failed: $error'); },
      ),
    );
  }
}
''',

    'lib/core/services/auth_service.dart': r'''
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      return (await _auth.signInWithCredential(credential)).user;
    } catch (e) {
      print("Sign In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
''',

    'lib/core/services/firestore_service.dart': r'''
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pantry_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserStats(String uid, String name) {
    return _db.collection('users').doc(uid).set({
      'name': name, 'lastActive': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
  }

  Future<void> addPantryItem(String uid, PantryItem item) {
    return _db.collection('users').doc(uid).collection('pantry').doc(item.id).set(item.toJson());
  }

  Stream<List<PantryItem>> streamPantry(String uid) {
    return _db.collection('users').doc(uid).collection('pantry')
        .orderBy('expiryDate').snapshots()
        .map((s) => s.docs.map((d) => PantryItem.fromJson(d.data())).toList());
  }
  
  Future<void> deleteItem(String uid, String id) {
    return _db.collection('users').doc(uid).collection('pantry').doc(id).delete();
  }
}
''',

    // ==========================================
    // PROVIDERS
    // ==========================================
    'lib/providers/app_state_provider.dart': r'''
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/services/ai_service.dart';
import '../models/recipe_model.dart';
import '../models/pantry_item.dart';

class AppStateProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  
  // Theme
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Stats
  double _totalMoneySaved = 1240.0;
  int _streakDays = 12;
  double get totalMoneySaved => _totalMoneySaved;
  int get streakDays => _streakDays;

  // Data
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;
  String _chefMode = 'Home Cook';
  String get chefMode => _chefMode;
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  void toggleTheme() { _isDarkMode = !_isDarkMode; notifyListeners(); }
  void setChefMode(String mode) { _chefMode = mode; notifyListeners(); }

  Future<void> scanFood(File image) async {
    _isScanning = true;
    _recipes = [];
    notifyListeners();
    try {
      final res = await _aiService.generateContent(image, _chefMode);
      _recipes = res.recipes;
      // Note: Ideally, add res.detectedItems to PantryProvider here
    } catch (e) {
      print("Scan Err: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  void completeRecipe(Recipe recipe) {
    _totalMoneySaved += recipe.moneySaved;
    notifyListeners();
  }
}
''',

    'lib/providers/pantry_provider.dart': r'''
import 'package:flutter/material.dart';
import '../models/pantry_item.dart';
import '../core/services/firestore_service.dart';
import '../core/services/auth_service.dart';

class PantryProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final AuthService _auth = AuthService();

  Stream<List<PantryItem>> get pantryStream {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db.streamPantry(uid);
  }

  Future<void> removeItem(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _db.deleteItem(uid, id);
  }
}
''',

    // ==========================================
    // WIDGETS
    // ==========================================
    'lib/widgets/glass_card.dart': r'''
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  const GlassCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.withOpacity(0.1) : Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
''',

    'lib/widgets/primary_button.dart': r'''
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const PrimaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.premiumGradient,
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ),
      ),
    );
  }
}
''',

    'lib/widgets/animated_gradient.dart': r'''
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});
  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark 
                  ? [Color(0xFF1a2a1d), Color(0xFF000000)] 
                  : [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(_controller.value * 3.14 / 4),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
''',

    // ==========================================
    // SCREENS
    // ==========================================
    'lib/screens/auth_gate.dart': r'''
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../core/services/auth_service.dart';
import 'login_screen.dart';
import 'main_container.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: Consumer<User?>(
        builder: (context, user, _) => user == null ? const LoginScreen() : const MainContainer(),
      ),
    );
  }
}
''',

    'lib/screens/login_screen.dart': r'''
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
''',

    'lib/screens/main_container.dart': r'''
import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'pantry_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import '../widgets/animated_gradient.dart';
import '../config/app_colors.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});
  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _idx = 0;
  final _screens = [const HomeScreen(), const PantryScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: AnimatedGradientBackground(child: _screens[_idx]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen())),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomAppBar(
            height: 70,
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(icon: Icon(Icons.home, color: _idx == 0 ? AppColors.primary : Colors.grey), onPressed: () => setState(() => _idx = 0)),
                IconButton(icon: Icon(Icons.kitchen, color: _idx == 1 ? AppColors.primary : Colors.grey), onPressed: () => setState(() => _idx = 1)),
                const SizedBox(width: 40),
                IconButton(icon: Icon(Icons.person, color: _idx == 2 ? AppColors.primary : Colors.grey), onPressed: () => setState(() => _idx = 2)),
                IconButton(icon: const Icon(Icons.leaderboard, color: Colors.grey), onPressed: () {}), // Todo
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''',

    'lib/screens/home_screen.dart': r'''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state_provider.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Hello Chef,", style: TextStyle(color: Colors.grey[600])),
          const Text("Ready to Save?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat(Icons.savings, "₹${provider.totalMoneySaved.toInt()}", "Saved"),
                Container(height: 40, width: 1, color: Colors.grey),
                _stat(Icons.local_fire_department, "${provider.streakDays}", "Streak"),
              ],
            ),
          ).animate().slideY(begin: 0.2, duration: 500.ms),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Impact Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(height: 100, color: Colors.green.withOpacity(0.1), child: const Center(child: Text("Graph Placeholder"))),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _stat(IconData icon, String val, String label) {
    return Column(children: [
      Icon(icon, color: Colors.green),
      Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}
''',

    'lib/screens/scan_screen.dart': r'''
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/app_state_provider.dart';
import 'recipe_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _init = false;
  bool _loading = false;

  @override
  void initState() { super.initState(); _setupCamera(); }
  void _setupCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if(mounted) setState(() => _init = true);
    }
  }
  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  void _snap() async {
    if(!_init) return;
    setState(() => _loading = true);
    try {
      final img = await _controller!.takePicture();
      await Provider.of<AppStateProvider>(context, listen: false).scanFood(File(img.path));
      if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RecipeResultScreen()));
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!_init) return const Scaffold(backgroundColor: Colors.black);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if(_loading) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
          Positioned(bottom: 30, left: 0, right: 0, child: GestureDetector(
            onTap: _snap,
            child: const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.camera_alt, color: Colors.black)),
          )),
          Positioned(top: 40, left: 20, child: BackButton(color: Colors.white)),
        ],
      ),
    );
  }
}
''',

    'lib/screens/recipe_result_screen.dart': r'''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/app_state_provider.dart';
import '../widgets/glass_card.dart';
import '../config/constants.dart';

class RecipeResultScreen extends StatefulWidget {
  const RecipeResultScreen({super.key});
  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen> {
  NativeAd? _ad;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    _ad = NativeAd(
      adUnitId: AppConstants.nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(onAdLoaded: (a) => setState(() => _loaded = true), onAdFailedToLoad: (a,e) => a.dispose()),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<AppStateProvider>(context).recipes;
    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: recipes.length,
        separatorBuilder: (_,__) => const SizedBox(height: 20),
        itemBuilder: (ctx, i) {
          if (i == 1 && _loaded) return Column(children: [
            Container(height: 100, color: Colors.grey[200], alignment: Alignment.center, child: AdWidget(ad: _ad!)),
            const SizedBox(height: 20),
            _card(recipes[i])
          ]);
          return _card(recipes[i]);
        },
      ),
    );
  }
  Widget _card(dynamic r) {
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text("Save ₹${r.moneySaved}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(r.description),
      ]),
    );
  }
}
''',

    'lib/screens/pantry_screen.dart': r'''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';
import '../widgets/glass_card.dart';

class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<PantryItem>>.value(
      value: Provider.of<PantryProvider>(context).pantryStream,
      initialData: const [],
      child: Consumer<List<PantryItem>>(
        builder: (ctx, items, _) {
          if (items.isEmpty) return const Center(child: Text("Pantry Empty. Scan something!"));
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(child: ListTile(
                leading: const Icon(Icons.fastfood),
                title: Text(items[i].name),
                subtitle: Text("Expires: ${items[i].expiryDate.day}/${items[i].expiryDate.month}"),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => Provider.of<PantryProvider>(context, listen:false).removeItem(items[i].id)),
              )),
            ),
          );
        },
      ),
    );
  }
}
''',

    'lib/screens/profile_screen.dart': r'''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          const Text("Chef Panda", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          GlassCard(child: SwitchListTile(
            title: const Text("Dark Mode"),
            value: provider.isDarkMode,
            onChanged: (v) => provider.toggleTheme(),
          )),
        ],
      ),
    );
  }
}
''',

    // ==========================================
    // MAIN ENTRY
    // ==========================================
    'lib/main.dart': r'''
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/pantry_provider.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  MobileAds.instance.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => PantryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pantry Panda',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthGate(),
        );
      },
    );
  }
}
''',
  };

  // EXECUTE GENERATION
  for (var entry in files.entries) {
    final path = entry.key;
    final content = entry.value;

    // Create directory if missing
    final file = File(path);
    if (!file.parent.existsSync()) {
      print('📂 Creating directory: ${file.parent.path}');
      file.parent.createSync(recursive: true);
    }

    // Write file
    print('📄 Writing file: $path');
    file.writeAsStringSync(content);
  }

  print('✅ SUCCESS! Pantry Panda V2 structure is ready.');
  print('⚠️ NEXT STEPS:');
  print('1. Run "flutter pub add flutter_animate google_fonts glass_kit lottie confetti font_awesome_flutter provider shared_preferences intl uuid firebase_core firebase_auth cloud_firestore google_sign_in google_generative_ai camera image_picker google_mobile_ads flutter_tts vibration home_widget"');
  print('2. Run "flutterfire configure"');
  print('3. Add your Assets (images/animations) to assets/ folder');
}