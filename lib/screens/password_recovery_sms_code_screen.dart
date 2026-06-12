import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'password_setup_screen.dart';

class PasswordRecoverySmsCodeScreen extends StatefulWidget {
  final String phone;
  final String verificationId;

  const PasswordRecoverySmsCodeScreen({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<PasswordRecoverySmsCodeScreen> createState() =>
      _PasswordRecoverySmsCodeScreenState();
}

class _PasswordRecoverySmsCodeScreenState
    extends State<PasswordRecoverySmsCodeScreen> {
  // 6 boxes for Firebase Phone Auth
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
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

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      // Sign the user in temporarily to allow password update
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navigate to setup screen with flag 'sms_flow'
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PasswordSetupScreen(
            email: widget.phone, // Passing phone in the email field for UI display purposes
            resetToken: 'sms_flow',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Invalid or expired OTP')),
      );
      setState(() => _isLoading = false);
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
      height: 120,
      decoration: const BoxDecoration(
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
              left: 16,
              top: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    return Container(
      width: 42,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.tertiaryDarker,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String maskedPhone = widget.phone;
    if (widget.phone.length > 4) {
      maskedPhone = '${widget.phone.substring(0, widget.phone.length - 4).replaceAll(RegExp(r'\d'), '*')} ${widget.phone.substring(widget.phone.length - 4)}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Wave header
          _buildWaveHeader(),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    "Enter 6-digits code we sent you\non your Phone Number",
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
                    maskedPhone,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 6 code boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) => _buildCodeBox(i)),
                  ),
                  const SizedBox(height: 24),

                  // Send Again
                  TextButton(
                    onPressed: () {
                      // Optionally handle resend here
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
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryDarker,
                        disabledBackgroundColor:
                            AppColors.tertiaryDarker.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
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
}
