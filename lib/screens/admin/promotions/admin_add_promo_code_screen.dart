import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/promo_code_service.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AdminAddPromoCodeScreen extends StatefulWidget {
  const AdminAddPromoCodeScreen({super.key});

  @override
  State<AdminAddPromoCodeScreen> createState() => _AdminAddPromoCodeScreenState();
}

class _AdminAddPromoCodeScreenState extends State<AdminAddPromoCodeScreen> {
  final _formKey = GlobalKey<FormState>();

  String _discountType = 'percentage';
  bool _isActive = true;
  bool _isSaving = false;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _usageLimitController = TextEditingController();
  
  DateTime? _validFrom;
  DateTime? _validUntil;

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _minOrderController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _validFrom = picked;
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = {
      "code": _codeController.text.trim().toUpperCase(),
      "discountType": _discountType,
      "discountValue": double.tryParse(_valueController.text) ?? 0.0,
      "minimumOrderValue": double.tryParse(_minOrderController.text) ?? 0.0,
      "validFrom": _validFrom?.toIso8601String(),
      "validUntil": _validUntil?.toIso8601String(),
      "usageLimit": int.tryParse(_usageLimitController.text),
      "isActive": _isActive,
    };

    try {
      await PromoCodeService.createPromoCode(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.promoCodeCreated)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating promo code: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createPromoCode, style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Container(
            decoration: BoxDecoration(color: Color(0xFFF5F6F8), shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.0.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.codeString, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _codeController,
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        decoration: _inputDecoration(hint: "e.g. SUMMER26"),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.discountType, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                SizedBox(height: 8.h),
                                DropdownButtonFormField<String>(
                                  initialValue: _discountType,
                                  decoration: _inputDecoration(),
                                  items: [
                                    DropdownMenuItem(value: 'percentage', child: Text(AppLocalizations.of(context)!.percentage)),
                                    DropdownMenuItem(value: 'fixed_amount', child: Text(AppLocalizations.of(context)!.fixedAmount)),
                                  ],
                                  onChanged: (val) {
                                    setState(() => _discountType = val!);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: _valueController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                  decoration: _inputDecoration(hint: "e.g. 15"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Text(AppLocalizations.of(context)!.minimumOrderValue, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _minOrderController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(hint: "e.g. 500.00"),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.validFrom, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                SizedBox(height: 8.h),
                                InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      _validFrom != null ? _validFrom!.toString().split(' ')[0] : 'Select Date',
                                      style: TextStyle(color: _validFrom != null ? Colors.black : Colors.grey.shade500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.validUntil, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                SizedBox(height: 8.h),
                                InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      _validUntil != null ? _validUntil!.toString().split(' ')[0] : 'Select Date',
                                      style: TextStyle(color: _validUntil != null ? Colors.black : Colors.grey.shade500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Text(AppLocalizations.of(context)!.usageLimitOptional, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _usageLimitController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(hint: "e.g. 100"),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.isActive, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                          Switch(
                            value: _isActive,
                            onChanged: (val) {
                              setState(() => _isActive = val);
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 48.h),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF14243A), // Navy blue
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(AppLocalizations.of(context)!.savePromoCode,
                            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Color(0xFF14567B), width: 1.5.w),
      ),
    );
  }
}
