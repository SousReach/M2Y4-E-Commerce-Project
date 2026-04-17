import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../config/api_config.dart';
import '../utils/price_formatter.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/recently_viewed_service.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;
  bool _addingToCart = false;
  String? _loadedProductId;
  String? _recordedProductId;

  // Recommendations
  List<Product> _recommendations = [];

  // Reviews
  List<dynamic> _reviews = [];
  bool _loadingReviews = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    if (productId != null && productId != _loadedProductId) {
      _loadedProductId = productId;
      _selectedSize = null;
      _selectedColor = null;
      context.read<ProductProvider>().loadProductById(productId);
      _loadReviews(productId);
    }
  }

  Future<void> _loadReviews(String productId) async {
    setState(() => _loadingReviews = true);
    try {
      final data = await ApiService.get(
        '${ApiConfig.baseUrl}/reviews/product/$productId',
      );
      if (!mounted) return;
      setState(() {
        _reviews = data as List;
        _loadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingReviews = false);
    }
  }

  void _recordView(Product product) {
    if (_recordedProductId != product.id) {
      _recordedProductId = product.id;
      RecentlyViewedService.add(product); // fire and forget
    }
  }

  void _loadRecommendations(Product product) {
    // Filter products from same category, excluding current product
    final provider = context.read<ProductProvider>();
    final all = provider.products;
    _recommendations = all
        .where((p) => p.categoryId == product.categoryId && p.id != product.id)
        .take(6)
        .toList();
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
          _recordView(product);
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
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            right: 12,
                            child: Consumer<WishlistProvider>(
                              builder: (context, wishlist, _) {
                                final isFav = wishlist.contains(product.id);
                                return CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20,
                                      color: isFav
                                          ? AppTheme.error
                                          : AppTheme.textPrimary,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await wishlist.toggle(product.id);
                                      } catch (_) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to update wishlist',
                                            ),
                                            backgroundColor: AppTheme.error,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
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
                              formatPrice(product.price),
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

                      // ── Rating Summary ──────────────────────
                      _buildRatingSummary(),

                      // ── You May Also Like ───────────────────
                      Builder(
                        builder: (_) {
                          _loadRecommendations(product);
                          if (_recommendations.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return _buildRecommendations();
                        },
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

  // ── Rating Summary ────────────────────────────────────────
  Widget _buildRatingSummary() {
    if (_loadingReviews) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_reviews.isEmpty) return const SizedBox.shrink();

    // Calculate breakdown
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double total = 0;
    for (final r in _reviews) {
      final rating = (r['rating'] ?? 0) as int;
      counts[rating] = (counts[rating] ?? 0) + 1;
      total += rating;
    }
    final avg = total / _reviews.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 32),
          const Text(
            'Ratings & Reviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Average score
              Column(
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < avg.round() ? Icons.star : Icons.star_border,
                        size: 16,
                        color: AppTheme.accent,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Star breakdown
              Expanded(
                child: Column(
                  children: [
                    for (int star = 5; star >= 1; star--)
                      _buildStarRow(star, counts[star]!, _reviews.length),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStarRow(int star, int count, int total) {
    final fraction = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: AppTheme.accent),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── You May Also Like ─────────────────────────────────────
  Widget _buildRecommendations() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 32),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'You May Also Like',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final rec = _recommendations[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product-detail',
                      arguments: rec.id,
                    );
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: rec.images.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: rec.images[0],
                                  height: 130,
                                  width: 150,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 130,
                                  width: 150,
                                  color: Colors.grey[100],
                                  child: const Icon(Icons.image),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatPrice(rec.price),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
