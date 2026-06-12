import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/custom_image.dart';
import '../providers/cart_provider.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'product_details_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Wishlist",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: wishlistAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text('Failed to load wishlist'),
              TextButton(
                onPressed: () => ref.invalidate(wishlistProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (wishlistItems) {
          if (wishlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Your wishlist is empty",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: 100,
            ),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              return _buildWishlistCard(context, ref, wishlistItems[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(
      BuildContext context, WidgetRef ref, var product) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 80,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.backgroundLightAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Price row
                Text(
                  "₫${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Add to Cart + Delete row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(cartProvider.notifier)
                              .addItem(product, qty: 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${product.title} added to cart"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiaryDarker,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 16,
                        ),
                        label: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        ref.read(wishlistProvider.notifier).toggleWishlist(product);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
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
