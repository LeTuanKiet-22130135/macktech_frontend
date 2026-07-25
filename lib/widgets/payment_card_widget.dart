import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../models/payment_card.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class PaymentCardWidget extends StatelessWidget {
  final PaymentCard card;

  const PaymentCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.brand == 'visa' 
              ? [AppColors.tertiaryDark, AppColors.primary] 
              : [AppColors.primary, AppColors.textSecondary],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.credit_card, color: Colors.white, size: 30.sp),
              Text(card.brand.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
          SizedBox(height: 30.h),
          Text(
            card.cardNumber,
            style: TextStyle(color: Colors.white, fontSize: 22.sp, letterSpacing: 2),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.cardHolder, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                  Text(card.cardHolder.toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.expires, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                  Text(card.expiryDate, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
