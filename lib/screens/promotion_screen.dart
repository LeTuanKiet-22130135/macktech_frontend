import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildImagePlaceholder('assets/images/banner.jpg'),
          SizedBox(height: 16.h),
          _buildImagePlaceholder('assets/images/084.png'),
          SizedBox(height: 16.h),
          _buildImagePlaceholder('assets/images/banner.jpg'),
          SizedBox(height: 16.h),
          _buildImagePlaceholder('assets/images/084.png'),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 160.h,
            width: double.infinity,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 40.sp, color: Colors.grey),
                SizedBox(height: 8.h),
                Text(
                  "Image missing: ${imagePath.split('/').last}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
