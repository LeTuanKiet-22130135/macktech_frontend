import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:app_frontend/theme/app_colors.dart';

/// About screen matching designs 060 and 102.
/// Shows the Macktech Mobiles dark circle logo, "About Shoppe" heading,
/// descriptive text, and a contact note.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "User Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // Dark circle logo (img 102)
            Center(
              child: Container(
                width: 180.w,
                height: 180.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/about_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: AppColors.primary,
                      child: Center(
                        child: Icon(
                          Icons.phone_android,
                          color: Colors.blue,
                          size: 60.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 36.h),

            // "About Shoppe" heading
            Text(
              "About Shoppe",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiaryDarker,
              ),
            ),
            SizedBox(height: 20.h),

            // Description paragraph
            Text(
              'Shoppe - Shopping UI kit" is likely a user interface (UI) kit designed to facilitate the development of e-commerce or shopping-related applications. UI kits are collections of pre-designed elements, components, and templates that developers and designers can use to create consistent and visually appealing user interfaces.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),
            SizedBox(height: 28.h),

            // Contact note
            Text(
              "If you need help or you have any questions, feel free to contact me by email.",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),

            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }
}
