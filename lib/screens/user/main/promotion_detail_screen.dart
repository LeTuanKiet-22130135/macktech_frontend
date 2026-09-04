import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/promotion.dart';
import '../../../models/product.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/product_card.dart';
import '../../../services/product_service.dart';
import 'package:app_frontend/utils/num_extension.dart';

class PromotionDetailScreen extends StatefulWidget {
  final Promotion promotion;

  const PromotionDetailScreen({super.key, required this.promotion});

  @override
  State<PromotionDetailScreen> createState() => _PromotionDetailScreenState();
}

class _PromotionDetailScreenState extends State<PromotionDetailScreen> {
  List<Product>? _fullProducts;
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (widget.promotion.products.isEmpty) {
      if (mounted) {
        setState(() {
          _fullProducts = [];
          _isLoadingProducts = false;
        });
      }
      return;
    }
    
    try {
      final List<Product> loaded = [];
      for (final p in widget.promotion.products) {
        final detail = await ProductService.fetchProductDetail(p.sku);
        
        double finalPrice = detail.price;
        String finalSubText = detail.subText;
        
        if (p.discountPercentage != null && p.discountPercentage! > 0) {
          finalPrice = detail.price * (1 - p.discountPercentage! / 100);
          finalSubText = detail.price.toPrice();
        }

        loaded.add(Product(
          id: detail.id,
          title: detail.title,
          brand: detail.brand,
          subText: finalSubText,
          price: finalPrice,
          imageUrl: detail.imageUrls.isNotEmpty ? detail.imageUrls.first : '',
          colors: detail.colors,
        ));
      }
      if (mounted) {
        setState(() {
          _fullProducts = loaded;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load promotional products")),
        );
      }
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = "${start.day}/${start.month}/${start.year}";
    final endStr = "${end.day}/${end.month}/${end.year}";
    return "$startStr - $endStr";
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
                  if (promo.description != null && promo.description!.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Text(
                      promo.description!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  
                  if (promo.products.isNotEmpty) ...[
                    Text(
                      "Included Products",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    if (_isLoadingProducts)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_fullProducts != null && _fullProducts!.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: _fullProducts!.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: _fullProducts![index]);
                        },
                      )
                    else
                      Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            "Failed to load products",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                  ] else ...[
                    Center(
                      child: Text(
                        "No specific products linked to this promotion.",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
