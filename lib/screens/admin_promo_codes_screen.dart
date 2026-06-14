import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/promo_code.dart';
import '../services/promo_code_service.dart';
import 'admin_add_promo_code_screen.dart';
import 'admin_edit_promo_code_screen.dart';

class AdminPromoCodesScreen extends StatefulWidget {
  const AdminPromoCodesScreen({super.key});

  @override
  State<AdminPromoCodesScreen> createState() => _AdminPromoCodesScreenState();
}

class _AdminPromoCodesScreenState extends State<AdminPromoCodesScreen> {
  bool _isLoading = true;
  List<PromoCode> _promoCodes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPromoCodes();
  }

  Future<void> _fetchPromoCodes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final codes = await PromoCodeService.getAllPromoCodes();
      setState(() {
        _promoCodes = codes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load promo codes: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStatus(PromoCode promo) async {
    try {
      // Just toggle isActive, send whole object
      final data = promo.toJson();
      data['isActive'] = !promo.isActive;
      
      await PromoCodeService.updatePromoCode(promo.id, data);
      await _fetchPromoCodes(); // Refresh
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                        : _promoCodes.isEmpty
                            ? const Center(child: Text("No promo codes found."))
                            : ListView.builder(
                                itemCount: _promoCodes.length,
                                itemBuilder: (context, index) {
                                  final promo = _promoCodes[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AdminEditPromoCodeScreen(promoCode: promo),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchPromoCodes();
                                        }
                                      },
                                      child: _buildPromoCard(promo),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAddPromoCodeScreen()),
          );
          if (result == true) {
            _fetchPromoCodes();
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPromoCard(PromoCode promo) {
    String valueText = promo.discountType == 'percentage' 
        ? "${promo.discountValue.toStringAsFixed(0)}% OFF" 
        : "₫${promo.discountValue.toStringAsFixed(0)} OFF";
        
    String target = promo.minimumOrderValue > 0 
        ? "Min order ₫${promo.minimumOrderValue.toStringAsFixed(0)}" 
        : "Storewide";

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
                  promo.code,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16),
                ),
              ),
              Switch(
                value: promo.isActive,
                onChanged: (val) {
                  _toggleStatus(promo);
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$valueText • $target",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            promo.usageLimit != null 
                ? "Used ${promo.usedCount} / ${promo.usageLimit} times" 
                : "Used ${promo.usedCount} times (No Limit)",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          if (promo.validUntil != null) ...[
            const SizedBox(height: 4),
            Text(
              "Expires: ${promo.validUntil!.toLocal().toString().split(' ')[0]}",
              style: TextStyle(color: Colors.red.shade400, fontSize: 12),
            ),
          ]
        ],
      ),
    );
  }
}
