import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Enhanced authentication button with loading animation and enabled state
class AnimatedFilledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final bool isEnabled;

  const AnimatedFilledButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (isLoading || !isEnabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? colorScheme.primary : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 4 : 0,
          shadowColor: isEnabled
              ? colorScheme.primary.withValues(alpha: 0.5)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    )
        .animate()
        .scale(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        )
        .then()
        .shimmer(
          delay: const Duration(milliseconds: 600),
          duration: const Duration(seconds: 1),
          color: isEnabled
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.transparent,
        );
  }
}
