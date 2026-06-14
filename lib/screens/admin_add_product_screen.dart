import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../theme/app_colors.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product created successfully')));
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
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Add new product",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category
                    _buildLabel("Category"),
                    const SizedBox(height: 8),
                    _isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            hint: Text("Select Category", style: TextStyle(color: Colors.grey.shade400)),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            decoration: _inputDecoration(),
                            items: _categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(cat.name, style: const TextStyle(fontSize: 16)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCategoryId = val;
                              });
                            },
                          ),
                    const SizedBox(height: 16),

                    // SKU
                    _buildLabel("SKU"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _skuController,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "e.g. MK-PHONE-001"),
                    ),
                    const SizedBox(height: 16),

                    // Product Name
                    _buildLabel("Product Name"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "Type Here"),
                    ),
                    const SizedBox(height: 16),

                    // Brand
                    _buildLabel("Brand"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _brandController,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "e.g. Apple, Samsung"),
                    ),
                    const SizedBox(height: 16),

                    // SubText
                    _buildLabel("Sub Text (Short description)"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subTextController,
                      decoration: _inputDecoration(hint: "Brief summary"),
                    ),
                    const SizedBox(height: 16),

                    // Add Image
                    _buildLabel("Add Image"),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(16),
                          image: _imageFile != null
                              ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageFile == null
                            ? const Center(
                                child: Icon(Icons.photo_camera_outlined, size: 48, color: Colors.grey),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Price
                    _buildLabel("Product Price"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "100000"),
                    ),
                    const SizedBox(height: 16),

                    // Stock Quantity
                    _buildLabel("Stock Quantity"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      decoration: _inputDecoration(hint: "e.g. 100"),
                    ),
                    const SizedBox(height: 16),

                    // Colors
                    _buildLabel("Colors (comma separated)"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _colorsController,
                      decoration: _inputDecoration(hint: "Black, Silver"),
                    ),
                    const SizedBox(height: 16),

                    // Key Features
                    _buildLabel("Key Features"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _featuresController,
                      maxLines: 5,
                      decoration: _inputDecoration(hint: "Type Here ....."),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel("Description"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: _inputDecoration(hint: "Type Here ....."),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              TextButton(
                onPressed: _isSaving ? null : _clearAll,
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14243A), // Navy blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  minimumSize: const Size(120, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
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
