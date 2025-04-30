part of '../checkout_screen.dart';
// Place Order Bar Widget
class PlaceOrderBar extends StatelessWidget {
  final double cartTotal;
  final double shippingFee;
  final double freeShippingThreshold;
  final bool isOrderPlacing;
  final Address? selectedAddress;
  final VoidCallback onPlaceOrder;

  const PlaceOrderBar(
      {super.key, required this.cartTotal, required this.shippingFee, required this.freeShippingThreshold, required this.isOrderPlacing, this.selectedAddress, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    final double subtotal = cartTotal;
    final double shipping =
    subtotal >= freeShippingThreshold ? 0.0 : shippingFee;
    final double tax = subtotal * 0.18; // 18% tax
    final double total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total:'),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: isOrderPlacing || selectedAddress == null
                    ? null
                    : () => onPlaceOrder(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 1000),
    );
  }
}