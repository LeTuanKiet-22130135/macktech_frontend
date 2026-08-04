import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/promotion.dart';
import '../../../models/product.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_image.dart';
import '../../../services/product_service.dart';
import '../product/product_details_screen.dart';

class PromotionDetailScreen extends StatefulWidget {
  final Promotion promotion;

  const PromotionDetailScreen({super.key, required this.promotion});

  @override
  State<PromotionDetailScreen> createState() => _PromotionDetailScreenState();
}

class _PromotionDetailScreenState extends State<PromotionDetailScreen> {
  bool _isLoading = false;

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = "${start.day}/${start.month}/${start.year}";
    final endStr = "${end.day}/${end.month}/${end.year}";
    return "$startStr - $endStr";
  }

  Future<void> _onShopNowTapped() async {
    if (widget.promotion.sku == null || widget.promotion.sku!.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await ProductService.fetchProductDetail(widget.promotion.sku!);
      if (mounted) {
        final product = Product(
          id: detail.id,
          title: detail.title,
          brand: detail.brand,
          subText: detail.subText,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load product details")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promotion;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Promotion Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'promo_${promo.id ?? promo.title}',
              child: CustomImage(
                imageUrl: promo.bannerImageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey.shade500),
                      SizedBox(width: 8.w),
                      Text(
                        _formatDateRange(promo.startDate, promo.endDate),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  if (promo.sku != null && promo.sku!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onShopNowTapped,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isLoading 
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                "Shop Now",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
    );
  }
}
