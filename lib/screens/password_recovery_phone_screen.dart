import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:app_frontend/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'password_recovery_sms_code_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class PasswordRecoveryPhoneScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryPhoneScreen({super.key});

  @override
  ConsumerState<PasswordRecoveryPhoneScreen> createState() =>
      _PasswordRecoveryPhoneScreenState();
}

class _PasswordRecoveryPhoneScreenState
    extends ConsumerState<PasswordRecoveryPhoneScreen> {
  String _completePhoneNumber = '';
  bool _isLoading = false;

  Future<void> _handleNext() async {
    if (_completePhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Check if the phone number exists via backend
      final exists = await ref.read(authProvider.notifier).checkPhoneExists(_completePhoneNumber);

      if (!exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.phoneNumberNotFoundInOurRecord),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // 3. Initiate Firebase Phone Verification
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _completePhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-resolution (usually Android only) is handled if needed
          // but typically we let the user enter the code manually.
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() => _isLoading = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PasswordRecoverySmsCodeScreen(
                phone: _completePhoneNumber,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout handler
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() => _isLoading = false);
    }
  }

  Widget _buildWaveHeader() {
    return Container(
      width: double.infinity,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.tertiaryDarker,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 16.w,
              top: 16.h,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Wave header
          _buildWaveHeader(),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  SizedBox(height: 32.h),

                  // Avatar
                  Container(
                    width: 110.w,
                    height: 110.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 3.w),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/Placeholder_01.png',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.pink.shade100,
                          child: Icon(
                            Icons.person,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Title
                  Text(AppLocalizations.of(context)!.passwordRecovery,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Subtitle
                  Text(
                    "Enter your phone number to receive\na recovery code",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 36.h),

                  // Phone Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: IntlPhoneField(
                      initialCountryCode: 'VN',
                      disableLengthCheck: true,
                      showDropdownIcon: true,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                    ),
                  ),

                  Spacer(),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryDarker,
                        disabledBackgroundColor: AppColors.tertiaryDarker
                            .withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.next,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
