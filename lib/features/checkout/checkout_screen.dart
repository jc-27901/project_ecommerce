import 'package:flutter/material.dart';
import 'package:project_ecommerce/features/address/address_form.dart';
import 'package:project_ecommerce/provider/user_profile_provider.dart';
import 'package:project_ecommerce/utils/basWidgets/base_loading_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/address_dm.dart';
import '../../provider/cart_provider.dart';
import '../../provider/address_provider.dart';
import '../../utils/basWidgets/base_error_view.dart';
part 'widgets/empty_cart_view.dart';
part 'widgets/section_header.dart';
part 'widgets/order_summary_widget.dart';
part 'widgets/order_processing_overlay.dart';
part 'widgets/address_selection_widget.dart';
part 'widgets/place_order_widget.dart';
part 'widgets/price_detail_widget.dart';
part 'widgets/payment_method_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOrderPlacing = false;
  Address? _selectedAddress;
  String _paymentMethod = 'COD'; // Default to Cash on Delivery
  final double _shippingFee = 49.0; // Default shipping fee
  final double _freeShippingThreshold = 499.0; // Free shipping threshold

  @override
  void initState() {
    super.initState();
    // Load addresses when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      UserProfileProvider userProvider = Provider.of(context, listen: false);
      await Provider.of<AddressProvider>(context, listen: false)
          .loadUserAddresses(userProvider.currentUserProfile!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Checkout')
            .animate()
            .fadeIn(duration: const Duration(milliseconds: 400))
            .slideX(begin: -0.2, end: 0),
        elevation: 0,
      ),
      body: Consumer2<CartProvider, AddressProvider>(
        builder: (context, cartProvider, addressProvider, _) {
          if (cartProvider.isLoading || addressProvider.isLoading) {
            return BaseLoadingView(loadingText: 'Preparing your checkout...');
          }

          if (cartProvider.error != null) {
            return BaseErrorView(error: cartProvider.error!);
          }

          if (addressProvider.error != null) {
            return BaseErrorView(error: addressProvider.error!);
          }

          if (cartProvider.cartItems.isEmpty) {
            return const EmptyCartView();
          }

          // Initialize selected address if not already selected
          if (_selectedAddress == null &&
              addressProvider.defaultAddress != null) {
            _selectedAddress = addressProvider.defaultAddress;
          }

          return _buildCheckoutContent(context, cartProvider, addressProvider);
        },
      ),
    );
  }

  /// Main checkout content
  Widget _buildCheckoutContent(BuildContext context, CartProvider cartProvider,
      AddressProvider addressProvider) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120), // Space for bottom bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary section
              SectionHeader(title: 'Order Summary', icon: Icons.shopping_bag_outlined),
              OrderSummaryWidget(cartProvider: cartProvider),

              // Delivery address section
              SectionHeader(title: 'Delivery Address', icon: Icons.location_on_outlined),
              AddressSelectionWidget(
                addresses: addressProvider.addresses,
                selectedAddress: _selectedAddress,
                onAddressSelected: (address) {
                  setState(() {
                    _selectedAddress = address;
                  });
                },
              ),

              // Payment method section
              SectionHeader(title: 'Payment Method', icon: Icons.payment_outlined),
              PaymentMethodWidget(
                selectedMethod: _paymentMethod,
                onMethodSelected: (method) {
                  setState(() {
                    _paymentMethod = method;
                  });
                },
              ),

              // Order summary
              SectionHeader(title: 'Price Details', icon: Icons.receipt_long_outlined),
              PriceDetailsWidget(
                cartTotal: cartProvider.cartTotal,
                shippingFee: _shippingFee,
                freeShippingThreshold: _freeShippingThreshold,
              ),
            ],
          ),
        ),

        // Place order button at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: PlaceOrderBar(
            cartTotal: cartProvider.cartTotal,
            shippingFee: _shippingFee,
            freeShippingThreshold: _freeShippingThreshold,
            isOrderPlacing: _isOrderPlacing,
            selectedAddress: _selectedAddress,
            onPlaceOrder: () => _placeOrder(context, cartProvider),
          ),
        ),

        // Loading overlay
        if (_isOrderPlacing)
          const OrderProcessingOverlay(),
      ],
    );
  }

  /// Place order logic
  Future<void> _placeOrder(
      BuildContext context, CartProvider cartProvider) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() {
      _isOrderPlacing = true;
    });

    try {
      // For demo purposes, simulate a network delay
      await Future.delayed(const Duration(seconds: 2));

      // Clear cart after successful order
      await cartProvider.clearCart();
      if (!context.mounted) return;
      // Navigate to order success screen
      Navigator.of(context).pushReplacementNamed('/order-success');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOrderPlacing = false;
        });
      }
    }
  }
}








