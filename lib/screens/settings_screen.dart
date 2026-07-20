import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

import 'delete_account_screen.dart';
import 'security_privacy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your account is protected",
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Macktech mobile app protects your personal information and keeps it private , safe and secure .",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  // 2x2 Grid for the green features
                  Row(
                    children: [
                      Expanded(child: _buildGreenItem(Icons.account_circle_outlined, "Account security")),
                      Expanded(child: _buildGreenItem(Icons.lock_outline, "Privacy")),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: _buildGreenItem(Icons.key, "Permissions")),
                      Expanded(child: _buildGreenItem(Icons.check_circle_outline, "Safety center")),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // List Items matching 027.png
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  _buildListTile("Delete Account", subtitle: "Bạn đang có một đơn hàng", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
                  }),
                  _buildDivider(),
                  _buildListTile("Security and Privacy", onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPrivacyScreen()));
                  }),
                  _buildDivider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreenItem(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.success, size: 28.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.success,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: EdgeInsets.only(top: 4.0.h),
              child: Text(
                subtitle,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
              ),
            )
          : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
