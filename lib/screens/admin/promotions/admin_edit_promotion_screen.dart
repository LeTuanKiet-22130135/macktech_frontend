import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/promotion.dart';
import '../../../services/promotion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_button.dart';

class AdminEditPromotionScreen extends StatefulWidget {
  final Promotion? promotion; // If null, it's a create form

  const AdminEditPromotionScreen({super.key, this.promotion});

  @override
  State<AdminEditPromotionScreen> createState() => _AdminEditPromotionScreenState();
}

class _AdminEditPromotionScreenState extends State<AdminEditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _bannerUrlController;
  late TextEditingController _linkedProductIdController;
  
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isActive;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final promo = widget.promotion;
    _titleController = TextEditingController(text: promo?.title ?? '');
    _bannerUrlController = TextEditingController(text: promo?.bannerImageUrl ?? '');
    _linkedProductIdController = TextEditingController(
        text: promo?.linkedProductId != null ? promo!.linkedProductId.toString() : '');
    
    _startDate = promo?.startDate ?? DateTime.now();
    _endDate = promo?.endDate ?? DateTime.now().add(Duration(days: 30));
    _isActive = promo?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bannerUrlController.dispose();
    _linkedProductIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (!mounted) return;
      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
          if (isStart) {
            _startDate = newDateTime;
          } else {
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final newPromo = Promotion(
        id: widget.promotion?.id,
        title: _titleController.text.trim(),
        bannerImageUrl: _bannerUrlController.text.trim(),
        linkedProductId: int.tryParse(_linkedProductIdController.text.trim()),
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
      );

      if (widget.promotion == null) {
        await PromotionService.createPromotion(newPromo);
      } else {
        await PromotionService.updatePromotion(widget.promotion!.id!, newPromo);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promotion saved successfully')),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save promotion')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.promotion != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? "Edit Promotion" : "Create Promotion",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(24.w),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Promotion Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _bannerUrlController,
                    decoration: InputDecoration(
                      labelText: 'Banner Image URL',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _linkedProductIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Linked Product ID (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  // Date Pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateSelector("Start Date", _startDate, true),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDateSelector("End Date", _endDate, false),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  // Is Active Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Is Active",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: _isActive,
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
                  
                  CustomButton(
                    text: "Save Promotion",
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSelector(String label, DateTime date, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _pickDate(context, isStart),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 14.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
