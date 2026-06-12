import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/images/success.png', height: 250, errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.check_circle, color: AppColors.success, size: 150);
              }),
              const SizedBox(height: 40),
              const Text("Success!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              const Text(
                "Your order will be delivered soon.\nThank you for choosing our app!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
              ),
              const Spacer(),
              CustomButton(text: "CONTINUE SHOPPING", onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
