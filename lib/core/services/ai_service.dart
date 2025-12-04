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
  final String _modelName = AppConstants.modelName;

  // 📸 VISION ANALYSIS
  Future<AIResponse> generateContent(File imageFile, String chefMode) async {
    try {
      final model = GenerativeModel(model: _modelName, apiKey: AppConstants.geminiApiKey);
      final imageBytes = await imageFile.readAsBytes();

      final content = [
        Content.multi([
          TextPart(AppConstants.getSystemPrompt(chefMode)),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      if (response.text == null) throw Exception("Empty AI Response");

      String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
      final startIndex = cleanJson.indexOf('{');
      final endIndex = cleanJson.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        cleanJson = cleanJson.substring(startIndex, endIndex + 1);
      }

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

  // 🆘 RECIPE RESCUE
  Future<String> getRecipeSos(String issue, String recipeContext) async {
    try {
      final model = GenerativeModel(model: _modelName, apiKey: AppConstants.geminiApiKey);
      final prompt = "I am cooking $recipeContext. The problem is: $issue. Give me a 1-sentence quick scientific fix using common kitchen items.";
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Try adding a little salt or lemon juice.";
    } catch (e) {
      return "Check your heat and stir properly!";
    }
  }
}