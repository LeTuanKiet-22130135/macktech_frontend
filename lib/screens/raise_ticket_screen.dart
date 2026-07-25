import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app_frontend/theme/app_colors.dart';
import '../services/ticket_service.dart';
import '../services/session_service.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.raiseANewTicket,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information section
                  Text(AppLocalizations.of(context)!.customerInformation,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Customer Name
                  _buildLabel("Customer Name"),
                  SizedBox(height: 6.h),
                  _buildTextField(_nameController, "Customer Name"),
                  SizedBox(height: 16.h),

                  // Email Address
                  _buildLabel("Email Address"),
                  SizedBox(height: 6.h),
                  _buildTextField(_emailController, "Email Address"),
                  SizedBox(height: 24.h),

                  // Ticket Type / Category
                  Text(AppLocalizations.of(context)!.ticketTypeCategory,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 10.h),
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
                  SizedBox(height: 24.h),

                  // Issue
                  Text(AppLocalizations.of(context)!.issue,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _issueController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.typeHere,
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Upload Image
                  Text(AppLocalizations.of(context)!.uploadImage,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  GestureDetector(
                    onTap: _pickTicketImage,
                    child: _attachedImage != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  _attachedImage!,
                                  width: double.infinity,
                                  height: 160.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _attachedImage = null),
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 20.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
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
                                  size: 36.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8.h),
                                Text(AppLocalizations.of(context)!.tapToAttachAnImage,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: 32.h),
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
      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? placeholder,
              style: TextStyle(
                fontSize: 15.sp,
                color: value != null
                    ? AppColors.tertiaryDarker
                    : Colors.grey.shade400,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22.sp),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              return InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onSelected(item);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 18.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 18.sp,
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
              child: Text(AppLocalizations.of(context)!.removeAllAnswers,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Send button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiaryDarker,
                foregroundColor: Colors.white,
                minimumSize: Size(0, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(AppLocalizations.of(context)!.send,
                      style: TextStyle(
                        fontSize: 18.sp,
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
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectATicketType)),
      );
      return;
    }
    if (_issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseDescribeTheIssue)),
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
            SnackBar(content: Text(AppLocalizations.of(context)!.ticketSubmittedSuccessfully)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.failedToSubmitTicket)),
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
