import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'password_recovery_email_screen.dart';
import 'password_recovery_phone_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';

/// Password Recovery - Method selection screen matching designs 166/167/198/199.
/// Shows avatar, "Password Recovery" heading, SMS/Email radio options,
/// Next button and Cancel link. Wave pattern header.
class PasswordRecoveryMethodsScreen extends StatefulWidget {
  final String? initialEmail;

  const PasswordRecoveryMethodsScreen({super.key, this.initialEmail});

  @override
  State<PasswordRecoveryMethodsScreen> createState() =>
      _PasswordRecoveryMethodsScreenState();
}

class _PasswordRecoveryMethodsScreenState
    extends State<PasswordRecoveryMethodsScreen> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Wave header
          _buildWaveHeader(),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  SizedBox(height: 32.h),

                  // Avatar
                  Container(
                    width: 110.w,
                    height: 110.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 3.w),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/Placeholder_01.png',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.pink.shade100,
                          child: Icon(
                            Icons.person,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Title
                  Text(
                    "Password Recovery",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Subtitle
                  Text(
                    "How you would like to restore\nyour password?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // SMS option
                  _buildMethodOption("SMS"),
                  SizedBox(height: 12.h),

                  // Email option
                  _buildMethodOption("Email"),

                  const Spacer(),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _selectedMethod != null
                          ? () {
                              if (_selectedMethod == "Email") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PasswordRecoveryEmailScreen(
                                      initialEmail: widget.initialEmail ?? '',
                                    ),
                                  ),
                                );
                              } else if (_selectedMethod == "SMS") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PasswordRecoveryPhoneScreen(),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryDarker,
                        disabledBackgroundColor: AppColors.tertiaryDarker
                            .withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveHeader() {
    return SizedBox(
      height: 200.h,
      child: Stack(
        children: [
          // Dark navy background
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 400.w,
              height: 280.h,
              decoration: const BoxDecoration(
                color: AppColors.tertiaryDarker,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(200),
                ),
              ),
            ),
          ),
          // Light blue accent wave
          Positioned(
            top: 40.h,
            left: -30,
            child: Container(
              width: 500.w,
              height: 180.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(200),
                  bottomLeft: Radius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(String method, {bool locked = false}) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: locked ? null : () => setState(() => _selectedMethod = method),
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          width: 280.w,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.tertiaryLight,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  locked ? "$method (Unavailable)" : method,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
              ),
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.tertiaryDarker : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.tertiaryDarker
                        : Colors.grey.shade400,
                    width: 2.w,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
