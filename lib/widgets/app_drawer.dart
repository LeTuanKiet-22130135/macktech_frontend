import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String selectedCategory = 'Phones';

  final List<Map<String, dynamic>> categories = [
    {'name': 'Phones', 'count': '21'},
    {'name': 'Audio', 'count': '06'},
    {'name': 'Cases', 'count': '06'},
    {'name': 'Storage', 'count': '06'},
    {'name': 'Other', 'count': '06'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(
        0xFFF9F9F9,
      ), // Light background to match images
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.grid_view_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    "DASHBOARD",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                  },
                ),
              ),
              const SizedBox(height: 24),

              // All Products
              ListTile(
                leading: const Icon(
                  Icons.inbox_outlined,
                  color: AppColors.textPrimary,
                ),
                title: const Text(
                  "ALL PRODUCTS",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                onTap: () {},
              ),

              // Order List
              ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: AppColors.textPrimary,
                ),
                title: const Text(
                  "ORDER LIST",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // Categories Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Categories",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category Items
              ...categories.map(
                (cat) => _buildCategoryItem(cat['name']!, cat['count']!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, String count) {
    bool isSelected = selectedCategory == name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            count,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () {
          setState(() {
            selectedCategory = name;
          });
        },
      ),
    );
  }
}
