import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../utils/price_formatter.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlist, _) {
          if (wishlist.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (wishlist.products.isEmpty) {
            return _buildEmpty(context);
          }
          return RefreshIndicator(
            onRefresh: () => wishlist.loadWishlist(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: wishlist.products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = wishlist.products[index];
                return _buildWishlistItem(context, wishlist, product);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 72,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Save items you love for later',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 44),
            ),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    WishlistProvider wishlist,
    product,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Thumbnail
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/product-detail',
              arguments: product.id,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.images[0],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[100],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/product-detail',
                arguments: product.id,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Column(
            children: [
              IconButton(
                onPressed: () async {
                  try {
                    await wishlist.remove(product.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Removed from wishlist'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } catch (_) {}
                },
                icon: const Icon(
                  Icons.favorite,
                  color: AppTheme.error,
                  size: 22,
                ),
                tooltip: 'Remove',
              ),
              IconButton(
                onPressed: () async {
                  try {
                    await context.read<CartProvider>().addToCart(
                          product.id,
                          size: product.sizes.isNotEmpty
                              ? product.sizes[0]
                              : '',
                          color: product.colors.isNotEmpty
                              ? product.colors[0]
                              : '',
                        );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add to cart'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.add_shopping_cart_outlined,
                  color: AppTheme.primary,
                  size: 22,
                ),
                tooltip: 'Add to cart',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
