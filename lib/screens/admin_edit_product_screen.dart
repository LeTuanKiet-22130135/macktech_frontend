import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AdminEditProductScreen extends StatefulWidget {
  const AdminEditProductScreen({super.key});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  final List<String> _categories = [
    'Phones',
    'Audio',
    'Phone Cases',
    'Storage',
    'Other',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _colorsController;
  late final TextEditingController _featuresController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    // Simulate pre-filled data
    _selectedCategory = 'Phone Cases';
    _nameController = TextEditingController(
      text: "Spigen Ultra Hybrid 14 Pro Max Case",
    );
    _priceController = TextEditingController(text: "14900.00");
    _colorsController = TextEditingController(text: "Clear, Black");
    _featuresController = TextEditingController(
      text: "Military grade drop protection\nAnti-yellowing PC back",
    );
    _descController = TextEditingController(
      text:
          "Showcase the iPhone 14 Pro Max in a crystal clear frame with lasting clarity...",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _colorsController.dispose();
    _featuresController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _deleteProduct() {
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleting product...")));
    Navigator.pop(context); // Simulate delete returning to dash
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
          "Edit Product",
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
                  "Select Category",
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
              _buildLabel("Product Image"),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Stub for hooking up image picker
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Light blueish grey
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Change",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
              TextButton.icon(
                onPressed: _deleteProduct,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  "Delete Product",
                  style: TextStyle(
                    color: Colors.red,
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
                  "Update",
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
