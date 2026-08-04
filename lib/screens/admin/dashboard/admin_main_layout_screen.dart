import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import '../products/admin_all_products_screen.dart';
import '../orders/admin_order_list_screen.dart';
import '../promotions/admin_promo_codes_screen.dart';
import '../users/admin_users_screen.dart';
import '../promotions/admin_promotions_screen.dart';
import '../../user/auth/login_screen.dart';
import '../../user/profile/change_password_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';
import '../../../providers/locale_provider.dart';

class AdminMainLayoutScreen extends ConsumerStatefulWidget {
  const AdminMainLayoutScreen({super.key});

  @override
  ConsumerState<AdminMainLayoutScreen> createState() => _AdminMainLayoutScreenState();
}

class _AdminMainLayoutScreenState extends ConsumerState<AdminMainLayoutScreen> {
  int _selectedIndex = 0; // 0 for All Products, 1 for Order List

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    return Scaffold(
      backgroundColor: AppColors.background, // light background for body
      appBar: AppBar(
        backgroundColor: AppColors.tertiaryNormal, // Navy blue
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            // Using placeholder for Macktech Mobiles logo if absent
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.rocket_launch, color: Colors.blueAccent), // Fake logo
            ),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context)!.macktechMobiles,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0.w),
            child: PopupMenuButton<int>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              offset: Offset(0, 50),
              color: Colors.white,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: AppColors.textPrimary),
              ),
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                  );
                } else if (value == 2) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  }
                } else if (value == 3) {
                  final next = currentLocale.languageCode == 'vi' ? 'en' : 'vi';
                  ref.read(localeProvider.notifier).setLocale(Locale(next));
                }
              },
              itemBuilder: (context) => [
                // Header
                PopupMenuItem<int>(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0.h, top: 8.0.h),
                    child: Text(AppLocalizations.of(context)!.admin,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                PopupMenuDivider(),
                // Change Password
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.changePassword,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24.w),
                      Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.textPrimary),
                    ],
                  ),
                ),
                // Language
                PopupMenuItem<int>(
                  value: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.language.toUpperCase(),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24.w),
                      Text(
                        currentLocale.languageCode == 'vi' ? 'VI' : 'EN',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                // Log out
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.logOut,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24.w),
                      Icon(Icons.logout, size: 20.sp, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      drawer: _buildAdminDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AdminDashboardScreen(),
          AdminAllProductsScreen(),
          AdminOrderListScreen(),
          AdminPromoCodesScreen(),
          AdminUsersScreen(),
          AdminPromotionsScreen(),
        ],
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDrawerItem(
                icon: Icons.dashboard_outlined,
                title: AppLocalizations.of(context)!.dashboard.toUpperCase(),
                isSelected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context); // Close drawer
                },
              ),
              SizedBox(height: 12.h),
              _buildDrawerItem(
                icon: Icons.inventory_2_outlined,
                title: AppLocalizations.of(context)!.allProducts.toUpperCase(),
                isSelected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context); // Close drawer
                },
              ),
              SizedBox(height: 12.h),
              _buildDrawerItem(
                icon: Icons.receipt_long_outlined,
                title: AppLocalizations.of(context)!.orderList.toUpperCase(),
                isSelected: _selectedIndex == 2,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context); // Close drawer
                },
              ),
              SizedBox(height: 12.h),
              _buildDrawerItem(
                icon: Icons.local_offer_outlined,
                title: AppLocalizations.of(context)!.discountCodes.toUpperCase(),
                isSelected: _selectedIndex == 3,
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context); // Close drawer
                },
              ),
              SizedBox(height: 12.h),
              _buildDrawerItem(
                icon: Icons.people_outline,
                title: AppLocalizations.of(context)!.userManagement.toUpperCase(),
                isSelected: _selectedIndex == 4,
                onTap: () {
                  setState(() => _selectedIndex = 4);
                  Navigator.pop(context); // Close drawer
                },
              ),
              SizedBox(height: 12.h),
              _buildDrawerItem(
                icon: Icons.campaign_outlined,
                title: AppLocalizations.of(context)!.promotions.toUpperCase(),
                isSelected: _selectedIndex == 5,
                onTap: () {
                  setState(() => _selectedIndex = 5);
                  Navigator.pop(context); // Close drawer
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected ? AppColors.tertiaryNormal : Colors.transparent;
    final fgColor = isSelected ? Colors.white : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: fgColor),
        title: Text(
          title,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        onTap: onTap,
      ),
    );
  }


}
