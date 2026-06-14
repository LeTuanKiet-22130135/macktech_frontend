import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/promo_code.dart';
import '../services/promo_code_service.dart';

class AdminEditPromoCodeScreen extends StatefulWidget {
  final PromoCode promoCode;

  const AdminEditPromoCodeScreen({super.key, required this.promoCode});

  @override
  State<AdminEditPromoCodeScreen> createState() => _AdminEditPromoCodeScreenState();
}

class _AdminEditPromoCodeScreenState extends State<AdminEditPromoCodeScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _discountType;
  late bool _isActive;
  bool _isSaving = false;
  bool _isDeleting = false;

  late TextEditingController _codeController;
  late TextEditingController _valueController;
  late TextEditingController _minOrderController;
  late TextEditingController _usageLimitController;
  
  DateTime? _validFrom;
  DateTime? _validUntil;

  @override
  void initState() {
    super.initState();
    _discountType = widget.promoCode.discountType;
    _isActive = widget.promoCode.isActive;
    
    _codeController = TextEditingController(text: widget.promoCode.code);
    _valueController = TextEditingController(text: widget.promoCode.discountValue.toStringAsFixed(0));
    _minOrderController = TextEditingController(text: widget.promoCode.minimumOrderValue.toStringAsFixed(0));
    _usageLimitController = TextEditingController(text: widget.promoCode.usageLimit?.toString() ?? '');
    
    _validFrom = widget.promoCode.validFrom;
    _validUntil = widget.promoCode.validUntil;
  }

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
      initialDate: (isFrom ? _validFrom : _validUntil) ?? DateTime.now(),
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
      await PromoCodeService.updatePromoCode(widget.promoCode.id, data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo Code Updated')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating promo code: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Promo Code?"),
        content: const Text("Are you sure you want to permanently delete this promo code?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("DELETE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        await PromoCodeService.deletePromoCode(widget.promoCode.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promo Code Deleted')));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting promo code: $e')));
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Promo Code", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFFF5F6F8), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isSaving || _isDeleting ? null : _delete,
          )
        ],
      ),
      body: _isSaving || _isDeleting
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.analytics_outlined, color: AppColors.secondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.promoCode.usageLimit != null
                                    ? "This promo code has been used ${widget.promoCode.usedCount} out of ${widget.promoCode.usageLimit} times."
                                    : "This promo code has been used ${widget.promoCode.usedCount} times.",
                                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Code String", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _codeController,
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Discount Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _discountType,
                                  decoration: _inputDecoration(),
                                  items: const [
                                    DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                                    DropdownMenuItem(value: 'fixed_amount', child: Text('Fixed Amount')),
                                  ],
                                  onChanged: (val) {
                                    setState(() => _discountType = val!);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Value", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _valueController,
                                  keyboardType: TextInputType.number,
                                  validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                  decoration: _inputDecoration(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("Minimum Order Value", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _minOrderController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Valid From", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Valid Until", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
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
                      const SizedBox(height: 24),
                      const Text("Usage Limit (Optional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usageLimitController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(hint: "e.g. 100"),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Is Active", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Switch(
                            value: _isActive,
                            onChanged: (val) {
                              setState(() => _isActive = val);
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14243A), // Navy blue
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "SAVE CHANGES",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF14567B), width: 1.5),
      ),
    );
  }
}
