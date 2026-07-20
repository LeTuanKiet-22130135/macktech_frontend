import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/images/success.png', height: 250.h, errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.check_circle, color: AppColors.success, size: 150.sp);
              }),
              SizedBox(height: 40.h),
              Text("Success!", style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              SizedBox(height: 16.h),
              Text(
                "Your order will be delivered soon.\nThank you for choosing our app!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary, height: 1.5),
              ),
              const Spacer(),
              CustomButton(text: "CONTINUE SHOPPING", onPressed: () => Navigator.pop(context)),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
