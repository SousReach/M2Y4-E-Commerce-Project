import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../utils/price_formatter.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  final bool embedded;
  const CartScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final content = Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (cart.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is empty',
            subtitle:
                'Looks like you haven\'t added\nanything yet. Start browsing!',
            actionLabel: 'Browse Watches',
            onAction: () => Navigator.pushNamed(context, '/products'),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return CartItemTile(
                    item: item,
                    onIncrement: () {
                      cart.updateQuantity(
                        item.product.id,
                        item.quantity + 1,
                        size: item.size,
                        color: item.color,
                      );
                    },
                    onDecrement: () {
                      if (item.quantity > 1) {
                        cart.updateQuantity(
                          item.product.id,
                          item.quantity - 1,
                          size: item.size,
                          color: item.color,
                        );
                      }
                    },
                    onRemove: () => cart.removeFromCart(item.id),
                  );
                },
              ),
            ),
            // Bottom summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${cart.itemCount} items)',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        Text(
                          formatPrice(cart.totalPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/checkout'),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: content,
    );
  }
}
