import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/promotion.dart';
import '../../../services/promotion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_image.dart';

class AdminEditPromotionScreen extends StatefulWidget {
  final Promotion? promotion; // If null, it's a create form

  const AdminEditPromotionScreen({super.key, this.promotion});

  @override
  State<AdminEditPromotionScreen> createState() => _AdminEditPromotionScreenState();
}

class _AdminEditPromotionScreenState extends State<AdminEditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isActive;

  List<PromotionProduct> _products = [];
  bool _isSaving = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final promo = widget.promotion;
    _titleController = TextEditingController(text: promo?.title ?? '');
    
    _startDate = promo?.startDate ?? DateTime.now();
    _endDate = promo?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _isActive = promo?.isActive ?? true;
    _products = promo != null ? List.from(promo.products) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (ctx) {
        final skuController = TextEditingController();
        final discountController = TextEditingController();
        return AlertDialog(
          title: const Text("Add Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: skuController,
                decoration: const InputDecoration(labelText: "SKU"),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: discountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Discount % (Optional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final sku = skuController.text.trim();
                if (sku.isNotEmpty) {
                  final discount = double.tryParse(discountController.text.trim());
                  setState(() {
                    _products.add(PromotionProduct(
                      sku: sku,
                      discountPercentage: discount,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final newPromo = Promotion(
        id: widget.promotion?.id,
        title: _titleController.text.trim(),
        bannerImageUrl: widget.promotion?.bannerImageUrl ?? '',
        products: _products,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
      );

      if (widget.promotion == null) {
        if (_selectedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an image for the promotion.')),
          );
          setState(() => _isSaving = false);
          return;
        }
        await PromotionService.createPromotion(newPromo, _selectedImage!);
      } else {
        await PromotionService.updatePromotion(widget.promotion!.id!, newPromo, imageFile: _selectedImage);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promotion saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save promotion')),
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                  
                  // Image picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Banner Image", style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                )
                              : (isEdit && widget.promotion!.bannerImageUrl.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: CustomImage(
                                        imageUrl: widget.promotion!.bannerImageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate, size: 40.sp, color: Colors.grey),
                                        SizedBox(height: 8.h),
                                        const Text("Tap to select image", style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  // Products List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Included Products", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add SKU"),
                      )
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (_products.isEmpty)
                    Text("No products added yet.", style: TextStyle(color: Colors.grey.shade500))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _products.length,
                      itemBuilder: (ctx, i) {
                        final p = _products[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text("SKU: ${p.sku}"),
                          subtitle: p.discountPercentage != null
                              ? Text("Discount: ${p.discountPercentage}%")
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _products.removeAt(i);
                              });
                            },
                          ),
                        );
                      },
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
