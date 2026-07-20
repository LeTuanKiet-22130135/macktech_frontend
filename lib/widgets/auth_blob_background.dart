import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:app_frontend/theme/app_colors.dart';

/// Shared blob background painter matching the organic shapes
/// from mockup designs 001/002/159/160.
/// Used by both LoginScreen and CreateAccountScreen.
class AuthBlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Large light-blue blob, top-left ──
    final lightBluePaint = Paint()
      ..color = AppColors.tertiaryLight
      ..style = PaintingStyle.fill;

    final lightBlobPath = Path();
    lightBlobPath.moveTo(-w * 0.05, 0);
    lightBlobPath.lineTo(w * 0.65, 0);
    lightBlobPath.cubicTo(
      w * 0.72, h * 0.05,
      w * 0.60, h * 0.32,
      w * 0.38, h * 0.40,
    );
    lightBlobPath.cubicTo(
      w * 0.15, h * 0.48,
      -w * 0.05, h * 0.38,
      -w * 0.05, h * 0.22,
    );
    lightBlobPath.close();
    canvas.drawPath(lightBlobPath, lightBluePaint);

    // ── Large dark-blue blob, top-left ──
    final darkBluePaint = Paint()
      ..color = AppColors.tertiaryNormal
      ..style = PaintingStyle.fill;

    final darkBlobPath = Path();
    darkBlobPath.moveTo(0, 0);
    darkBlobPath.lineTo(w * 0.55, 0);
    darkBlobPath.cubicTo(
      w * 0.58, h * 0.08,
      w * 0.42, h * 0.30,
      w * 0.22, h * 0.35,
    );
    darkBlobPath.cubicTo(
      w * 0.02, h * 0.40,
      -w * 0.08, h * 0.28,
      0, h * 0.15,
    );
    darkBlobPath.close();
    canvas.drawPath(darkBlobPath, darkBluePaint);

    // ── Small dark-blue blob, mid-right ──
    final smallBlobPaint = Paint()
      ..color = AppColors.tertiaryNormal
      ..style = PaintingStyle.fill;

    final smallBlobPath = Path();
    smallBlobPath.moveTo(w + 10, h * 0.30);
    smallBlobPath.cubicTo(
      w * 0.90, h * 0.32,
      w * 0.85, h * 0.38,
      w * 0.88, h * 0.43,
    );
    smallBlobPath.cubicTo(
      w * 0.92, h * 0.48,
      w + 10, h * 0.46,
      w + 10, h * 0.42,
    );
    smallBlobPath.close();
    canvas.drawPath(smallBlobPath, smallBlobPaint);

    // ── Large light circle, bottom-right ──
    final bottomCirclePaint = Paint()
      ..color = AppColors.tertiaryLight
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(w * 0.80, h * 0.92),
      w * 0.50,
      bottomCirclePaint,
    );

    // ── Subtle vertical streak behind the form area ──
    final streakPaint = Paint()
      ..color = AppColors.backgroundHover
      ..style = PaintingStyle.fill;

    final streakPath = Path();
    streakPath.moveTo(w * 0.45, h * 0.52);
    streakPath.cubicTo(
      w * 0.48, h * 0.60,
      w * 0.40, h * 0.80,
      w * 0.42, h * 0.95,
    );
    streakPath.lineTo(w * 0.52, h * 0.95);
    streakPath.cubicTo(
      w * 0.50, h * 0.78,
      w * 0.56, h * 0.58,
      w * 0.53, h * 0.52,
    );
    streakPath.close();
    canvas.drawPath(streakPath, streakPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Builds a pill-shaped text field matching the mockup style:
/// light grey fill, thin dark rounded border, generous padding.
Widget buildAuthPillField({
  required String hintText,
  bool obscure = false,
  TextInputType keyboardType = TextInputType.text,
  Widget? suffixIcon,
  TextEditingController? controller,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: TextStyle(fontSize: 16.sp, color: AppColors.primary),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 16.sp,
      ),
      filled: true,
      fillColor: AppColors.backgroundLightAlt,
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40.r),
        borderSide: BorderSide(color: AppColors.textSecondary, width: 1.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40.r),
        borderSide: BorderSide(color: AppColors.textSecondary, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40.r),
        borderSide: BorderSide(color: AppColors.tertiaryNormal, width: 1.5.w),
      ),
    ),
  );
}
