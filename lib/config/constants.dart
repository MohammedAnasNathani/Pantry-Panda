import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // 🔑 API KEY (SECURE LOAD)
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? "";

  // 🤖 AI MODEL
  static const String modelName = 'gemini-2.5-flash';

  // 💰 ADMOB TEST IDS (These are test ids)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // 💡 CHEF'S WISDOM DATABASE
  static const List<Map<String, String>> kitchenTips = [
    {"emoji": "🥑", "title": "Avocados", "desc": "Store with an onion slice. The sulfur prevents browning for up to 3 days."},
    {"emoji": "🍌", "title": "Bananas", "desc": "Wrap the stems in plastic or foil. This blocks ethylene gas and slows ripening."},
    {"emoji": "🍞", "title": "Stale Bread", "desc": "Splash with water and bake at 350°F for 5 minutes. It becomes soft inside and crunchy outside."},
    {"emoji": "🌿", "title": "Herbs", "desc": "Treat them like flowers! Trim stems and place in a glass of water in the fridge."},
    {"emoji": "🥔", "title": "Potatoes", "desc": "Never store with onions! They make each other rot faster. Keep potatoes in the dark."},
    {"emoji": "🧀", "title": "Cheese", "desc": "Rub butter on the cut side of cheese to prevent it from drying out before wrapping."},
    {"emoji": "🍋", "title": "Lemons", "desc": "Store in a bowl of water in the fridge. They will stay juicy for 3 months."},
    {"emoji": "🍄", "title": "Mushrooms", "desc": "Store in a paper bag, not plastic. Plastic traps moisture and makes them slimy."},
    {"emoji": "🥬", "title": "Lettuce", "desc": "Place a paper towel in the bag. It absorbs excess moisture and keeps leaves crisp."},
    {"emoji": "🥚", "title": "Eggs", "desc": "Don't store in the fridge door. The temperature fluctuation makes them spoil faster."},
  ];

  // 🎭 CHEF MODES (UPDATED DESCRIPTIONS)
  static const Map<String, dynamic> chefModes = {
    'Home Cook': {
      'icon': Icons.soup_kitchen,
      'color': Colors.green,
      'title': 'The Home Cook',
      'desc': 'Perfect for everyday meals. Focuses on simple ingredients, quick prep times, and family-friendly flavors. Uses common staples found in every kitchen.',
      'prompt': 'You are a warm home cook. Suggest quick, comfort food. Tone: Friendly.'
    },
    'Gourmet Chef': {
      'icon': Icons.restaurant,
      'color': Colors.purple,
      'title': 'The Gourmet Chef',
      'desc': 'Elevate your dining experience. Focuses on plating techniques, complex flavor profiles, and culinary sophistication. Ideal for dates or impressing guests.',
      'prompt': 'You are a French Chef. Focus on plating and elegance. Tone: Sophisticated.'
    },
    'Dorm Survivor': {
      'icon': Icons.microwave,
      'color': Colors.orange,
      'title': 'Dorm Survivor',
      'desc': 'Maximum taste, minimum effort. Designed for microwaves, kettles, and single-burner stoves. Focuses on cheap ingredients and zero dishwashing.',
      'prompt': 'You are a broke student. Use microwave, minimal ingredients. Tone: Funny.'
    },
    'Gym Bro': {
      'icon': Icons.fitness_center,
      'color': Colors.redAccent,
      'title': 'The Gym Bro',
      'desc': 'Fuel your gains. Prioritizes high protein, calculated macros, and clean energy. Perfect for post-workout recovery and muscle building.',
      'prompt': 'You are a fitness coach. Focus strictly on HIGH PROTEIN. Tone: Energetic.'
    },
  };

  static String getSystemPrompt(String chefMode) {
    return '''
      You are Pantry Panda ($chefMode). ${chefModes[chefMode]?['prompt']}
      
      Analyze this image.
      1. Identify visible ingredients.
      2. Estimate remaining shelf life (days).
      3. Create 4 DISTINCT recipes (Variety: 1 Soup/Salad, 1 Main, 1 Quick Fix, 1 Creative).
      4. CALCULATE SAVINGS: Estimate restaurant price (INR) vs home cook cost. Diff is 'money_saved_inr'.
      
      RETURN RAW JSON ONLY. NO MARKDOWN.
      {
        "pantry_items": [{"name": "Item", "days_until_expiry": 3, "category": "Veg"}],
        "recipes": [
          {
            "title": "Title", 
            "description": "Short appetizing description", 
            "cooking_time_minutes": 15,
            "calories": 300, 
            "difficulty": "Easy", 
            "money_saved_inr": 200,
            "steps": ["Step 1", "Step 2"], 
            "ingredients_needed": ["Item 1"]
          }
        ]
      }
    ''';
  }
}