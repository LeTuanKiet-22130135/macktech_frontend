import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/product_card.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/search_products_provider.dart';
import 'filter_screen.dart';
import '../../../services/category_service.dart';
import '../../../models/category.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

/// Search results screen with active search bar, sort & filter controls,
/// and a product grid showing matching results.
class SearchResultScreen extends ConsumerStatefulWidget {
  const SearchResultScreen({super.key});

  @override
  ConsumerState<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _searchQuery = '';
  String _sortBy = 'relevance';
  
  int _currentPage = 1;

  // Filter state
  String? _filterBrand;
  int? _filterCategoryId;
  double? _filterMinPrice;
  double? _filterMaxPrice;

  // Cached filter metadata from last successful API response
  List<String> _availableBrands = [];
  List<Category> _availableCategories = [];
  double _apiMinPrice = 0;
  double _apiMaxPrice = 0;

  bool get _hasActiveFilter =>
      _filterBrand != null ||
      _filterCategoryId != null ||
      _filterMinPrice != null ||
      _filterMaxPrice != null;

  @override
  void initState() {
    super.initState();
    // Auto-focus the search bar when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService.getAllCategories();
    if (mounted) {
      setState(() {
        _availableCategories = cats;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.sortBy,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSortOption(AppLocalizations.of(context)!.relevance, "relevance"),
                _buildSortOption(AppLocalizations.of(context)!.priceLowToHigh, "price_low"),
                _buildSortOption(AppLocalizations.of(context)!.priceHighToLow, "price_high"),
                _buildSortOption(AppLocalizations.of(context)!.nameAToZ, "name_az"),
                _buildSortOption(AppLocalizations.of(context)!.nameZToA, "name_za"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.tertiaryNormal : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.tertiaryNormal, size: 20.sp)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
          _currentPage = 1;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = SearchQuery(
      query: _searchQuery,
      sortBy: _sortBy,
      page: _currentPage - 1,
      brand: _filterBrand,
      categoryId: _filterCategoryId,
      minPrice: _filterMinPrice,
      maxPrice: _filterMaxPrice,
    );
    final productsAsyncValue = ref.watch(searchProductsProvider(queryParams));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            _buildSearchHeader(),

            // Sort & Filter bar
            _buildSortFilterBar(),

            // Async product grid handling
            Expanded(
              child: productsAsyncValue.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.redAccent, size: 40.sp),
                      SizedBox(height: 12.h),
                      Text(AppLocalizations.of(context)!.failedToLoadProducts),
                      TextButton(
                        onPressed: () => ref.invalidate(searchProductsProvider(queryParams)),
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
                data: (data) {
                  final products = data.products;
                  final totalPages = data.totalPages;
                  final totalElements = data.totalElements;

                  // Cache filter metadata from the latest response
                  _availableBrands = data.availableBrands;
                  _apiMinPrice = data.minPrice;
                  _apiMaxPrice = data.maxPrice;

                  // If we went past the last page, snap back
                  if (products.isEmpty && _currentPage > 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _currentPage--);
                    });
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      // Results count
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _searchQuery.isEmpty
                                ? "$totalElements ${AppLocalizations.of(context)!.productsText}"
                                : "$totalElements ${AppLocalizations.of(context)!.resultsFor} \"$_searchQuery\"",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
          
                      // Product grid
                      Expanded(
                        child: products.isEmpty
                            ? _buildEmptyState()
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(16.w),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.62,
                                      ),
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        return ProductCard(product: products[index]);
                                      },
                                    ),
                                    SizedBox(height: 24.h),
                                    // Pagination controls
                                    if (totalPages > 1) _buildPagination(totalPages),
                                    SizedBox(height: 24.h),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: AppColors.tertiaryDarker,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                    _currentPage = 1;
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchAnyProduct,
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _currentPage = 1;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showSortBottomSheet,
            child: _buildChip(AppLocalizations.of(context)!.sort, Icons.swap_vert),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push<FilterResult>(
                context,
                MaterialPageRoute(
                  builder: (_) => FilterScreen(
                    availableBrands: _availableBrands,
                    availableCategories: _availableCategories,
                    minPrice: _apiMinPrice,
                    maxPrice: _apiMaxPrice,
                    initialBrands: _filterBrand != null ? {_filterBrand!} : null,
                    initialCategoryId: _filterCategoryId,
                    initialMinPrice: _filterMinPrice,
                    initialMaxPrice: _filterMaxPrice,
                  ),
                ),
              );

              // result == null means user pressed Cancel/Reset — clear filters
              if (result == null) {
                setState(() {
                  _filterBrand = null;
                  _filterCategoryId = null;
                  _filterMinPrice = null;
                  _filterMaxPrice = null;
                  _currentPage = 1;
                });
              } else {
                setState(() {
                  _filterBrand = result.selectedBrands.isNotEmpty
                      ? result.selectedBrands.first
                      : null;
                  _filterCategoryId = result.selectedCategoryId;
                  _filterMinPrice = result.minPrice;
                  _filterMaxPrice = result.maxPrice;
                  _currentPage = 1;
                });
              }
            },
            child: _buildChip(
              _hasActiveFilter ? "${AppLocalizations.of(context)!.filter} ✓" : AppLocalizations.of(context)!.filter,
              Icons.filter_list,
              isActive: _hasActiveFilter,
            ),
          ),
          Spacer(),
          if (_sortBy != 'relevance' || _hasActiveFilter)
            GestureDetector(
              onTap: () => setState(() {
                _sortBy = 'relevance';
                _filterBrand = null;
                _filterCategoryId = null;
                _filterMinPrice = null;
                _filterMaxPrice = null;
                _currentPage = 1;
              }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 14.sp, color: AppColors.tertiaryDark),
                    SizedBox(width: 4.w),
                    Text(AppLocalizations.of(context)!.clearAll,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.tertiaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {bool isActive = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive ? AppColors.tertiaryLight.withValues(alpha: 0.3) : AppColors.backgroundLightAlt,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isActive ? AppColors.tertiaryNormal : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: isActive ? AppColors.tertiaryDark : AppColors.textPrimary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.tertiaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(AppLocalizations.of(context)!.noProductsFound,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(AppLocalizations.of(context)!.tryADifferentSearchTerm,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
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
