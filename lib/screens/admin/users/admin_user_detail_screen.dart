import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/user.dart';
import '../../../services/admin_user_service.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  User? _user;
  String? _error;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _fetchUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AdminUserService.getUserById(widget.userId);
      if (mounted) {
        if (user != null) {
          setState(() {
            _user = user;
            _nameController.text = user.name;
            _phoneController.text = user.phone ?? '';
            _addressController.text = user.address ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = "User not found.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load user details: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedUser = await AdminUserService.updateUser(widget.userId, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      if (mounted) {
        if (updatedUser != null) {
          setState(() {
            _user = updatedUser;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToUpdateProfile)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _changePassword() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changePassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.newPassword, border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmPassword, border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Required";
                  if (val != passwordController.text) return "Passwords do not match";
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppLocalizations.of(context)!.save, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true && passwordController.text.isNotEmpty) {
      setState(() => _isSaving = true);
      try {
        final success = await AdminUserService.changeUserPassword(widget.userId, passwordController.text);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.passwordChangedSuccessfully)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToChangePassword)));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteUser),
        content: Text(AppLocalizations.of(context)!.thisActionIsIrreversibleAreYou),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        final success = await AdminUserService.deleteUser(widget.userId);
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.userDeleted)));
            Navigator.pop(context, true); // Return true to refresh list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeleteUser)));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        title: Text(AppLocalizations.of(context)!.userDetails, style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Container(
            decoration: BoxDecoration(color: Color(0xFFF5F6F8), shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          if (_user != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: _isSaving ? null : _deleteUser,
            )
        ],
      ),
      body: _isLoading || _isSaving
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : _user == null
                  ? Center(child: Text(AppLocalizations.of(context)!.userNotFound))
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.0.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Header
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: AppColors.primary,
                                      child: Text(
                                        _user!.name.isNotEmpty ? _user!.name[0].toUpperCase() : '?',
                                        style: TextStyle(fontSize: 32.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      _user!.email,
                                      style: TextStyle(fontSize: 16.sp, color: Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        _user!.role.toUpperCase(),
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32.h),
                              
                              Text(AppLocalizations.of(context)!.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: _nameController,
                                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                decoration: _inputDecoration(),
                              ),
                              SizedBox(height: 24.h),

                              Text(AppLocalizations.of(context)!.phoneNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: _phoneController,
                                decoration: _inputDecoration(hint: "e.g. 0123456789"),
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 24.h),

                              Text(AppLocalizations.of(context)!.address, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: _addressController,
                                decoration: _inputDecoration(hint: "User address"),
                                maxLines: 2,
                              ),
                              SizedBox(height: 32.h),

                              SizedBox(
                                width: double.infinity,
                                height: 56.h,
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF14243A), // Navy blue
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: Text(AppLocalizations.of(context)!.saveChanges,
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                width: double.infinity,
                                height: 56.h,
                                child: OutlinedButton(
                                  onPressed: _changePassword,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Color(0xFF14243A)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: Text(AppLocalizations.of(context)!.changePassword,
                                    style: TextStyle(color: Color(0xFF14243A), fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
