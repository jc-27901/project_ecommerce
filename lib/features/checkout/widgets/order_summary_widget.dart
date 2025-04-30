part of '../checkout_screen.dart';

// Order Summary Widget
class OrderSummaryWidget extends StatelessWidget {
  final CartProvider cartProvider;

  const OrderSummaryWidget({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${cartProvider.cartItemCount} Items',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to cart
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...List.generate(
              cartProvider.cartItems.length > 3
                  ? 3
                  : cartProvider.cartItems.length,
                  (index) {
                final cartItem = cartProvider.cartItems[index];
                final product = cartProvider.cartProducts[cartItem.productId];

                if (product == null) {
                  return const SizedBox.shrink(); // Skip unavailable products
                }

                return CartItemWidget(
                  productImage: product.imageUrls.first,
                  productName: product.name,
                  quantity: cartItem.quantity,
                  price: product.finalPrice * cartItem.quantity,
                  index: index,
                );
              },
            ),

            // Show "more items" if needed
            if (cartProvider.cartItems.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+ ${cartProvider.cartItems.length - 3} more items',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 100),
    )
        .slideY(begin: 0.1, end: 0);
  }
}

// Cart Item Widget
class CartItemWidget extends StatelessWidget {
  final String productImage;
  final String productName;
  final int quantity;
  final double price;
  final int index;

  const CartItemWidget({
    super.key,
    required this.productImage,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey, size: 20),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Price
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}