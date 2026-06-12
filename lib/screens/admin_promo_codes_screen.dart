import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'admin_add_promo_code_screen.dart';

class AdminPromoCodesScreen extends StatelessWidget {
  const AdminPromoCodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Discount Codes",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage promotions and product-specific limits.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildPromoCard(
                      code: "SUMMER26",
                      value: "15% OFF",
                      target: "Storewide",
                      timesUsed: 42,
                      usageLimit: 100,
                      isActive: true,
                    ),
                    const SizedBox(height: 12),
                    _buildPromoCard(
                      code: "IPHONE15",
                      value: "₫50.00 OFF",
                      target: "Apply to: iPhone 15 Pro",
                      timesUsed: 12,
                      usageLimit: 50,
                      isActive: true,
                    ),
                    const SizedBox(height: 12),
                    _buildPromoCard(
                      code: "WELCOME10",
                      value: "10% OFF",
                      target: "Storewide",
                      timesUsed: 315,
                      usageLimit: null,
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddPromoCodeScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPromoCard({
    required String code,
    required String value,
    required String target,
    required int timesUsed,
    required int? usageLimit,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16),
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (val) {},
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$value • $target",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            usageLimit != null ? "Used $timesUsed / $usageLimit times" : "Used $timesUsed times (No Limit)",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}


