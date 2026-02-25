import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  bool _addingToCart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    if (productId != null) {
      context.read<ProductProvider>().loadProductById(productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading || provider.selectedProduct == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = provider.selectedProduct!;
          _selectedSize ??= product.sizes.isNotEmpty ? product.sizes[0] : null;
          _selectedColor ??= product.colors.isNotEmpty
              ? product.colors[0]
              : null;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Stack(
                        children: [
                          SizedBox(
                            height: 400,
                            width: double.infinity,
                            child: product.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: product.images[0],
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[100],
                                    child: const Icon(Icons.image, size: 80),
                                  ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            left: 12,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category
                            Text(
                              product.categoryName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Name
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Price
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Description
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Size selector
                            if (product.sizes.isNotEmpty) ...[
                              const Text(
                                'Size',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: product.sizes.map((size) {
                                  final isSelected = size == _selectedSize;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedSize = size),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        size,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Color selector
                            if (product.colors.isNotEmpty) ...[
                              const Text(
                                'Color',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: product.colors.map((color) {
                                  final isSelected = color == _selectedColor;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedColor = color),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        color,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add to cart button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: _addingToCart
                        ? null
                        : () async {
                            setState(() => _addingToCart = true);
                            try {
                              await context.read<CartProvider>().addToCart(
                                product.id,
                                size: _selectedSize ?? '',
                                color: _selectedColor ?? '',
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to cart!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add to cart'),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                            }
                            setState(() => _addingToCart = false);
                          },
                    child: _addingToCart
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Add to Cart'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
