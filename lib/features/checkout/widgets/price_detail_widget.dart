part of '../checkout_screen.dart';
// Price Details Widget
class PriceDetailsWidget extends StatelessWidget {
  final double cartTotal;
  final double shippingFee;
  final double freeShippingThreshold;

  const PriceDetailsWidget({
    super.key,
    required this.cartTotal,
    required this.shippingFee,
    required this.freeShippingThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final double shipping = cartTotal >= freeShippingThreshold ? 0.0 : shippingFee;
    final double tax = cartTotal * 0.18; // 18% tax
    final double total = cartTotal + shipping + tax;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PriceRowWidget(
              label: 'Cart Subtotal',
              value: '₹${cartTotal.toStringAsFixed(2)}',
            ),
            PriceRowWidget(
              label: 'Shipping',
              value: shipping == 0.0 ? 'FREE' : '₹${shipping.toStringAsFixed(2)}',
              valueColor: shipping == 0.0 ? Colors.green : null,
              infoText: cartTotal >= freeShippingThreshold
                  ? 'Free shipping on orders above ₹499'
                  : 'Free shipping on orders above ₹499 (₹${(freeShippingThreshold - cartTotal).toStringAsFixed(2)} more to go)',
            ),
            PriceRowWidget(
              label: 'Tax (18% GST)',
              value: '₹${tax.toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            PriceRowWidget(
              label: 'Total Amount',
              value: '₹${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 900),
    )
        .slideY(begin: 0.1, end: 0);
  }
}

// Price Row Widget
class PriceRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;
  final String? infoText;

  const PriceRowWidget({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
    this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 16 : 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 16 : 14,
                  color: valueColor,
                ),
              ),
            ],
          ),
          if (infoText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                infoText!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}