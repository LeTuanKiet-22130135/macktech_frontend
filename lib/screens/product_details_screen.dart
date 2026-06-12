import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/product_detail.dart';
import '../models/review.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/product_detail_provider.dart';
import '../services/review_service.dart';
import '../widgets/custom_image.dart';
import '../widgets/review_card.dart';
import 'reviews_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';
import '../services/recombee_tracking_service.dart';

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

  @override
  void initState() {
    super.initState();
    // Fire Recombee click tracking event when user opens the screen
    RecombeeTrackingService.trackDetailView(widget.product.id, recommId: widget.recommId);
    _fetchReviews();
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
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            ),
          ),
        ),
        const Expanded(
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
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load product details',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(
                      productDetailProvider(widget.product.id)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                                color: AppColors.tertiaryDarker,
                              ),
                            ),
                            if (detail.brand.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                detail.brand,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (detail.subText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                detail.subText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildQuantityControls(),
                    ],
                  ),
                ),

                // Stock badge
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _buildStockBadge(detail),
                ),

                // Total Price
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '₫${(detail.price * quantity).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
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
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: _buildColorChips(detail.colors),
                  ),

                // Key Features
                if (detail.keyFeatures.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: _buildKeyFeatures(detail.keyFeatures),
                  ),

                // Add to Cart + Wishlist row
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _buildActionRow(detail),
                ),

                // Description section
                if (detail.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _buildDescription(detail),
                  ),

                // Divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Divider(height: 1),
                ),

                // Reviews section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: _buildReviewsSection(),
                ),

                const SizedBox(height: 24),
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
          height: 300,
          color: AppColors.backgroundLightAlt,
          child: PageView.builder(
            controller: _imagePageController,
            itemCount: images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: CustomImage(imageUrl: images[index], fit: BoxFit.contain),
              );
            },
          ),
        ),

        // Back button
        Positioned(
          top: 12,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Colors.black),
            ),
          ),
        ),

        // Left arrow
        if (images.length > 1 && _currentImageIndex > 0)
          Positioned(
            left: 8,
            top: 140,
            child: GestureDetector(
              onTap: () {
                _imagePageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.chevron_left, size: 20, color: Colors.grey),
              ),
            ),
          ),

        // Right arrow
        if (images.length > 1 && _currentImageIndex < images.length - 1)
          Positioned(
            right: 8,
            top: 140,
            child: GestureDetector(
              onTap: () {
                _imagePageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right,
                    size: 20, color: Colors.grey),
              ),
            ),
          ),

        // Dot indicators
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final isActive = i == _currentImageIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.tertiaryDarker
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: detail.inStock
                ? AppColors.success.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            detail.inStock
                ? 'In Stock (${detail.stockQuantity})'
                : 'Out of Stock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: detail.inStock ? AppColors.success : Colors.red,
            ),
          ),
        ),
        if (detail.sku.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            'SKU: ${detail.sku}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
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
        const Text(
          'Available Colors',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryDarker,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(colors.length, (index) {
            final color = colors[index];
            final isSelected = _selectedColorIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tertiaryDarker : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.tertiaryDarker : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  color,
                  style: TextStyle(
                    fontSize: 12,
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

    if (features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Features',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryDarker,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map((spec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiaryDarker,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    spec,
                    style: TextStyle(
                      fontSize: 13,
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$quantity',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16, color: Colors.grey.shade700),
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
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.shopping_cart_outlined, size: 20),
            label: Text(
              detail.inStock ? 'Add to Cart' : 'Out of Stock',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 14),
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
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isWished ? Colors.white : AppColors.tertiaryDarker,
                  shape: BoxShape.circle,
                  border: isWished ? Border.all(color: AppColors.border) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? Colors.redAccent : Colors.white,
                  size: 22,
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
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryDarker,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayText,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () =>
                setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Row(
              children: [
                Text(
                  _descriptionExpanded ? 'Show less' : 'Read more',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiaryNormal,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _descriptionExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
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
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
                if (!_isLoadingReviews && _totalReviews > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$_totalReviews',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiaryNormal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoadingReviews)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(),
          )
        else if (_recentReviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "No reviews yet.",
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, height: 1),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < _averageRating ? Icons.star : Icons.star_half,
                        size: 20,
                        color: AppColors.star,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
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

  // ───────── Added to Cart Dialog ─────────

  void _showAddedToCartDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.success, width: 3),
                  ),
                  child: const Center(
                    child: Icon(Icons.check, color: AppColors.success, size: 44),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Added to cart !',
                  style: TextStyle(
                    fontSize: 22,
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
