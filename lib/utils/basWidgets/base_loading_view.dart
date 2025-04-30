import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BaseLoadingView extends StatelessWidget {
  const BaseLoadingView({super.key, required this.loadingText});

  final String loadingText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator()
              .animate()
              .fade(duration: const Duration(milliseconds: 500))
              .scale(),
          const SizedBox(height: 20),
          Text(loadingText)
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 300))
              .slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }
}
