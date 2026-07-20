import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme/app_colors.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Product product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  List<Category> _categories = [];
  int? _selectedCategoryId;

  File? _newImageFile;
  String? _existingImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _brandController;
  late final TextEditingController _subTextController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _colorsController;
  late final TextEditingController _featuresController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    // Pre-fill with what we have from Product
    _nameController = TextEditingController(text: widget.product.title);
    _brandController = TextEditingController(text: widget.product.brand);
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(2),
    );
    _skuController = TextEditingController();
    _subTextController = TextEditingController();
    _stockController = TextEditingController();
    _colorsController = TextEditingController();
    _featuresController = TextEditingController();
    _descController = TextEditingController();

    if (widget.product.imageUrl.isNotEmpty) {
      _existingImageUrl = widget.product.imageUrl;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await CategoryService.getAllCategories();
      final detail = await ProductService.fetchProductDetail(widget.product.id);

      setState(() {
        _categories = categories;

        // Use details
        _skuController.text = detail.sku;
        _subTextController.text = detail.subText;
        _stockController.text = detail.stockQuantity.toString();
        _colorsController.text = detail.colors.join(', ');
        _featuresController.text = detail.keyFeatures;
        _descController.text = detail.description;

        // We don't have categoryId returned in ProductDetail per guide,
        // but if it's there we can set it. If it's not, we have to let the user pick it.
        // guide.md for GET /api/products/{id} does not show categoryId in the response json,
        // but we can try to find it or just leave it blank.
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading edit screen data: $e");
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
        _existingImageUrl = null;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_newImageFile == null) return _existingImageUrl;
    try {
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child(fileName);
      await ref.putFile(_newImageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isSaving = true);

    String? imageUrl = await _uploadImage();

    final colorsList = _colorsController.text
        .split(',')
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
      await ProductService.updateProduct(widget.product.id, productData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await ProductService.deleteProduct(widget.product.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product deleted')));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
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
              color: const Color(0xFFF5F6F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Edit Product",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: _isLoading || _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Product Information",
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
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      hint: Text(
                        "Select Category",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      decoration: _inputDecoration(),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(
                            cat.name,
                            style: TextStyle(fontSize: 16.sp),
                          ),
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
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "e.g. MK-PHONE-001"),
                    ),
                    SizedBox(height: 16.h),

                    // Product Name
                    _buildLabel("Product Name"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _nameController,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "Type Here"),
                    ),
                    SizedBox(height: 16.h),

                    // Brand
                    _buildLabel("Brand"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _brandController,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
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
                    _buildLabel("Product Image"),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Light blueish grey
                          borderRadius: BorderRadius.circular(16.r),
                          image: _newImageFile != null
                              ? DecorationImage(
                                  image: FileImage(_newImageFile!),
                                  fit: BoxFit.cover,
                                )
                              : _existingImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_existingImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            (_newImageFile == null && _existingImageUrl == null)
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 36.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Change",
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "R S . "),
                    ),
                    SizedBox(height: 16.h),

                    // Stock Quantity
                    _buildLabel("Stock Quantity"),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
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
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _isLoading || _isSaving ? null : _deleteProduct,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  "Delete Product",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading || _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14243A), // Navy blue
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 48.w,
                    vertical: 16.h,
                  ),
                  minimumSize: const Size(120, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Update",
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
