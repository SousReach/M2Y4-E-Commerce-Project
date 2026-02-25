import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadFeaturedProducts();
      context.read<ProductProvider>().loadProducts();
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildExploreTab(),
            _buildOrdersTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 2) {
            context.read<ProductProvider>().loadProducts();
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => Text(
                        'Hi, ${auth.user?.name ?? 'there'} 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find your style',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Cart icon
                Consumer<CartProvider>(
                  builder: (context, cart, _) => Stack(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/cart'),
                        icon: const Icon(Icons.shopping_bag_outlined),
                      ),
                      if (cart.itemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: const Text(
              'Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];
                    return CategoryCard(
                      category: cat,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/products',
                          arguments: {
                            'categoryId': cat.id,
                            'categoryName': cat.name,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Featured Products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.featuredProducts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: provider.featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = provider.featuredProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: product.id,
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildExploreTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onSubmitted: (query) {
              context.read<ProductProvider>().loadProducts(query: query);
            },
            decoration: InputDecoration(
              hintText: 'Search clothing...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: Consumer<ProductProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.products.isEmpty) {
                return const Center(child: Text('No products found'));
              }
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: provider.products.length,
                itemBuilder: (context, index) {
                  final product = provider.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/product-detail',
                        arguments: product.id,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Your Orders'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/orders'),
            child: const Text('View Order History'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primary,
              child: Text(
                (auth.user?.name ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              auth.user?.name ?? 'User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              auth.user?.email ?? '',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            _profileTile(
              Icons.shopping_bag_outlined,
              'My Orders',
              () => Navigator.pushNamed(context, '/orders'),
            ),
            _profileTile(
              Icons.person_outline,
              'Edit Profile',
              () => Navigator.pushNamed(context, '/profile'),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
