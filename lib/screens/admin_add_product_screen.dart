import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  final List<String> _categories = [
    'Phones',
    'Audio',
    'Phone Cases',
    'Storage',
    'Other',
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _colorsController.dispose();
    _featuresController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _selectedCategory = null;
    });
    _nameController.clear();
    _priceController.clear();
    _colorsController.clear();
    _featuresController.clear();
    _descController.clear();
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
      body: SingleChildScrollView(
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
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                hint: Text(
                  "Phones",
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
                decoration: _inputDecoration(),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Product Name
              _buildLabel("Product Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(hint: "Type Here"),
              ),
              const SizedBox(height: 16),

              // Add Image
              _buildLabel("Add Image"),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Stub for hooking up image picker
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0), // Grey placeholder
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product Price
              _buildLabel("Product Price"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(hint: "R S . "),
              ),
              const SizedBox(height: 16),

              // Colors
              _buildLabel("Colors"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: const Icon(Icons.add, color: Colors.grey, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _colorsController,
                      decoration: _inputDecoration(),
                    ),
                  ),
                ],
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

              const SizedBox(height: 40), // Spacing for bottom bar
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
                onPressed: _clearAll,
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
                onPressed: () {
                  // Simulate submission and pop
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14243A), // Navy blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  minimumSize: const Size(
                    120,
                    56,
                  ), // Override global infinite width
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
