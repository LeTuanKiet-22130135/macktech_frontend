import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'password_setup_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';

import '../providers/auth_provider.dart';

/// Password Recovery - OTP code entry screen matching designs 168/199.
/// Shows avatar, masked phone/email, 4-digit code input boxes,
/// "Send Again" link, Done/Cancel buttons.
class PasswordRecoveryCodeScreen extends ConsumerStatefulWidget {
  final String email;
  const PasswordRecoveryCodeScreen({super.key, required this.email});

  @override
  ConsumerState<PasswordRecoveryCodeScreen> createState() =>
      _PasswordRecoveryCodeScreenState();
}

class _PasswordRecoveryCodeScreenState
    extends ConsumerState<PasswordRecoveryCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String maskedContact = widget.email.replaceRange(
      3, widget.email.indexOf('@'), '*' * (widget.email.indexOf('@') - 3 > 0 ? widget.email.indexOf('@') - 3 : 1)
    );
    final String subtitle = "Enter 4-digits code we sent you\non your Email Address";

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
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Masked contact
                  Text(
                    maskedContact,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 4 code boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => _buildCodeBox(i)),
                  ),
                  const SizedBox(height: 24),

                  // Send Again
                  TextButton(
                    onPressed: () {
                      // Resend code
                    },
                    child: Text(
                      "Send Again",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Done button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              final otp = _controllers.map((c) => c.text).join();
                              if (otp.length != 4) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a 4-digit code')),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);
                              try {
                                final resetToken = await ref.read(authProvider.notifier).verifyOtp(
                                  widget.email,
                                  otp,
                                );
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PasswordSetupScreen(
                                      email: widget.email,
                                      resetToken: resetToken,
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
                              "Done",
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

  Widget _buildCodeBox(int index) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.tertiaryDarker,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          isCollapsed: true,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
