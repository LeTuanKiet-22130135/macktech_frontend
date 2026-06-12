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
        const SnackBar(content: Text('Name and Email are required.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(userProfileProvider.notifier).updateProfile(name: name, phone: phone, email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
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
        title: const Text(
          "Personal Details",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
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
                                ? const Icon(Icons.person, size: 50, color: AppColors.primary)
                                : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryNormal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              const Text("Name", style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              const SizedBox(height: 8),
              CustomTextField(hintText: "Enter your name", controller: _nameController),
              const SizedBox(height: 16),

              const Text("Phone Number", style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              const SizedBox(height: 8),
              IntlPhoneField(
                initialCountryCode: _initialCountryCode,
                initialValue: _initialPhoneNumber,
                disableLengthCheck: true,
                showDropdownIcon: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  counterText: '',
                ),
                onChanged: (phone) {
                  _completePhoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 16),

              const Text("Email Address", style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: "Enter your email", 
                keyboardType: TextInputType.emailAddress, 
                controller: _emailController,
                enabled: !_isEmailLocked,
              ),
              const SizedBox(height: 16),

              // Change Password Link
              if (!_isEmailLocked)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Change Password",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 48),

              // Save Button
              CustomButton(
                text: _isSaving ? "Saving..." : "Save",
                onPressed: _isSaving ? () {} : _updateProfile,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
