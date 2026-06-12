import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'password_recovery_code_screen.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class PasswordRecoveryEmailScreen extends ConsumerStatefulWidget {
  final String initialEmail;

  const PasswordRecoveryEmailScreen({super.key, required this.initialEmail});

  @override
  ConsumerState<PasswordRecoveryEmailScreen> createState() =>
      _PasswordRecoveryEmailScreenState();
}

class _PasswordRecoveryEmailScreenState extends ConsumerState<PasswordRecoveryEmailScreen> {
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                    "Password Recovery",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "Enter your email address to\nrecover your password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Email Input Field
                  CustomTextField(
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),

                  const Spacer(),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter an email')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);
                              try {
                                await ref.read(authProvider.notifier).sendPasswordRecoveryOtp(email);
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PasswordRecoveryCodeScreen(
                                      email: email,
                                    ),
                                  ),
                                );
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
                              "Next",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
          // Dark navy background
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
          // Light blue accent wave
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
}
