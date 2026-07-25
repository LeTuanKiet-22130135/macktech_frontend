import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_frontend/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

import 'delete_account_screen.dart';
import 'security_privacy_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)?.settings ?? "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
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
                  Text(AppLocalizations.of(context)!.yourAccountIsProtected,
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(AppLocalizations.of(context)!.macktechMobileAppProtectsYourP,
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
                      Expanded(child: _buildGreenItem(Icons.account_circle_outlined, AppLocalizations.of(context)!.accountSecurity)),
                      Expanded(child: _buildGreenItem(Icons.lock_outline, AppLocalizations.of(context)!.privacy)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: _buildGreenItem(Icons.key, AppLocalizations.of(context)!.permissions)),
                      Expanded(child: _buildGreenItem(Icons.check_circle_outline, AppLocalizations.of(context)!.safetyCenter)),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // List Items matching 027.png
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  _buildListTile(AppLocalizations.of(context)!.deleteAccount, subtitle: AppLocalizations.of(context)!.youHaveAnOngoingOrder, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DeleteAccountScreen()));
                  }),
                  _buildDivider(),
                  _buildListTile(AppLocalizations.of(context)!.securityAndPrivacy, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SecurityPrivacyScreen()));
                  }),
                  _buildDivider(),
                  _buildLanguageListTile(context, ref),
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
    return Divider(height: 1, thickness: 1, color: AppColors.border);
  }

  Widget _buildLanguageListTile(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final loc = AppLocalizations.of(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      title: Text(
        loc?.language ?? "Language",
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      trailing: DropdownButton<String>(
        value: currentLocale.languageCode,
        underline: SizedBox(),
        items: [
          DropdownMenuItem(value: 'vi', child: Text(loc?.vietnamese ?? "Vietnamese")),
          DropdownMenuItem(value: 'en', child: Text(loc?.english ?? "English")),
        ],
        onChanged: (val) {
          if (val != null) {
            ref.read(localeProvider.notifier).setLocale(Locale(val));
          }
        },
      ),
    );
  }
}
