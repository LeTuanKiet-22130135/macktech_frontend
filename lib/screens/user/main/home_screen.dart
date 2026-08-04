import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/product_card.dart';
import '../../../models/product.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/recommendation_provider.dart';
import 'promotion_screen.dart';
import 'search_result_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';
import '../../../widgets/custom_image.dart';
import '../../../providers/promotion_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    // Pass 0-indexed page to backend
    final recommendationsAsync = ref.watch(recommendationsProvider(_currentPage - 1));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  // Invalidate and wait for the new recommendations to be fetched
                  return ref.refresh(recommendationsProvider(_currentPage - 1).future);
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                  padding: EdgeInsets.only(bottom: 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLatestPromotions(context),
                      _buildSuggestedHeader(context),
                      _buildRecommendedProductGrid(recommendationsAsync),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dark header with logo, search bar, and filter row — matching 052
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.tertiaryDarker,
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        children: [
          // Title row with logo
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logohomecscreen.png',
                  height: 28.h,
                  errorBuilder: (c, e, s) => Icon(
                    Icons.phone_android,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(AppLocalizations.of(context)!.macktechMobiles,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Search bar - navigates to search results
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 8.h, bottom: 20.h),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchResultScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Text(AppLocalizations.of(context)!.searchAnyProduct,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestPromotions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.latestPromotions,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          // Promo Carousel
          const _PromoCarousel(),
          SizedBox(height: 12.h),
          // View all promotions button
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PromotionScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.black),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.viewAllPromotions, style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward, size: 16.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildSuggestedHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalizations.of(context)!.suggestedForYou,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchResultScreen()),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(AppLocalizations.of(context)!.viewAll,
              style: TextStyle(
                color: AppColors.tertiaryNormal,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays recommended products from the API with server-side pagination.
  Widget _buildRecommendedProductGrid(AsyncValue<({String? recommId, List<Product> products, int totalPages, int totalElements})> asyncData) {
    return asyncData.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 40.sp),
              SizedBox(height: 12.h),
              Text(AppLocalizations.of(context)!.failedToLoadRecommendations,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
              SizedBox(height: 12.h),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(recommendationsProvider(_currentPage - 1)),
                icon: Icon(Icons.refresh, size: 18.sp),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      ),
      data: (data) {
        final products = data.products;
        final recommId = data.recommId;
        final totalPages = data.totalPages;
        
        if (products.isEmpty && _currentPage > 1) {
          // Went past the last page — snap back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _currentPage--);
          });
          return const SizedBox.shrink();
        }
        
        if (products.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(AppLocalizations.of(context)!.noRecommendationsAvailable,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          );
        }



        return Column(
          children: [
            // Product grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: products[index], recommId: recommId);
                },
              ),
            ),
            SizedBox(height: 24.h),
            // Pagination controls
            if (totalPages > 1) _buildPagination(totalPages),
          ],
        );
      },
    );
  }

  Widget _buildPagination(int totalPages) {
    // Sliding window of max 5 pages
    int startPage = math.max(1, _currentPage - 2);
    int endPage = math.min(totalPages, _currentPage + 2);

    if (endPage - startPage + 1 < 5) {
      if (startPage == 1) {
        endPage = math.min(totalPages, 5);
      } else if (endPage == totalPages) {
        startPage = math.max(1, totalPages - 4);
      }
    }

    final pages = List.generate(endPage - startPage + 1, (i) => startPage + i);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _currentPage > 1
                  ? () => setState(() => _currentPage--)
                  : null,
              child: Text(AppLocalizations.of(context)!.back,
                style: TextStyle(
                  color: _currentPage > 1
                      ? AppColors.textPrimary
                      : Colors.grey.shade400,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ...pages.map((page) {
              final isActive = page == _currentPage;
              return GestureDetector(
                onTap: () => setState(() => _currentPage = page),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$page",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }),
            TextButton(
              onPressed: _currentPage < totalPages
                  ? () => setState(() => _currentPage++)
                  : null,
              child: Text(AppLocalizations.of(context)!.next,
                style: TextStyle(
                  color: _currentPage < totalPages
                      ? AppColors.tertiaryNormal
                      : Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoCarousel extends ConsumerStatefulWidget {
  const _PromoCarousel();

  @override
  ConsumerState<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends ConsumerState<_PromoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(promotionBannersProvider);

    return bannersAsync.when(
      loading: () => AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.r),
          ),
          alignment: Alignment.center,
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, _) => AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.r),
          ),
          alignment: Alignment.center,
          child: Text("No promotions available", style: TextStyle(color: Colors.grey)),
        ),
      ),
      data: (banners) {
        if (banners.isEmpty) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.center,
              child: Text("No active promotions", style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final imageUrl = banners[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PromotionScreen()),
                        );
                      },
                      child: CustomImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
