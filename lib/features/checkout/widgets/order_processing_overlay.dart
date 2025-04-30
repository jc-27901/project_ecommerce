part of '../checkout_screen.dart';

class OrderProcessingOverlay extends StatelessWidget {
  const OrderProcessingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: BaseLoadingView(loadingText: 'Processing your order...'),
      ),
    );
  }
}
