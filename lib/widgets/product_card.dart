import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../screens/product_details_screen.dart';
import '../providers/wishlist_provider.dart';

import 'custom_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String? recommId;

  const ProductCard({super.key, required this.product, this.recommId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product, recommId: recommId)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomImage(imageUrl: product.imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer(
                      builder: (context, ref, child) {
                        ref.watch(wishlistProvider);
                        final isWished = ref.read(wishlistProvider.notifier).isInWishlist(product.id);
                        return GestureDetector(
                          onTap: () {
                            ref.read(wishlistProvider.notifier).toggleWishlist(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isWished ? "Removed from wishlist" : "Added to wishlist"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isWished ? Colors.white : Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isWished ? Icons.favorite : Icons.favorite_border,
                              color: isWished ? Colors.redAccent : Colors.grey.shade600,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₫${product.price.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const Icon(Icons.shopping_cart_outlined, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
