part of '../checkout_screen.dart';

// Empty Cart View Widget
class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey)
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 800))
              .scaleXY(begin: 0.5, end: 1.0),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[700],
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
          const SizedBox(height: 16),
          Text(
            'Add items to checkout',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate back to cart or product listing
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Return to Shopping'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 800))
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}