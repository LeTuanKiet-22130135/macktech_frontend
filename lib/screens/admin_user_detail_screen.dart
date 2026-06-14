import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user.dart';
import '../services/admin_user_service.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update profile")));
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
        title: const Text("Change Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder()),
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("SAVE", style: TextStyle(color: Colors.white)),
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password changed successfully")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to change password")));
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
        title: const Text("Delete User?"),
        content: const Text("This action is irreversible. Are you sure you want to delete this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User deleted")));
            Navigator.pop(context, true); // Return true to refresh list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete user")));
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
        title: const Text("User Details", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFFF5F6F8), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isSaving ? null : _deleteUser,
            )
        ],
      ),
      body: _isLoading || _isSaving
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _user == null
                  ? const Center(child: Text("User not found."))
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
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
                                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _user!.email,
                                      style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _user!.role.toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                decoration: _inputDecoration(),
                              ),
                              const SizedBox(height: 24),

                              const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController,
                                decoration: _inputDecoration(hint: "e.g. 0123456789"),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 24),

                              const Text("Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _addressController,
                                decoration: _inputDecoration(hint: "User address"),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 32),

                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF14243A), // Navy blue
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text(
                                    "SAVE CHANGES",
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: _changePassword,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF14243A)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text(
                                    "CHANGE PASSWORD",
                                    style: TextStyle(color: Color(0xFF14243A), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
