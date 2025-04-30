// Error View Widget
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BaseErrorView extends StatelessWidget {
  final String error;

  const BaseErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 70, color: Colors.red)
              .animate()
              .shake(duration: const Duration(milliseconds: 700)),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 500))
              .slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }
}