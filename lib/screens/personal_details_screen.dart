import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../providers/user_profile_provider.dart';
import 'change_password_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  File? _profileImage;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEmailLocked = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _completePhoneNumber = '';
  String _initialPhoneNumber = '';
  String _initialCountryCode = 'VN';

  /// Parse an E.164 phone number (e.g., +84941172573) into country code and national number.
  void _parseE164PhoneNumber(String e164) {
    try {
      final parsed = PhoneNumber.parse(e164);
      _initialCountryCode = parsed.isoCode.name;
      _initialPhoneNumber = parsed.nsn;
    } catch (e) {
      // Fallback: couldn't parse, just use the raw number without '+'
      _initialPhoneNumber = e164.startsWith('+') ? e164.substring(1) : e164;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkProvider();
    _fetchProfile();
  }

  void _checkProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final userInfo in user.providerData) {
        if (userInfo.providerId == 'google.com' || userInfo.providerId == 'facebook.com') {
          _isEmailLocked = true;
          break;
        }
      }
    }
  }

  Future<void> _fetchProfile() async {
    try {
      // Force-refresh from backend to get the latest
      await ref.read(userProfileProvider.notifier).refresh();
      final profile = ref.read(userProfileProvider).value;
      if (mounted && profile != null) {
        setState(() {
          _nameController.text = profile.name;
          final rawPhone = profile.phone;
          _completePhoneNumber = rawPhone;
          // Parse E.164 number to extract country code and national number
          if (rawPhone.startsWith('+')) {
            _parseE164PhoneNumber(rawPhone);
          } else {
            _initialPhoneNumber = rawPhone;
          }
          _emailController.text = profile.email;
          _avatarUrl = profile.avatarUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final phone = _completePhoneNumber;
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.nameAndEmailAreRequired)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(userProfileProvider.notifier).updateProfile(name: name, phone: phone, email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.personalDetails,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading 
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Edit Button
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100.w,
                            height: 100.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.w),
                              image: _profileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_profileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(_avatarUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                            ),
                            child: (_profileImage == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
                                ? Icon(Icons.person, size: 50.sp, color: AppColors.primary)
                                : null,
                      ),
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryNormal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                        child: Icon(Icons.camera_alt, size: 16.sp, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Form Fields
              Text(AppLocalizations.of(context)!.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              CustomTextField(hintText: AppLocalizations.of(context)!.enterYourName, controller: _nameController),
              SizedBox(height: 16.h),

              Text(AppLocalizations.of(context)!.phoneNumber, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              IntlPhoneField(
                initialCountryCode: _initialCountryCode,
                initialValue: _initialPhoneNumber,
                disableLengthCheck: true,
                showDropdownIcon: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
                  counterText: '',
                ),
                onChanged: (phone) {
                  _completePhoneNumber = phone.completeNumber;
                },
              ),
              SizedBox(height: 16.h),

              Text(AppLocalizations.of(context)!.emailAddress, style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: AppLocalizations.of(context)!.enterYourEmail, 
                keyboardType: TextInputType.emailAddress, 
                controller: _emailController,
                enabled: !_isEmailLocked,
              ),
              SizedBox(height: 16.h),

              // Change Password Link
              if (!_isEmailLocked)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(AppLocalizations.of(context)!.changePassword,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              
              SizedBox(height: 48.h),

              // Save Button
              CustomButton(
                text: _isSaving ? "Saving..." : "Save",
                onPressed: _isSaving ? () {} : _updateProfile,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
