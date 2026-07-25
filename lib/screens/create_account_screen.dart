import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_blob_background.dart';
import 'login_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _completePhoneNumber = '';

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color _navyBlue = AppColors.tertiaryNormal;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performRegister() async {
    final name = _nameController.text.trim();
    final phone = _completePhoneNumber;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillInAllRequiredFields)),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordMustBeAtLeast6Characte)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Call the backend API to create the user profile and Firebase account
      await ref.read(authProvider.notifier).register(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );

      // 2. Temporarily sign in to send email verification
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.sendEmailVerification();

      // 3. Sign out immediately — user must verify email before logging in
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.checkYourEmailForALinkToVerify),
          duration: Duration(seconds: 5),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Shared blob background
          SizedBox.expand(child: CustomPaint(painter: AuthBlobPainter())),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.16),

                  // "Create Account" title — left-aligned, large, two lines
                  Text(
                    "Create\nAccount",
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),

                  // Name field
                  buildAuthPillField(
                    hintText: AppLocalizations.of(context)!.name,
                    controller: _nameController,
                  ),
                  SizedBox(height: 12.h),

                  // Phone number field (E.164)
                  IntlPhoneField(
                    initialCountryCode: 'VN',
                    disableLengthCheck: true,
                    showDropdownIcon: true,
                    flagsButtonPadding: EdgeInsets.only(left: 16.w),
                    style: TextStyle(fontSize: 16.sp, color: AppColors.primary),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.phoneNumber,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16.sp,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundLightAlt,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.r),
                        borderSide: BorderSide(color: AppColors.textSecondary, width: 1.w),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.r),
                        borderSide: BorderSide(color: AppColors.textSecondary, width: 1.w),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.r),
                        borderSide: BorderSide(color: AppColors.tertiaryNormal, width: 1.5.w),
                      ),
                      counterText: '',
                    ),
                    onChanged: (phone) {
                      _completePhoneNumber = phone.completeNumber;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Email field
                  buildAuthPillField(
                    hintText: AppLocalizations.of(context)!.email,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  SizedBox(height: 12.h),

                  // Password field with visibility toggle
                  buildAuthPillField(
                    hintText: AppLocalizations.of(context)!.password,
                    obscure: _obscurePassword,
                    controller: _passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                        size: 22.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // "Done" button — navy blue, full-width, rounded
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _performRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navyBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.done,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // "Cancel" text
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),

                  // "Already have an Account?" link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.alreadyHaveAnAccount,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
