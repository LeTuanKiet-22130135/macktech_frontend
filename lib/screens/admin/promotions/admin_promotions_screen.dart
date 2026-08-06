import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/promotion.dart';
import '../../../services/promotion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_image.dart';
import 'admin_edit_promotion_screen.dart';

class AdminPromotionsScreen extends StatefulWidget {
  const AdminPromotionsScreen({super.key});

  @override
  State<AdminPromotionsScreen> createState() => _AdminPromotionsScreenState();
}

class _AdminPromotionsScreenState extends State<AdminPromotionsScreen> {
  bool _isLoading = true;
  List<Promotion> _promotions = [];

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() => _isLoading = true);
    try {
      final promotions = await PromotionService.fetchAdminPromotions();
      if (mounted) {
        setState(() {
          _promotions = promotions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load promotions')),
        );
      }
    }
  }

  Future<void> _deletePromotion(Promotion promo) async {
    if (promo.id == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Promotion'),
        content: Text('Are you sure you want to delete "${promo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await PromotionService.deletePromotion(promo.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promotion deleted successfully')),
        );
        _fetchPromotions();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete promotion')),
        );
      }
    }
  }

  void _navigateToEdit([Promotion? promo]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditPromotionScreen(promotion: promo),
      ),
    );
    if (result == true) {
      _fetchPromotions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _promotions.isEmpty
              ? Center(child: Text("No promotions found.", style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _promotions.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final promo = _promotions[index];
                    return _buildPromotionItem(promo);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToEdit(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPromotionItem(Promotion promo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Banner Image
          SizedBox(
            height: 120.h,
            width: double.infinity,
            child: CustomImage(
              imageUrl: promo.bannerImageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        promo.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: promo.isActive ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        promo.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: promo.isActive ? AppColors.success : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  "Dates: ${_formatDate(promo.startDate)} - ${_formatDate(promo.endDate)}",
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                ),
                if (promo.products.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    "Products: ${promo.products.length}",
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                  ),
                ],
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _navigateToEdit(promo),
                      icon: Icon(Icons.edit, size: 16.sp),
                      label: Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      onPressed: () => _deletePromotion(promo),
                      icon: Icon(Icons.delete, size: 16.sp),
                      label: Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
