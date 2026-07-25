import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../auth/login_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(32.0.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top icon
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.priority_high, color: Colors.white),
                  ),
                ),
                SizedBox(height: 32.h),

                Text(
                  "You are going to delete\nyour account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  "You won't be able to restore your data",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 40.h),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9FBEE4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                        ),
                        child: Text(AppLocalizations.of(dialogCtx)!.cancel,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          _showPasswordVerification();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFC62828),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                        ),
                        child: Text(AppLocalizations.of(dialogCtx)!.delete,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPasswordVerification() {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(32.0.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lock icon
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.red.shade700,
                        size: 36.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    Text(AppLocalizations.of(dialogCtx)!.confirmYourPassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    Text(
                      "Enter your password to permanently\ndelete your account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Password field
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      enabled: !isProcessing,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(dialogCtx)!.enterYourPassword,
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.red.shade400,
                            width: 2.w,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    passwordController.dispose();
                                    Navigator.pop(dialogCtx);
                                  },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(AppLocalizations.of(dialogCtx)!.cancel,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    final password = passwordController.text
                                        .trim();
                                    if (password.isEmpty) {
                                      ScaffoldMessenger.of(
                                        dialogCtx,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(AppLocalizations.of(dialogCtx)!.pleaseEnterYourPassword,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setDialogState(() {
                                      isProcessing = true;
                                    });

                                    try {
                                      await _performAccountDeletion(password);
                                      // Navigation already happened inside
                                      // _performAccountDeletion — dialog route
                                      // is gone, nothing more to do here.
                                    } catch (e) {
                                      setDialogState(() {
                                        isProcessing = false;
                                      });
                                      if (!dialogCtx.mounted) return;
                                      ScaffoldMessenger.of(
                                        dialogCtx,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFC62828),
                              disabledBackgroundColor: Color(
                                0xFFC62828,
                              ).withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: isProcessing
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(AppLocalizations.of(dialogCtx)!.delete,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performAccountDeletion(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user found. Please log in again.');
    }

    // 1. Re-authenticate with Firebase using entered password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Get a fresh Firebase ID token
    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase token.');
    }

    // 3. Send DELETE request to backend
    await ref.read(authProvider.notifier).deleteAccount(idToken);

    // 4. Clear local session first (before any navigation)
    await ref.read(sessionProvider.notifier).logout();

    // 5. Hide the chat FAB
    ref.read(chatFabVisibleProvider.notifier).set(false);

    // 6. Navigate to Login screen BEFORE signing out of Firebase.
    //    This avoids the StreamBuilder in main.dart racing with our navigation.
    if (!mounted) return;
    final nav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    nav.popUntil((route) => route.isFirst);
    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );

    // 7. Now sign out of Firebase (after we've already navigated away)
    await FirebaseAuth.instance.signOut();

    messenger.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.accountSuccessfullyDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.deleteAccount,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0.w),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("⚠️ ", style: TextStyle(fontSize: 18.sp)),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.deleteYourAccount,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context)!.deleteAccountWarningMsg,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showDeleteConfirmation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9FBEE4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(AppLocalizations.of(context)!.iUnderstand,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
