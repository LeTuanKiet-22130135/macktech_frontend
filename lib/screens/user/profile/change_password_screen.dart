import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/user_profile_provider.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

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
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillInAllFields)),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.newPasswordMustBeAtLeast6Chara)),
      );
      return;
    }

    if (newPassword != reenterPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.newPasswordsDoNotMatch)),
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
        title: Text(AppLocalizations.of(context)!.changePassword,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight, // Light grayish-blue for back button bg matching 008
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0.w),
          child: Container(
            padding: EdgeInsets.all(24.0.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.oldPassword,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOld,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureOld = !_obscureOld;
                    });
                  },
                ),
                SizedBox(height: 20.h),
                Text(AppLocalizations.of(context)!.newPassword,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
                SizedBox(height: 20.h),
                Text(AppLocalizations.of(context)!.reenterNewPassword,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _reenterPasswordController,
                  obscureText: _obscureReenter,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureReenter = !_obscureReenter;
                    });
                  },
                ),
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryDarker, // Dark navy blue matching 008
                        foregroundColor: Colors.white,
                        minimumSize: Size(120, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(AppLocalizations.of(context)!.done,
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
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
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: 18.sp,
          letterSpacing: 2, // Spacing matching password dots
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: InputBorder.none,
          hintText: '***********',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: EdgeInsets.only(top: 40.h),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Password Changed\nSuccessfully !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
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
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          minimumSize: Size(double.infinity, 56), // Override global infinite width to double.infinity locally just in case
                        ),
                        child: Text(AppLocalizations.of(context)!.ok,
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0.h,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.background, // Off-white backing
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.success, width: 4.w),
                      ),
                      child: Icon(Icons.check, color: AppColors.success, size: 30.sp),
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
