import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_all_products_screen.dart';
import 'admin_order_list_screen.dart';
import 'admin_promo_codes_screen.dart';
import 'admin_users_screen.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

class AdminMainLayoutScreen extends ConsumerStatefulWidget {
  const AdminMainLayoutScreen({super.key});

  @override
  ConsumerState<AdminMainLayoutScreen> createState() => _AdminMainLayoutScreenState();
}

class _AdminMainLayoutScreenState extends ConsumerState<AdminMainLayoutScreen> {
  int _selectedIndex = 0; // 0 for All Products, 1 for Order List
  bool _categoriesExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // light background for body
      appBar: AppBar(
        backgroundColor: AppColors.tertiaryNormal, // Navy blue
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            // Using placeholder for Macktech Mobiles logo if absent
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rocket_launch, color: Colors.blueAccent), // Fake logo
            ),
            const SizedBox(width: 8),
            const Text(
              "Macktech Mobiles",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<int>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              offset: const Offset(0, 50),
              color: Colors.white,
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: AppColors.textPrimary),
              ),
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                } else if (value == 2) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                // Header
                PopupMenuItem<int>(
                  enabled: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Text(
                      "Admin",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                // Change Password
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "CHANGE PASSWORD",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24),
                      Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textPrimary),
                    ],
                  ),
                ),
                // Log out
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "LOG OUT",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24),
                      Icon(Icons.logout, size: 20, color: AppColors.textPrimary),
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
        ],
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDrawerItem(
                icon: Icons.dashboard_outlined,
                title: "DASHBOARD",
                isSelected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context); // Close drawer
                },
              ),
              const SizedBox(height: 12),
              _buildDrawerItem(
                icon: Icons.inventory_2_outlined,
                title: "ALL PRODUCTS",
                isSelected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context); // Close drawer
                },
              ),
              const SizedBox(height: 12),
              _buildDrawerItem(
                icon: Icons.receipt_long_outlined,
                title: "ORDER LIST",
                isSelected: _selectedIndex == 2,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context); // Close drawer
                },
              ),
              const SizedBox(height: 12),
              _buildDrawerItem(
                icon: Icons.local_offer_outlined,
                title: "DISCOUNT CODES",
                isSelected: _selectedIndex == 3,
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context); // Close drawer
                },
              ),
              const SizedBox(height: 12),
              _buildDrawerItem(
                icon: Icons.people_outline,
                title: "USER MANAGEMENT",
                isSelected: _selectedIndex == 4,
                onTap: () {
                  setState(() => _selectedIndex = 4);
                  Navigator.pop(context); // Close drawer
                },
              ),
              const SizedBox(height: 32),
              
              // Categories Section
              InkWell(
                onTap: () {
                  setState(() {
                    _categoriesExpanded = !_categoriesExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Icon(
                        _categoriesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_categoriesExpanded) ...[
                _buildCategoryItem("Phones", "21", isSelected: false),
                _buildCategoryItem("Audio", "06", isSelected: true), // Matches img 015 Audio active state styling
                _buildCategoryItem("Cases", "06", isSelected: false),
                _buildCategoryItem("Storage", "06", isSelected: false),
                _buildCategoryItem("Other", "06", isSelected: false),
              ]
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: fgColor),
        title: Text(
          title,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCategoryItem(String title, String count, {required bool isSelected}) {
    final bgColor = isSelected ? AppColors.tertiaryDarkHover : AppColors.borderGrey;
    final fgColor = isSelected ? Colors.white : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
