import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool _isInitialized = false;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (err) => print('Ad Failed'),
      ),
    );
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
        await _controller!.initialize();
        if (mounted) setState(() => _isInitialized = true);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() { _controller?.dispose(); _rewardedAd?.dispose(); super.dispose(); }

  Future<void> _handleCapture() async {
    final provider = Provider.of<AppStateProvider>(context, listen: false);

    // 1. Check Lock
    if (provider.isModeLocked(provider.chefMode)) {
      _showUnlockDialog(provider);
      return;
    }

    if (!_isInitialized) return;

    try {
      final imageX = await _controller!.takePicture();
      _showRotatingLoader();
      await provider.scanFood(File(imageX.path));
      Navigator.pop(context); // Close loader
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RecipeResultScreen()));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showRotatingLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => _RotatingLoadingDialog(),
    );
  }

  void _showUnlockDialog(AppStateProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Unlock Premium Chef?", style: TextStyle(color: Colors.white)),
        content: const Text("Watch a short video to unlock this specialized AI model.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(context);
              if (_rewardedAd != null) {
                _rewardedAd!.show(onUserEarnedReward: (_, __) {
                  provider.unlockMode(provider.chefMode);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mode Unlocked! Ready to Scan."), backgroundColor: Colors.green));
                  _loadRewardedAd(); // Load next
                });
              } else {
                provider.unlockMode(provider.chefMode);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad skipped (Dev Mode)")));
              }
            },
            child: const Text("Watch & Unlock", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(String modeKey, Map<String, dynamic> data, AppStateProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      isScrollControlled: true,
      builder: (c) {
        return Consumer<AppStateProvider>(
            builder: (ctx, prov, _) {
              final isLocked = prov.isModeLocked(modeKey);
              return Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: data['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: data['color'].withOpacity(0.3), blurRadius: 30)]
                      ),
                      child: Icon(data['icon'], size: 60, color: data['color']),
                    ),
                    const SizedBox(height: 24),
                    Text(data['title'], style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(data['desc'], textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.5)),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(c);
                          provider.setChefMode(modeKey);
                          if (isLocked) {
                            _showUnlockDialog(provider);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Switched to ${data['title']}"), backgroundColor: data['color'], duration: const Duration(seconds: 1)));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: data['color'], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLocked) const Icon(Icons.lock, size: 20),
                            if (isLocked) const SizedBox(width: 8),
                            Text(isLocked ? "Unlock Mode" : "Select Mode", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(backgroundColor: Colors.black);
    final provider = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),

          Center(
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1), borderRadius: BorderRadius.circular(30)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_corner(0), _corner(1)]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_corner(3), _corner(2)]),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.greenAccent),
          ),

          // 👨‍🍳 CHEF MODE SELECTOR
          Positioned(
            bottom: 140, left: 0, right: 0,
            child: SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: AppConstants.chefModes.keys.map((mode) {
                  final isSelected = provider.chefMode == mode;
                  final isLocked = provider.isModeLocked(mode);
                  final data = AppConstants.chefModes[mode];

                  return GestureDetector(
                    onTap: () => provider.setChefMode(mode),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: 300.ms,
                                width: 80, height: 80,
                                decoration: BoxDecoration(
                                  color: isSelected ? data['color'] : Colors.grey[900],
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: isSelected ? Colors.white : Colors.white24, width: 2),
                                  boxShadow: isSelected ? [BoxShadow(color: data['color'].withOpacity(0.5), blurRadius: 15)] : [],
                                ),
                                child: Icon(data['icon'], color: Colors.white, size: 36),
                              ),
                              if (isLocked)
                                Positioned(right: -4, top: -4, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle), child: const Icon(Icons.lock, size: 14, color: Colors.black)).animate().scale(begin: const Offset(0,0), end: const Offset(1,1))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 🛠️ THE FIX: Use 'mode' (key) directly for label
                              Text(mode.split(' ')[0], style: TextStyle(color: isSelected ? data['color'] : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showInfoSheet(mode, data, provider),
                                child: const Icon(Icons.info_outline, color: Colors.white38, size: 16),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _handleCapture,
                child: Container(
                  height: 80, width: 80,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 20)]),
                  child: const Icon(Icons.center_focus_strong, size: 40),
                ),
              ),
            ),
          ),
          Positioned(top: 60, left: 20, child: const BackButton(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _corner(int i) {
    return Container(width: 30, height: 30, decoration: BoxDecoration(border: Border(
      top: i < 2 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
      bottom: i > 1 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
      left: i % 2 == 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
      right: i % 2 != 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
    )));
  }
}

class _RotatingLoadingDialog extends StatefulWidget {
  @override
  State<_RotatingLoadingDialog> createState() => _RotatingLoadingDialogState();
}

class _RotatingLoadingDialogState extends State<_RotatingLoadingDialog> {
  final List<String> _msgs = ["Identifying Ingredients...", "Scanning Freshness...", "Checking Pantry...", "Calculating Savings...", "Calling Top Chefs...", "Generating Magic..."];
  int _index = 0;
  Timer? _timer;
  @override
  void initState() { super.initState(); _timer = Timer.periodic(const Duration(milliseconds: 2000), (t) { if(mounted) setState(() => _index = (_index + 1) % _msgs.length); }); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Lottie.asset('assets/animations/scanning.json', height: 150, errorBuilder: (c,e,s)=>const Icon(Icons.radar, size: 80, color: Colors.greenAccent)),
        const SizedBox(height: 30),
        Text(_msgs[_index], textAlign: TextAlign.center, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, decoration: TextDecoration.none, fontFamily: 'Courier')),
      ]),
    );
  }
}