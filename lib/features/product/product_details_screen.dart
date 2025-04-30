import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:project_ecommerce/models/product_dm.dart';

/// Product Details Screen - Displays detailed information about a single product
/// Includes animated UI elements, image carousel, and product information sections
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Current image index for the carousel
  int _currentImageIndex = 0;

  // Animation controller for button animations
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar with product image
              _buildSliverAppBar(),

              // Product details
              SliverToBoxAdapter(
                child: _buildProductDetails(),
              ),
            ],
          ),

          // Bottom action bar with price and buttons
          _buildBottomActionBar(),

          // Custom back button
          _buildBackButton(),
        ],
      ),
    );
  }

  /// Build sliver app bar with image carousel
  Widget _buildSliverAppBar() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = MediaQuery.of(context).size.height * 0.45;

    return SliverAppBar(
      expandedHeight: appBarHeight,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: _showAppBarTitle
            ? Text(
          widget.product.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn()
            : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image carousel
            PageView.builder(
              itemCount: widget.product.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Hero(
                  tag: 'product-${widget.product.id}',
                  child: Image.network(
                    widget.product.imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Image indicators
            if (widget.product.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.product.imageUrls.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.white.withOpacity(0.5),
                      ),
                    ).animate(target: _currentImageIndex == index ? 1 : 0)
                        .scale(begin: Offset(0.8, 0.8), end: Offset(1.2, 1.2), duration: const Duration(milliseconds: 300));
                  }),
                ),
              ),

            // Discount badge if applicable
            if (widget.product.discountType != DiscountType.none)
              Positioned(
                top: statusBarHeight + 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getDiscountText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 300))
                  .slideX(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  /// Build product details section
  Widget _buildProductDetails() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and availability status
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.product.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.product.isAvailable ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    color: widget.product.isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: const Duration(milliseconds: 100))
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Price information
          _buildPriceSection().animate()
              .fadeIn(delay: const Duration(milliseconds: 200))
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Description
          _buildSectionTitle('Description'),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),

          const SizedBox(height: 24),

          // Stock information
          _buildSectionTitle('Stock Information'),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Available Quantity',
            '${widget.product.stockQuantity} units',
          ).animate().fadeIn(delay: const Duration(milliseconds: 400)),

          const SizedBox(height: 24),

          // Category information
          _buildSectionTitle('Category'),
          const SizedBox(height: 8),
          _buildCategoryChip().animate()
              .fadeIn(delay: const Duration(milliseconds: 500)),

          const SizedBox(height: 24),

          // Product attributes
          _buildSectionTitle('Specifications'),
          const SizedBox(height: 12),
          _buildAttributesSection().animate()
              .fadeIn(delay: const Duration(milliseconds: 600)),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  /// Build price section with discounted price if applicable
  Widget _buildPriceSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Final price
        Text(
          '₹${widget.product.finalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),

        // Original price if discounted
        if (widget.product.discountType != DiscountType.none) ...[
          const SizedBox(width: 12),
          Text(
            '₹${widget.product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          // Discount percentage
          if (widget.product.discountType == DiscountType.percentage)
            Text(
              '${widget.product.discountValue.toInt()}% OFF',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
        ],
      ],
    );
  }

  /// Build section titles with consistent styling
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// Build information row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build category chip with icon
  Widget _buildCategoryChip() {
    IconData categoryIcon;
    switch (widget.product.category) {
      case ProductCategory.electronics:
        categoryIcon = Icons.devices;
        break;
      case ProductCategory.clothing:
        categoryIcon = Icons.checkroom;
        break;
      case ProductCategory.furniture:
        categoryIcon = Icons.chair;
        break;
      case ProductCategory.groceries:
        categoryIcon = Icons.shopping_basket;
        break;
      case ProductCategory.beauty:
        categoryIcon = Icons.spa;
        break;
      case ProductCategory.toys:
        categoryIcon = Icons.toys;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return Chip(
      avatar: Icon(
        categoryIcon,
        size: 18,
        color: Theme.of(context).primaryColor,
      ),
      label: Text(
        _capitalizeFirstLetter(widget.product.category.toString().split('.').last),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  /// Build attributes section from the product's attributes map
  Widget _buildAttributesSection() {
    if (widget.product.attributes.isEmpty) {
      return const Text(
        'No specifications available for this product.',
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
      );
    }

    return Column(
      children: widget.product.attributes.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  _capitalizeFirstLetter(entry.key),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build bottom action bar with add to cart and favorite buttons
  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Favorite button
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.favorite_border,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(
              begin: 1,
              end: 1.05,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
            ),

            const SizedBox(width: 16),

            // Add to Cart button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.product.isAvailable ? () {} : null,
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 300))
                  .slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }

  /// Build custom back button
  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 200));
  }

  /// Helper method to get discount text
  String _getDiscountText() {
    switch (widget.product.discountType) {
      case DiscountType.percentage:
        return '${widget.product.discountValue.toInt()}% OFF';
      case DiscountType.fixedAmount:
        return '₹${widget.product.discountValue} OFF';
      default:
        return 'SALE';
    }
  }

  /// Helper method to capitalize first letter of a string
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}