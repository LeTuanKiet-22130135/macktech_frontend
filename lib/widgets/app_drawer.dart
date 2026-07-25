import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String selectedCategory = 'Phones';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Phones', 'count': '21'},
    {'name': 'Audio', 'count': '06'},
    {'name': 'Cases', 'count': '06'},
    {'name': 'Storage', 'count': '06'},
    {'name': 'Other', 'count': '06'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(
        0xFFF9F9F9,
      ), // Light background to match images
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 32.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.grid_view_outlined,
                    color: Colors.white,
                  ),
                  title: Text(AppLocalizations.of(context)!.dashboard,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                  },
                ),
              ),
              SizedBox(height: 24.h),

              // All Products
              ListTile(
                leading: Icon(
                  Icons.inbox_outlined,
                  color: AppColors.textPrimary,
                ),
                title: Text(AppLocalizations.of(context)!.allProducts,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w),
                onTap: () {},
              ),

              // Order List
              ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: AppColors.textPrimary,
                ),
                title: Text(AppLocalizations.of(context)!.orderList,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w),
                onTap: () {},
              ),

              SizedBox(height: 32.h),

              // Categories Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.categories,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Category Items
              ...categories.map(
                (cat) => _buildCategoryItem(cat['name']!, cat['count']!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, String count) {
    bool isSelected = selectedCategory == name;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            count,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w),
        onTap: () {
          setState(() {
            selectedCategory = name;
          });
        },
      ),
    );
  }
}
