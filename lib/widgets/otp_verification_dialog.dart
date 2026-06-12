import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_frontend/theme/app_colors.dart';

class OTPVerificationDialog extends StatefulWidget {
  final VoidCallback onVerify;

  const OTPVerificationDialog({super.key, required this.onVerify});

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

class _OTPVerificationDialogState extends State<OTPVerificationDialog> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please enter the OTP (One-Time Password) sent to your registered email/phone number to complete your verification.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildCodeBox(index)),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: widget.onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiaryDarker,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56), // Override global infinite width
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    return Container(
      width: 56,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.backgroundLightAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
