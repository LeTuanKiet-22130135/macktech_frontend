import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';
import '../../../models/product_detail.dart';
import '../../../models/review.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../providers/product_detail_provider.dart';
import '../../../services/review_service.dart';
import '../../../widgets/review_card.dart';
import 'reviews_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';
import '../../../services/recombee_tracking_service.dart';
import '../../../services/product_service.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/custom_image.dart';
import 'package:app_frontend/l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:app_frontend/utils/num_extension.dart';
class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;
  final String? recommId;
  const ProductDetailsScreen({super.key, required this.product, this.recommId});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int quantity = 1;
  bool _descriptionExpanded = false;
  int _currentImageIndex = 0;
  int _selectedColorIndex = 0;
  final PageController _imagePageController = PageController();

  List<Review> _recentReviews = [];
  bool _isLoadingReviews = true;
  double _averageRating = 0.0;
  int _totalReviews = 0;

  List<Product> _similarProducts = [];
  bool _isLoadingSimilar = true;

  @override
  void initState() {
    super.initState();
    // Fire Recombee click tracking event when user opens the screen
    RecombeeTrackingService.trackDetailView(widget.product.id, recommId: widget.recommId);
    _fetchReviews();
    _fetchSimilarProducts();
  }

  Future<void> _fetchSimilarProducts() async {
    try {
      final similar = await ProductService.fetchSimilarProducts(widget.product.id, limit: 10);
      if (mounted) {
        setState(() {
          _similarProducts = similar;
          _isLoadingSimilar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSimilar = false;
        });
      }
    }
  }

  Future<void> _fetchReviews() async {
    final reviews = await ReviewService.getProductReviews(widget.product.id);
    if (mounted) {
      setState(() {
        _totalReviews = reviews.length;
        if (reviews.isNotEmpty) {
          final sum = reviews.fold(0.0, (prev, element) => prev + element.rating);
          _averageRating = sum / reviews.length;
          _recentReviews = reviews.take(2).toList();
        } else {
          _averageRating = 0.0;
          _recentReviews = [];
        }
        _isLoadingReviews = false;
      });
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(productDetailProvider(widget.product.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: detailAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(error),
          data: (detail) => _buildDetailContent(detail),
        ),
      ),
    );
  }

  // ───────── Loading State ─────────

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Back button row while loading
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, size: 20.sp),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // ───────── Error State ─────────

  Widget _buildErrorState(Object error) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, size: 20.sp),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48.sp),
                SizedBox(height: 16.h),
                Text(AppLocalizations.of(context)!.failedToLoadProductDetails,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
                ),
                SizedBox(height: 16.h),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(
                      productDetailProvider(widget.product.id)),
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────── Main Content ─────────

  Widget _buildDetailContent(ProductDetail detail) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image carousel
                _buildImageCarousel(detail),

                // Title + Quantity row
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                                color: AppColors.tertiaryDarker,
                              ),
                            ),
                            if (detail.brand.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                detail.brand,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            SizedBox(height: 8.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (detail.subText.isNotEmpty) ...[
                                  Text(
                                    "₫${detail.subText}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Text(
                                  "₫${detail.price.toPrice()}",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      _buildQuantityControls(),
                    ],
                  ),
                ),

                // Stock badge
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _buildStockBadge(detail),
                ),

                // Total Price
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.totalPrice,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '₫${(detail.price * quantity).toPrice()}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiaryDarker,
                        ),
                      ),
                    ],
                  ),
                ),

                // Colors
                if (detail.colors.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: _buildColorChips(detail.colors),
                  ),

                // Key Features
                if (detail.keyFeatures.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: _buildKeyFeatures(detail.keyFeatures),
                  ),

                // Add to Cart + Wishlist row
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _buildActionRow(detail),
                ),

                // Description section
                if (detail.description.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _buildDescription(detail),
                  ),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Divider(height: 1),
                ),

                // Reviews section
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _buildReviewsSection(),
                ),

                SizedBox(height: 16.h),
                _buildSimilarProductsSection(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────── Image Carousel ─────────

  Widget _buildImageCarousel(ProductDetail detail) {
    final images =
        detail.imageUrls.isNotEmpty ? detail.imageUrls : [widget.product.imageUrl];

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300.h,
          color: AppColors.backgroundLightAlt,
          child: PageView.builder(
            controller: _imagePageController,
            itemCount: images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(32.w),
                child: CustomImage(imageUrl: images[index], fit: BoxFit.contain),
              );
            },
          ),
        ),

        // Back button
        Positioned(
          top: 12.h,
          left: 16.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black),
            ),
          ),
        ),

        // Left arrow
        if (images.length > 1 && _currentImageIndex > 0)
          Positioned(
            left: 8.w,
            top: 140.h,
            child: GestureDetector(
              onTap: () {
                _imagePageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.chevron_left, size: 20.sp, color: Colors.grey),
              ),
            ),
          ),

        // Right arrow
        if (images.length > 1 && _currentImageIndex < images.length - 1)
          Positioned(
            right: 8.w,
            top: 140.h,
            child: GestureDetector(
              onTap: () {
                _imagePageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chevron_right,
                    size: 20.sp, color: Colors.grey),
              ),
            ),
          ),

        // Dot indicators
        if (images.length > 1)
          Positioned(
            bottom: 16.h,
            left: 0.w,
            right: 0.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final isActive = i == _currentImageIndex;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: isActive ? 28 : 8,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.tertiaryDarker
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // ───────── Stock Badge ─────────

  Widget _buildStockBadge(ProductDetail detail) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: detail.inStock
                ? AppColors.success.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            detail.inStock
                ? '${AppLocalizations.of(context)!.inStock} (${detail.stockQuantity})'
                : AppLocalizations.of(context)!.outOfStock,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: detail.inStock ? AppColors.success : Colors.red,
            ),
          ),
        ),
        if (detail.sku.isNotEmpty) ...[
          SizedBox(width: 12.w),
          Text(
            '${AppLocalizations.of(context)!.sku} ${detail.sku}',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
          ),
        ],
      ],
    );
  }

  // ───────── Color Chips ─────────

  Widget _buildColorChips(List<String> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.availableColors,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryDarker,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(colors.length, (index) {
            final color = colors[index];
            final isSelected = _selectedColorIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tertiaryDarker : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.tertiaryDarker : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  color,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ───────── Key Features ─────────

  Widget _buildKeyFeatures(String keyFeatures) {
    // Split by newline; each line is a feature bullet
    final features = keyFeatures
        .split('\n')
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();

    if (features.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.keyFeatures,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryDarker,
          ),
        ),
        SizedBox(height: 8.h),
        ...features.map((spec) {
          return Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Container(
                    width: 5.w,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryDarker,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    spec,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ───────── Quantity Controls ─────────

  Widget _buildQuantityControls() {
    return Row(
      children: [
        _buildQtyBtn(Icons.remove, () {
          if (quantity > 1) setState(() => quantity--);
        }),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            '$quantity',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        _buildQtyBtn(Icons.add, () {
          setState(() => quantity++);
        }),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16.sp, color: Colors.grey.shade700),
      ),
    );
  }

  // ───────── Action Row ─────────

  Widget _buildActionRow(ProductDetail detail) {
    return Row(
      children: [
        // Add to Cart button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: detail.inStock
                ? () {
                    final selectedColor = detail.colors.isNotEmpty
                        ? detail.colors[_selectedColorIndex.clamp(0, detail.colors.length - 1)]
                        : null;
                    ref
                        .read(cartProvider.notifier)
                        .addItem(widget.product, qty: quantity, selectedColor: selectedColor);
                    _showAddedToCartDialog();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiaryDarker,
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              minimumSize: Size(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.r),
              ),
              elevation: 0,
            ),
            icon: Icon(Icons.shopping_cart_outlined, size: 20.sp),
            label: Text(
              detail.inStock ? 'Add to Cart' : 'Out of Stock',
              style:
                  TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        // Wishlist heart button
        Consumer(
          builder: (context, ref, child) {
            ref.watch(wishlistProvider);
            final isWished = ref.read(wishlistProvider.notifier).isInWishlist(detail.id);
            return GestureDetector(
              onTap: () {
                final product = Product(
                  id: detail.id,
                  title: detail.title,
                  brand: detail.brand,
                  price: detail.price,
                  imageUrl: detail.imageUrls.isNotEmpty ? detail.imageUrls.first : '',
                );
                ref.read(wishlistProvider.notifier).toggleWishlist(product);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isWished ? "Removed from wishlist" : "Added to wishlist"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 52.w,
                height: 52.h,
                decoration: BoxDecoration(
                  color: isWished ? Colors.white : AppColors.tertiaryDarker,
                  shape: BoxShape.circle,
                  border: isWished ? Border.all(color: AppColors.border) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? Colors.redAccent : Colors.white,
                  size: 22.sp,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ───────── Description ─────────

  Widget _buildDescription(ProductDetail detail) {
    // Show up to ~200 chars when collapsed, full when expanded
    final fullText = detail.description;
    final isLong = fullText.length > 200;
    final displayText =
        (!_descriptionExpanded && isLong) ? '${fullText.substring(0, 200)}…' : fullText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.description,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryDarker,
          ),
        ),
        SizedBox(height: 8.h),
        MarkdownBody(
          data: displayText,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
        ),
        if (isLong) ...[
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () =>
                setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Row(
              children: [
                Text(
                  _descriptionExpanded ? 'Show less' : 'Read more',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiaryNormal,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  _descriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20.sp,
                  color: AppColors.tertiaryNormal,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ───────── Reviews Section ─────────

  Widget _buildReviewsSection() {
    return Column(
      children: [
        // Reviews header with View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(AppLocalizations.of(context)!.reviews,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
                if (!_isLoadingReviews && _totalReviews > 0) ...[
                  SizedBox(width: 8.w),
                  Text(
                    '$_totalReviews',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewsScreen(productId: widget.product.id)),
                ).then((_) => _fetchReviews()); // Refresh when coming back
              },
              child: Text(AppLocalizations.of(context)!.viewAll,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiaryNormal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        if (_isLoadingReviews)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: CircularProgressIndicator(),
          )
        else if (_recentReviews.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(AppLocalizations.of(context)!.noReviewsYet,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          Column(
            children: [
              // Overall rating summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp, height: 1),
                  ),
                  SizedBox(width: 6.w),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < _averageRating ? Icons.star : Icons.star_half,
                        size: 20.sp,
                        color: AppColors.star,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              
              // Recent reviews
              ..._recentReviews.map((review) => ReviewCard(
                review: review,
                onReviewChanged: _fetchReviews,
              )),
            ],
          ),
      ],
    );
  }

  Widget _buildSimilarProductsSection() {
    if (_isLoadingSimilar) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_similarProducts.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(AppLocalizations.of(context)!.similarProducts,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 260.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: _similarProducts.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 160.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: _similarProducts[index]),
                      ),
                    );
                  },
                  child: ProductCard(
                    product: _similarProducts[index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ───────── Added to Cart Dialog ─────────

  void _showAddedToCartDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 60.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success, width: 3.w),
                  ),
                  child: Center(
                    child: Icon(Icons.check, color: AppColors.success, size: 44.sp),
                  ),
                ),
                SizedBox(height: 28.h),
                Text(AppLocalizations.of(context)!.addedToCart,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
