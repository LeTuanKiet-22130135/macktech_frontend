import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme/app_colors.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoadingCategories = true;
  List<Category> _categories = [];
  int? _selectedCategoryId;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _subTextController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await CategoryService.getAllCategories();
    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _brandController.dispose();
    _subTextController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _colorsController.dispose();
    _featuresController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _selectedCategoryId = null;
      _imageFile = null;
    });
    _nameController.clear();
    _skuController.clear();
    _brandController.clear();
    _subTextController.clear();
    _priceController.clear();
    _stockController.clear();
    _colorsController.clear();
    _featuresController.clear();
    _descController.clear();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    try {
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('product_images').child(fileName);
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectACategory)));
      return;
    }

    setState(() => _isSaving = true);

    String? imageUrl = await _uploadImage();

    final colorsList = _colorsController.text.split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final productData = {
      "sku": _skuController.text.trim(),
      "title": _nameController.text.trim(),
      "brand": _brandController.text.trim(),
      "subText": _subTextController.text.trim(),
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "categoryId": _selectedCategoryId,
      "stockQuantity": int.tryParse(_stockController.text) ?? 0,
      "colors": colorsList,
      "keyFeatures": _featuresController.text.trim(),
      "description": _descController.text.trim(),
      "imageUrls": imageUrl != null ? [imageUrl] : [],
    };

    try {
      await ProductService.createProduct(productData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.productCreatedSuccessfully)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating product: $e')));
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
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F6F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.addNewProduct,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: _isSaving
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.productInformation,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Category
                    _buildLabel("Category"),
                    SizedBox(height: 8.h),
                    _isLoadingCategories
                        ? Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<int>(
                            initialValue: _selectedCategoryId,
                            hint: Text(AppLocalizations.of(context)!.selectCategory, style: TextStyle(color: Colors.grey.shade400)),
                            icon: Icon(Icons.keyboard_arrow_down),
                            decoration: _inputDecoration(),
                            items: _categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name, style: TextStyle(fontSize: 16.sp)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCategoryId = val;
                              });
                            },
                          ),
                    SizedBox(height: 16.h),

                    // SKU
                    _buildLabel("SKU"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _skuController,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "e.g. MK-PHONE-001"),
                    ),
                    SizedBox(height: 16.h),

                    // Product Name
                    _buildLabel("Product Name"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "Type Here"),
                    ),
                    SizedBox(height: 16.h),

                    // Brand
                    _buildLabel("Brand"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _brandController,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "e.g. Apple, Samsung"),
                    ),
                    SizedBox(height: 16.h),

                    // SubText
                    _buildLabel("Sub Text (Short description)"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _subTextController,
                      decoration: _inputDecoration(hint: "Brief summary"),
                    ),
                    SizedBox(height: 16.h),

                    // Add Image
                    _buildLabel("Add Image"),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16.r),
                          image: _imageFile != null
                              ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageFile == null
                            ? Center(
                                child: Icon(Icons.photo_camera_outlined, size: 48.sp, color: Colors.grey),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Product Price
                    _buildLabel("Product Price"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "100000"),
                    ),
                    SizedBox(height: 16.h),

                    // Stock Quantity
                    _buildLabel("Stock Quantity"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "e.g. 100"),
                    ),
                    SizedBox(height: 16.h),

                    // Colors
                    _buildLabel("Colors (comma separated)"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _colorsController,
                      decoration: _inputDecoration(hint: "Black, Silver"),
                    ),
                    SizedBox(height: 16.h),

                    // Key Features
                    _buildLabel("Key Features"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _featuresController,
                      maxLines: 5,
                      decoration: _inputDecoration(hint: "Type Here ....."),
                    ),
                    SizedBox(height: 16.h),

                    // Description
                    _buildLabel("Description"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: _inputDecoration(hint: "Type Here ....."),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _isSaving ? null : _clearAll,
                child: Text(AppLocalizations.of(context)!.clearAll,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF14243A), // Navy blue
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 48.w,
                    vertical: 16.h,
                  ),
                  minimumSize: Size(120, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.done,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
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
