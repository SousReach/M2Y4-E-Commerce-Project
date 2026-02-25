import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null && args['categoryId'] != null) {
      context.read<ProductProvider>().loadProductsByCategory(
        args['categoryId']!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final categoryName = args?['categoryName'] ?? 'Products';

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.products.isEmpty) {
            return const Center(child: Text('No products in this category'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
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
    );
  }
}
