import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../widgets/custom_image.dart';
import '../../../providers/cart_provider.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'product_details_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';
import 'package:app_frontend/utils/num_extension.dart';
import '../../../models/product.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.wishlist,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: wishlistAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 40.sp),
              SizedBox(height: 12.h),
              Text(AppLocalizations.of(context)!.failedToLoadWishlist),
              TextButton(
                onPressed: () => ref.invalidate(wishlistProvider),
                child: Text(AppLocalizations.of(context)!.retry),
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
                  Icon(Icons.favorite_border, size: 80.sp, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text(AppLocalizations.of(context)!.yourWishlistIsEmpty,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 8.h,
              bottom: 100.h,
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
      BuildContext context, WidgetRef ref, Product product) {

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
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 80.w,
            height: 90.h,
            decoration: BoxDecoration(
              color: AppColors.backgroundLightAlt,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: CustomImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                // Price row
                Text(
                  "₫${product.price.toPrice()}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),

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
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiaryDarker,
                          foregroundColor: Colors.white,
                          minimumSize: Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12.w),
                        ),
                        icon: Icon(
                          Icons.shopping_cart_outlined,
                          size: 16.sp,
                        ),
                        label: Text(AppLocalizations.of(context)!.addToCart,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        ref.read(wishlistProvider.notifier).toggleWishlist(product);
                      },
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20.sp,
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
