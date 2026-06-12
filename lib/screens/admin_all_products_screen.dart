import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'admin_add_product_screen.dart';
import 'admin_edit_product_screen.dart';

class AdminAllProductsScreen extends StatelessWidget {
  const AdminAllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top action bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminAddProductScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add new product", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.overlayDark, // Dark navy blue matching 022 button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),

        // Product Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Adjust to fit image and text comfortably
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4, // Mocking 4 items as seen in 022
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminEditProductScreen()),
                  );
                },
                child: _buildAdminProductCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminProductCard(int index) {
    // Mock data matching mockup 022
    final mockProducts = [
      {'name': 'Apple iPhone 16 Pro Max 256GB', 'brand': 'Apple', 'price': '₫389,900.00'},
      {'name': 'OnePlus Nord N20SE 4GB RAM 64GB', 'brand': 'OnePlus', 'price': '₫54,900.00'},
      {'name': 'Samsung Galaxy A26 8GB RAM 256GB', 'brand': 'Samsung', 'price': '₫119,990.00'},
      {'name': 'Apple iPhone 11 128GB', 'brand': 'Apple', 'price': '₫134,900.00'},
    ];

    final product = mockProducts[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder matching mockup card top
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Light grey background like mockup
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.phone_iphone, size: 50, color: Colors.grey.shade400),
              ),
            ),
          ),
          // Product details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product['brand']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['price']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
