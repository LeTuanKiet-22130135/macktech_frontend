import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/promo_code.dart';
import '../../../services/promo_code_service.dart';
import 'admin_add_promo_code_screen.dart';
import 'admin_edit_promo_code_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';
import 'package:app_frontend/utils/num_extension.dart';

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
      backgroundColor: Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.discountCodes,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 8.h),
              Text(AppLocalizations.of(context)!.managePromotionsAndProductspec,
                style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
                        : _promoCodes.isEmpty
                            ? Center(child: Text(AppLocalizations.of(context)!.noPromoCodesFound))
                            : ListView.builder(
                                itemCount: _promoCodes.length,
                                itemBuilder: (context, index) {
                                  final promo = _promoCodes[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.0.h),
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
        heroTag: null,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminAddPromoCodeScreen()),
          );
          if (result == true) {
            _fetchPromoCodes();
          }
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(AppLocalizations.of(context)!.newCode, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPromoCard(PromoCode promo) {
    String valueText = promo.discountType == 'percentage' 
        ? "${promo.discountValue.toPrice()}% OFF" 
        : "₫${promo.discountValue.toPrice()} OFF";
        
    String target = promo.minimumOrderValue > 0 
        ? "Min order ₫${promo.minimumOrderValue.toPrice()}" 
        : "Storewide";

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryLight,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  promo.code,
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16.sp),
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
          SizedBox(height: 12.h),
          Text(
            "$valueText • $target",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            promo.usageLimit != null 
                ? "Used ${promo.usedCount} / ${promo.usageLimit} times" 
                : "Used ${promo.usedCount} times (No Limit)",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
          if (promo.validUntil != null) ...[
            SizedBox(height: 4),
            Text(
              "Expires: ${promo.validUntil!.toLocal().toString().split(' ')[0]}",
              style: TextStyle(color: Colors.red.shade400, fontSize: 12.sp),
            ),
          ]
        ],
      ),
    );
  }
}
