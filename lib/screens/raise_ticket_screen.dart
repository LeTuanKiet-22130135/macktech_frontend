import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app_frontend/theme/app_colors.dart';
import '../services/ticket_service.dart';
import '../services/session_service.dart';

/// Raise a new ticket screen matching design 063.
/// Form with customer info, ticket type selector (035),
/// issue text area, image upload, preferred contact method (071),
/// and Send / Remove all answers buttons.
class RaiseTicketScreen extends StatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends State<RaiseTicketScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _issueController = TextEditingController();

  String? _selectedTicketType;
  File? _attachedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getUser();
    if (mounted) {
      setState(() {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
      });
    }
  }

  Future<void> _pickTicketImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _attachedImage = File(image.path);
      });
    }
  }

  final List<String> _ticketTypes = [
    "Repair Request",
    "Complaint about a product",
    "Price Inquiry",
    "Other",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Raise a new ticket",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information section
                  const Text(
                    "Customer Information",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Customer Name
                  _buildLabel("Customer Name"),
                  const SizedBox(height: 6),
                  _buildTextField(_nameController, "Customer Name"),
                  const SizedBox(height: 16),

                  // Email Address
                  _buildLabel("Email Address"),
                  const SizedBox(height: 6),
                  _buildTextField(_emailController, "Email Address"),
                  const SizedBox(height: 24),

                  // Ticket Type / Category
                  const Text(
                    "Ticket Type / Category",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSelectField(
                    value: _selectedTicketType,
                    placeholder: "Select",
                    onTap: () => _showSelectionSheet(
                      title: "Ticket Type",
                      items: _ticketTypes,
                      onSelected: (val) {
                        setState(() => _selectedTicketType = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Issue
                  const Text(
                    "Issue",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _issueController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: "Type here ...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Upload Image
                  const Text(
                    "Upload Image",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickTicketImage,
                    child: _attachedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _attachedImage!,
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _attachedImage = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                              color: Colors.grey.shade50,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 36,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to attach an image",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectField({
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? placeholder,
              style: TextStyle(
                fontSize: 15,
                color: value != null
                    ? AppColors.tertiaryDarker
                    : Colors.grey.shade400,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }

  /// Shows a bottom sheet with a list of selectable options
  /// matching designs 035 (ticket types) and 071 (contact methods).
  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onSelected(item);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        children: [
          // Remove all answers
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _nameController.clear();
                  _emailController.clear();
                  _issueController.clear();
                  _selectedTicketType = null;
                  _attachedImage = null;
                });
              },
              child: Text(
                "Remove all answers",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiaryDarker,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Send",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTicket() async {
    if (_selectedTicketType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ticket type')),
      );
      return;
    }
    if (_issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ticket = await TicketService.createTicket(
        _selectedTicketType!,
        _issueController.text.trim(),
        image: _attachedImage,
      );

      if (ticket != null) {
        if (mounted) {
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate success and trigger reload on previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ticket submitted successfully!")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to submit ticket.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
