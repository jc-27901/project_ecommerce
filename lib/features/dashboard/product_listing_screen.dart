import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:project_ecommerce/models/cart_item_dm.dart';
import 'package:project_ecommerce/models/product_dm.dart';
import 'package:project_ecommerce/provider/cart_provider.dart';
import 'package:project_ecommerce/provider/product_provider.dart';

import '../product/product_details_screen.dart';

/// ProductListingScreen - The main screen to display products in a grid layout
/// Uses Provider pattern for state management and data fetching
class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data fetching after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// Initialize product and cart data
  void _initializeData() {
    // Fetch products and load cart items without rebuilding UI yet
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    Provider.of<CartProvider>(context, listen: false).loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return const _ProductListingView();
  }
}

/// Main view component for product listing
/// Handles different UI states: loading, error, empty, and products display
class _ProductListingView extends StatelessWidget {
  const _ProductListingView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        // Handle different UI states based on the product provider's state
        if (productProvider.isLoadingProducts) {
          return _buildLoadingView();
        }

        if (productProvider.error != null) {
          return _buildErrorView(context, productProvider);
        }

        if (productProvider.products.isEmpty) {
          return _buildEmptyView();
        }

        // Default view with products
        return _buildProductsView(context, productProvider);
      },
    );
  }

  /// Loading animation view with fading and scaling effects
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator()
              .animate()
              .fade(duration: const Duration(milliseconds: 500))
              .scale(),
          const SizedBox(height: 20),
          const Text("Loading products...")
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 300))
              .slideY(begin: 0.5, end: 0),
        ],
      ),
    );
  }

  /// Error view with animated error icon and retry button
  Widget _buildErrorView(
      BuildContext context, ProductProvider productProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 70, color: Colors.red)
              .animate()
              .shake(duration: const Duration(milliseconds: 700)),
          const SizedBox(height: 16),
          Text(
            'Error: ${productProvider.error}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => productProvider.fetchProducts(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
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

  /// Empty state view with fade and scale animations
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey)
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 800))
              .scaleXY(begin: 0.5, end: 1.0),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
          const SizedBox(height: 24),
          const Text(
            'Check back later for new arrivals',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
        ],
      ),
    );
  }

  /// Main product listing view with staggered grid
  Widget _buildProductsView(
      BuildContext context, ProductProvider productProvider) {
    return Column(
      children: [
        // Removed header content as it was commented out in original code

        // Main product grid with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => productProvider.fetchProducts(),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: const EdgeInsets.all(12),
              itemCount: productProvider.products.length,
              itemBuilder: (context, index) {
                final Product product = productProvider.products[index];

                // Calculate dynamic height for staggered effect
                final double height = _getHeightForIndex(index);

                // Apply staggered animation to each product card
                return ProductCard(
                  product: product,
                  height: height,
                  index: index,
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 100 * (index % 4)),
                    )
                    .slideY(begin: 0.2, end: 0);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Calculate dynamic height for product cards to create visual interest
  double _getHeightForIndex(int index) {
    // Create a pattern of different heights
    const List<double> pattern = [280, 380, 380, 280];
    return pattern[index % pattern.length];
  }
}

/// Product card widget for displaying individual products
/// Includes image, details, price, and action buttons
class ProductCard extends StatelessWidget {
  final Product product;
  final double height;
  final int index;

  const ProductCard({
    super.key,
    required this.product,
    required this.height,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'product-${product.id}',
      child: Material(
        // Material needed for proper Hero animation
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToProductDetails(context, product),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section with overlay and buttons
                  _buildProductImageSection(context),

                  // Details section with product info and price
                  _buildProductDetailsSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Product image section with gradient overlay and action buttons
  Widget _buildProductImageSection(BuildContext context) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product image background
          _buildProductImage(),

          // Gradient overlay for text visibility
          _buildGradientOverlay(),

          // Favorite and cart buttons in top right
          _buildActionButtons(context),

          // Discount label if applicable
          if (product.discountType != DiscountType.none)
            _buildDiscountLabel(context),
        ],
      ),
    );
  }

  /// Product image with cover fit
  Widget _buildProductImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(product.imageUrls.first),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// Gradient overlay for better text visibility
  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.4),
            ],
          ),
        ),
      ),
    );
  }

  /// Favorite and cart buttons
  Widget _buildActionButtons(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Row(
        children: [
          // Favorite button
          _buildIconButton(
            context,
            Icons.favorite_border,
            () => _toggleFavorite(context, product),
          ),
          const SizedBox(width: 8),

          // Cart button with dynamic icon based on cart state
          Consumer<CartProvider>(
            builder: (context, provider, _) {
              final CartItem? cartItem =
                  provider.getCartItemForProduct(product.id ?? '');
              return _buildIconButton(
                context,
                cartItem != null
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined,
                () => _handleCartAction(context, cartItem, provider),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Handle cart button action - remove if in cart, add if not
  void _handleCartAction(
      BuildContext context, CartItem? cartItem, CartProvider provider) {
    if (cartItem != null) {
      provider.removeFromCart(cartItem.id);
    } else {
      _addToCart(context, product, provider);
    }
  }

  /// Discount label for products on sale
  Widget _buildDiscountLabel(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _getDiscountText(product),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Product details section with name, description and price
  Widget _buildProductDetailsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Product description
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Price information
          _buildPriceSection(context),
        ],
      ),
    );
  }

  /// Price section showing current price and strikethrough original price if discounted
  Widget _buildPriceSection(BuildContext context) {
    return Row(
      children: [
        // Final price
        Text(
          '₹${product.finalPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),

        // Original price if discounted
        if (product.discountType != DiscountType.none)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '₹${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  /// Helper to build animated icon buttons
  Widget _buildIconButton(
      BuildContext context, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(
        begin: 1,
        end: 1.15,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut);
  }

  /// Get discount text based on discount type
  String _getDiscountText(Product product) {
    switch (product.discountType) {
      case DiscountType.percentage:
        return '${product.discountValue.toInt()}% OFF';
      case DiscountType.fixedAmount:
        return '₹${product.discountValue} OFF';
      default:
        return 'SALE';
    }
  }

  /// Navigate to product details screen
  void _navigateToProductDetails(BuildContext context, Product product) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product)));
  }

  /// Toggle favorite status
  void _toggleFavorite(BuildContext context, Product product) {
    // Implement toggling favorite status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Add product to cart
  void _addToCart(
      BuildContext context, Product product, CartProvider cartProvider) async {
    await cartProvider.addToCart(product, 1).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product.name} to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }
}
