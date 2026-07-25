import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'admin_add_product_screen.dart';
import 'admin_edit_product_screen.dart';
import '../../../models/product.dart';
import '../../../services/product_service.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AdminAllProductsScreen extends StatefulWidget {
  const AdminAllProductsScreen({super.key});

  @override
  State<AdminAllProductsScreen> createState() => _AdminAllProductsScreenState();
}

class _AdminAllProductsScreenState extends State<AdminAllProductsScreen> {
  bool _isLoading = true;
  List<Product> _products = [];
  String? _error;
  
  int _currentPage = 0;
  int _totalPages = 0;
  final int _pageSize = 20;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Product> fetchedProducts;
      int fetchedTotalPages;
      
      if (_searchQuery.isNotEmpty) {
        final result = await ProductService.searchProducts(query: _searchQuery, page: _currentPage, size: _pageSize);
        fetchedProducts = result.products;
        fetchedTotalPages = result.totalPages;
      } else {
        final result = await ProductService.fetchAllProducts(page: _currentPage, size: _pageSize);
        fetchedProducts = result.products;
        fetchedTotalPages = result.totalPages;
      }
          
      setState(() {
        _products = fetchedProducts;
        _totalPages = fetchedTotalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load products: $e";
        _isLoading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top action bar
        Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminAddProductScreen()),
                    );
                    if (result == true) {
                      _fetchProducts();
                    }
                  },
                  icon: Icon(Icons.add, size: 18.sp),
                  label: Text(AppLocalizations.of(context)!.addNewProduct, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.overlayDark, // Dark navy blue matching 022 button
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchProducts,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _currentPage = 0;
                            });
                            _fetchProducts();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Color(0xFFF5F6F8),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                    _currentPage = 0; // Reset to first page on new search
                  });
                  _fetchProducts();
                },
              ),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                  : _products.isEmpty
                      ? Center(child: Text(AppLocalizations.of(context)!.noProductsFound))
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65, // Adjust to fit image and text comfortably
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return InkWell(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AdminEditProductScreen(product: product)),
                                );
                                if (result == true) {
                                  _fetchProducts();
                                }
                              },
                              child: _buildAdminProductCard(product),
                            );
                          },
                        ),
        ),
        
        // Pagination Controls
        if (_totalPages > 1)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0.h),
            child: _buildPaginationControls(),
          ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    int startPage = max(0, min(_currentPage - 2, _totalPages - 5));
    int endPage = min(_totalPages - 1, startPage + 4);
    
    // Adjust start page if we hit the end
    if (endPage - startPage < 4 && _totalPages >= 5) {
      startPage = max(0, endPage - 4);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
          color: _currentPage > 0 ? AppColors.textPrimary : Colors.grey.shade300,
        ),
        for (int i = startPage; i <= endPage; i++)
          GestureDetector(
            onTap: () => _goToPage(i),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: _currentPage == i ? AppColors.overlayDark : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _currentPage == i ? AppColors.overlayDark : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: _currentPage == i ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: _currentPage < _totalPages - 1 ? () => _goToPage(_currentPage + 1) : null,
          color: _currentPage < _totalPages - 1 ? AppColors.textPrimary : Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildAdminProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder matching mockup card top
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Light grey background like mockup
                borderRadius: BorderRadius.circular(12.r),
                image: product.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imageUrl.isEmpty
                  ? Center(
                      child: Icon(Icons.phone_iphone, size: 50.sp, color: Colors.grey.shade400),
                    )
                  : null,
            ),
          ),
          // Product details
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 8.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  product.brand,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '₫${product.price.toStringAsFixed(0)}', // Format price
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
