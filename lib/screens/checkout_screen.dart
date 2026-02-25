import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPlacing = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacing = true);

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final items = cart.items
        .map(
          (item) => OrderItem(
            productId: item.product.id,
            name: item.product.name,
            price: item.product.price,
            quantity: item.quantity,
            size: item.size,
            color: item.color,
          ),
        )
        .toList();

    final shippingAddress = ShippingAddress(
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final order = await orderProvider.placeOrder(
      items: items,
      totalPrice: cart.totalPrice,
      shippingAddress: shippingAddress,
    );

    if (!mounted) return;
    setState(() => _isPlacing = false);

    if (order != null) {
      cart.clearCart();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.success, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Order Placed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Failed to place order'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...cart.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.name} x${item.quantity}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${cart.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Shipping address
              const Text(
                'Shipping Address',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: 'Street Address',
                controller: _streetController,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'City',
                controller: _cityController,
                prefixIcon: const Icon(Icons.location_city_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Country',
                controller: _countryController,
                prefixIcon: const Icon(Icons.flag_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Place Order',
                onPressed: _placeOrder,
                isLoading: _isPlacing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
