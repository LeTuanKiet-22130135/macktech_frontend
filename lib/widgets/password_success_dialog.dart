import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';
import '../screens/user/auth/login_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

void showPasswordSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      );
    },
  );
}

Widget _buildDialogContent(BuildContext context) {
  return Stack(
    alignment: Alignment.topCenter,
    clipBehavior: Clip.none,
    children: [
      Container(
        margin: EdgeInsets.only(top: 40.h),
        padding: EdgeInsets.only(top: 60.h, bottom: 24.h, left: 24.w, right: 24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Password Changed\nSuccessfully !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: AppLocalizations.of(context)!.ok,
              onPressed: () {
                // Navigate back to login screen on success
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      Positioned(
        top: 0.h,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 40.sp,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
