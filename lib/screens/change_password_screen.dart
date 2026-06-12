import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../providers/session_provider.dart';
import '../providers/user_profile_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureReenter = true;
  bool _isUpdating = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _reenterPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final reenterPassword = _reenterPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || reenterPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters')),
      );
      return;
    }

    if (newPassword != reenterPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final role = ref.read(userRoleProvider) ?? 'user';

      if (role == 'admin' || role == 'agent') {
        // Use backend API for admin/agent
        await ref.read(userProfileProvider.notifier).changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
      } else {
        // Use Firebase for user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null || user.email == null) {
          throw Exception('User not logged in or email not found');
        }

        // Re-authenticate
        final cred = EmailAuthProvider.credential(email: user.email!, password: oldPassword);
        await user.reauthenticateWithCredential(cred);

        // Update password
        await user.updatePassword(newPassword);
      }

      if (mounted) {
        _showSuccessPopup(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '').replaceFirst('[firebase_auth/invalid-credential] ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight, // Light grayish-blue for back button bg matching 008
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Old Password",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOld,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureOld = !_obscureOld;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "New Password",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Re-enter New Password",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _reenterPasswordController,
                  obscureText: _obscureReenter,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureReenter = !_obscureReenter;
                    });
                  },
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryDarker, // Dark navy blue matching 008
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Done",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Transparent white back
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 18,
          letterSpacing: 2, // Spacing matching password dots
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          hintText: "***********",
          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Password Changed\nSuccessfully !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final nav = Navigator.of(context);
                          Navigator.pop(ctx); // close dialog
                          nav.pop(); // close password screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.overlayDark, // Dark navy
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          minimumSize: const Size(double.infinity, 56), // Override global infinite width to double.infinity locally just in case
                        ),
                        child: const Text(
                          "OK",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.background, // Off-white backing
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.success, width: 4),
                      ),
                      child: const Icon(Icons.check, color: AppColors.success, size: 30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
