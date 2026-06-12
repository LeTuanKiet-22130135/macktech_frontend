import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../screens/login_screen.dart';

void showPasswordSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Password Changed\nSuccessfully !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: "OK",
              onPressed: () {
                // Navigate back to login screen on success
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      Positioned(
        top: 0,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
