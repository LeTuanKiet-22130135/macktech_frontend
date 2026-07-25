import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

/// Welcome/splash screen matching design 140.
/// Uses a dark textured background (full-104) with the Macktech logo
/// centered, a "Let's get started" button, and an
/// "I already have an account" link.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _navyBlue = AppColors.tertiaryNormal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen dark background (img 104)
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
          ),

          // Slight dark overlay for depth
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0.w),
              child: Column(
                children: [
                  Spacer(flex: 3),

                  // Logo image (logohomecscreen.png)
                  Image.asset(
                    'assets/images/logohomecscreen.png',
                    width: 280.w,
                    fit: BoxFit.contain,
                  ),

                  Spacer(flex: 4),

                  // "Let's get started" button
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OnboardingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navyBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "Let's get started",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // "I already have an account" row
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.iAlreadyHaveAnAccount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: _navyBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
