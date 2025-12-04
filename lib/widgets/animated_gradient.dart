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
