import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/password_success_dialog.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'login_screen.dart';

import '../providers/auth_provider.dart';

/// Setup New Password screen matching design 169.
/// Shows avatar, "Setup New Password" heading, New Password / Repeat Password
/// fields, and a Save button that triggers the success dialog.
class PasswordSetupScreen extends ConsumerStatefulWidget {
  final String email;
  final String resetToken;

  const PasswordSetupScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  ConsumerState<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends ConsumerState<PasswordSetupScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Avatar
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/Placeholder_01.png',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.pink.shade100,
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    "Setup New Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "Please, setup a new password for\nyour account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // New Password field
                  _buildPasswordField("New Password", _newPasswordController),
                  const SizedBox(height: 14),

                  // Repeat Password field
                  _buildPasswordField("Repeat Password", _repeatPasswordController),

                  const Spacer(),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final newPassword = _newPasswordController.text.trim();
                              final repeatPassword = _repeatPasswordController.text.trim();

                              if (newPassword.isEmpty || repeatPassword.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all fields')),
                                );
                                return;
                              }

                              if (newPassword.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password must be at least 6 characters')),
                                );
                                return;
                              }

                              if (newPassword != repeatPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Passwords do not match')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);
                              try {
                                if (widget.resetToken == 'sms_flow') {
                                  // Update Firebase password directly
                                  await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
                                  await FirebaseAuth.instance.signOut();
                                  
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password updated successfully. Please login.')),
                                  );
                                  
                                  // Use popUntil to clear stack safely then pushReplacement
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                } else {
                                  await ref.read(authProvider.notifier).resetPassword(
                                    widget.email,
                                    widget.resetToken,
                                    newPassword,
                                  );
                                  if (!mounted) return;
                                  showPasswordSuccessDialog(context);
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                                );
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryDarker,
                        disabledBackgroundColor: AppColors.tertiaryDarker.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 400,
              height: 280,
              decoration: const BoxDecoration(
                color: AppColors.tertiaryDarker,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(200),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -30,
            child: Container(
              width: 500,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(200),
                  bottomLeft: Radius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
