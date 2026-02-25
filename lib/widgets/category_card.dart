import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipOval(
                child: category.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[100]),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.category, size: 28),
                      )
                    : const Icon(Icons.category, size: 28),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
