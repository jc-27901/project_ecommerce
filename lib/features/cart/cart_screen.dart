import 'package:flutter/material.dart';
import 'package:project_ecommerce/utils/basWidgets/base_error_view.dart';
import 'package:project_ecommerce/utils/basWidgets/base_loading_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/cart_item_dm.dart';
import '../../models/product_dm.dart';
import '../../provider/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart')
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 400))
            .slideX(begin: -0.2, end: 0),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return cartProvider.cartItems.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearCartDialog(context),
              )
                  .animate()
                  .fadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 300))
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isLoading) {
            return BaseLoadingView(loadingText: 'Loading your cart...');
          }

          if (cartProvider.error != null) {
            return BaseErrorView(error: cartProvider.error!);
          }

          if (cartProvider.cartItems.isEmpty) {
            return EmptyCartView();
          }

          return _buildCartItemsView(context, cartProvider);
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.cartItems.isEmpty) {
            return const SizedBox.shrink();
          }

          return _buildCheckoutBar(context, cartProvider);
        },
      ),
    );
  }



  /// Cart items view
  Widget _buildCartItemsView(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100), // Make space for checkout bar
            itemCount: cartProvider.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartProvider.cartItems[index];
              final product = cartProvider.cartProducts[cartItem.productId];

              // If product is null, show placeholder or skip
              if (product == null) {
                return _buildUnavailableCartItem(context, cartItem);
              }

              return _buildCartItemCard(context, cartItem, product, index);
            },
          ),
        ),
      ],
    );
  }

  /// Build cart item card with product details
  Widget _buildCartItemCard(
      BuildContext context, CartItem cartItem, Product product, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Dismissible(
        key: Key(cartItem.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
        ),
        onDismissed: (direction) {
          Provider.of<CartProvider>(context, listen: false)
              .removeFromCart(cartItem.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} removed from cart'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(product, cartItem.quantity);
                },
              ),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrls.first,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.finalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.discountType != DiscountType.none)
                        Row(
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getDiscountText(product),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      if (!product.isAvailable)
                        Text(
                          'Currently unavailable',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Quantity Controls
                Column(
                  children: [
                    _buildQuantityControl(
                      context,
                      cartItem,
                      product.stockQuantity,
                      product.isAvailable,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${(product.finalPrice * cartItem.quantity).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: 100 * index),
        )
            .slideX(begin: 0.2, end: 0),
      ),
    );
  }

  /// Build UI for an unavailable product
  Widget _buildUnavailableCartItem(BuildContext context, CartItem cartItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product unavailable',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This product may have been removed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[400],
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .removeFromCart(cartItem.id);
                },
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideX(begin: 0.2, end: 0),
    );
  }

  /// Build quantity selector for cart item
  Widget _buildQuantityControl(
      BuildContext context, CartItem cartItem, int stockQuantity, bool isAvailable) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease quantity button
          InkWell(
            onTap: () {
              if (cartItem.quantity > 1 && isAvailable) {
                cartProvider.updateQuantity(cartItem.id, cartItem.quantity - 1);
              } else if (cartItem.quantity == 1) {
                cartProvider.removeFromCart(cartItem.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.grey[200] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 16,
                color: isAvailable ? Colors.black : Colors.grey,
              ),
            ),
          ),
          // Quantity display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.white,
            child: Text(
              '${cartItem.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Increase quantity button
          InkWell(
            onTap: isAvailable && cartItem.quantity < stockQuantity
                ? () {
              cartProvider.updateQuantity(
                  cartItem.id, cartItem.quantity + 1);
            }
                : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isAvailable && cartItem.quantity < stockQuantity
                    ? Colors.grey[200]
                    : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: isAvailable && cartItem.quantity < stockQuantity
                    ? Colors.black
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(
        begin: 1,
        end: 1.05,
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOut);
  }

  /// Build the checkout bar at bottom of screen
  Widget _buildCheckoutBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${cartProvider.cartItemCount} items):',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${cartProvider.cartTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to checkout screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'CHECKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 300),
    )
        .slideY(begin: 1, end: 0);
  }

  /// Display confirmation dialog for clearing the cart
  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<CartProvider>(context, listen: false).clearCart();
            },
            child: const Text(
              'CLEAR',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Get discount text based on discount type
  String _getDiscountText(Product product) {
    if (product.discountType == DiscountType.percentage) {
      return '${product.discountValue.toInt()}% OFF';
    } else if (product.discountType == DiscountType.fixedAmount) {
      return '₹${product.discountValue.toStringAsFixed(0)} OFF';
    } else {
      return 'SPECIAL OFFER';
    }
  }

  // Add this method to navigate to product details screen
}