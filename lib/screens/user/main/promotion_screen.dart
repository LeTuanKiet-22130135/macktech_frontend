import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../providers/promotion_provider.dart';
import '../../../models/promotion.dart';
import '../../../models/product.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_image.dart';
import '../../../services/product_service.dart';
import '../product/product_details_screen.dart';

class PromotionScreen extends ConsumerWidget {
  const PromotionScreen({super.key});

  void _onPromotionTapped(BuildContext context, Promotion promotion) async {
    if (promotion.linkedProductId == null) return;
    
    // Show a loading dialog while fetching product details
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await ProductService.fetchProductDetail(promotion.linkedProductId.toString());
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        // Create a basic Product object to pass to details screen
        final product = Product(
          id: detail.id,
          title: detail.title,
          brand: detail.brand,
          price: detail.price,
          imageUrl: detail.imageUrls.isNotEmpty ? detail.imageUrls.first : '',
          colors: detail.colors,
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product details.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(promotionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Promotions",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: promotionsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
              SizedBox(height: 16.h),
              Text("Failed to load promotions", style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () => ref.invalidate(promotionsProvider),
                child: Text("Retry"),
              )
            ],
          ),
        ),
        data: (promotions) {
          if (promotions.isEmpty) {
            return Center(
              child: Text(
                "No active promotions at the moment.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: promotions.length,
            separatorBuilder: (context, index) => SizedBox(height: 24.h),
            itemBuilder: (context, index) {
              final promo = promotions[index];
              return _buildPromotionCard(context, promo);
            },
          );
        },
      ),
    );
  }

  Widget _buildPromotionCard(BuildContext context, Promotion promo) {
    return GestureDetector(
      onTap: () => _onPromotionTapped(context, promo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Image
            SizedBox(
              height: 180.h,
              child: CustomImage(
                imageUrl: promo.bannerImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            
            // Details
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey.shade500),
                      SizedBox(width: 6.w),
                      Text(
                        _formatDateRange(promo.startDate, promo.endDate),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (promo.linkedProductId != null) ...[
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Shop Now",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.arrow_forward_ios, size: 12.sp, color: AppColors.primary),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = "${start.day}/${start.month}/${start.year}";
    final endStr = "${end.day}/${end.month}/${end.year}";
    return "$startStr - $endStr";
  }
}
