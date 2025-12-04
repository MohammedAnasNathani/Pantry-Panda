import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../models/recipe_model.dart';
import '../providers/app_state_provider.dart';
import '../core/services/ai_service.dart';

class CookingScreen extends StatefulWidget {
  final Recipe recipe;
  const CookingScreen({super.key, required this.recipe});
  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  final FlutterTts _tts = FlutterTts();
  final PageController _pageCtrl = PageController();
  final ConfettiController _confetti = ConfettiController(duration: const Duration(seconds: 3));
  int _curr = 0;

  @override
  void initState() {
    super.initState();
    // Auto speak first step
    _speak(widget.recipe.steps[0]);
  }

  void _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.speak(text);
  }

  // 🆘 SOS LOGIC (Fully Working)
  void _showSOS() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.support_agent, size: 50, color: Colors.redAccent),
            const SizedBox(height: 10),
            const Text("Kitchen Rescue 🚑", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Burned it? Too salty? Ask Chef Panda.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "E.g. It's too salty!",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                )
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.isEmpty) return;
                  Navigator.pop(ctx);

                  // Show thinking snackbar
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chef Panda is thinking...")));

                  try {
                    // Call AI
                    final fix = await AIService().getRecipeSos(ctrl.text, widget.recipe.title);

                    // Show Result
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text("Chef's Fix", style: TextStyle(color: Colors.white)),
                        content: Text(fix, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        actions: [
                          TextButton(onPressed: () { _speak(fix); Navigator.pop(c); }, child: const Text("Listen")),
                          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Close")),
                        ],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not connect to Chef Panda.")));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("Fix My Dish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Immersive Story Mode
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) {
              setState(() => _curr = i);
              if (i < widget.recipe.steps.length) _speak(widget.recipe.steps[i]);
            },
            itemCount: widget.recipe.steps.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.recipe.steps.length) return _finishPage();

              return GestureDetector(
                onTap: () => _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.grey[900]!], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("STEP ${index + 1}", style: const TextStyle(color: Colors.greenAccent, fontSize: 14, letterSpacing: 4, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      Text(widget.recipe.steps[index], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.3)),
                      const SizedBox(height: 60),
                      const Text("Tap for next", style: TextStyle(color: Colors.white24, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),

          // TOP PROGRESS BAR
          Positioned(
            top: 60, left: 20, right: 20,
            child: Row(children: List.generate(widget.recipe.steps.length + 1, (index) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), height: 4, color: index <= _curr ? Colors.greenAccent : Colors.white12)))),
          ),

          // SOS BUTTON
          Positioned(
            bottom: 40, left: 20,
            child: FloatingActionButton(backgroundColor: Colors.redAccent, onPressed: _showSOS, child: const Icon(Icons.sos, color: Colors.white)),
          ),

          // BACK BUTTON
          Positioned(top: 60, left: 20, child: BackButton(color: Colors.white, onPressed: () => Navigator.pop(context))),

          Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confetti, blastDirectionality: BlastDirectionality.explosive)),
        ],
      ),
    );
  }

  Widget _finishPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/success.json', height: 200, repeat: false),
          const SizedBox(height: 20),
          const Text("BON APPÉTIT!", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 10),
          Text("+50 Eco Points Added", style: TextStyle(color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            onPressed: () {
              _confetti.play();
              Provider.of<AppStateProvider>(context, listen: false).completeRecipe(widget.recipe);
              Future.delayed(const Duration(seconds: 2), () { Navigator.pop(context); Navigator.pop(context); });
            },
            child: const Text("Finish & Save Money", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}