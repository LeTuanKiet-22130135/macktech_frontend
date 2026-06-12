import 'package:flutter/material.dart';
import 'main_layout_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';

/// Order success screen matching design 144.
/// Shows shopping bag illustration, success message, and CONTINUE SHOPPING button.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Shopping bags illustration with confetti
              SizedBox(
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Confetti dots
                    ..._buildConfetti(),

                    // Light bag (behind)
                    Positioned(
                      top: 30,
                      left: 80,
                      child: _buildShoppingBag(
                        AppColors.primary,
                        AppColors.primary,
                        60,
                        80,
                      ),
                    ),
                    // Dark bag (front)
                    Positioned(
                      top: 60,
                      left: 110,
                      child: _buildShoppingBag(
                        AppColors.primary,
                        AppColors.primary,
                        70,
                        90,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // "Success!" text
              const Text(
                "Success!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiaryDarker,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle messages
              Text(
                "Your order has been placed.\nOrder will be ready for pick-up.\nThank you for choosing our app!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 3),

              // CONTINUE SHOPPING button with subtle pink shadow
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainLayoutScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiaryDarker,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "CONTINUE SHOPPING",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Help button at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 24,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Help",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a stylized shopping bag icon
  Widget _buildShoppingBag(Color bodyColor, Color darkColor, double w, double h) {
    return Column(
      children: [
        // Handle
        Container(
          width: w * 0.4,
          height: h * 0.2,
          decoration: BoxDecoration(
            border: Border.all(color: darkColor, width: 3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Colors.transparent,
          ),
        ),
        // Body
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: bodyColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  /// Builds confetti particles
  List<Widget> _buildConfetti() {
    final confettiData = <Map<String, dynamic>>[
      {"top": 10.0, "left": 100.0, "color": Colors.red, "size": 6.0},
      {"top": 20.0, "left": 180.0, "color": Colors.orange, "size": 5.0},
      {"top": 50.0, "left": 60.0, "color": Colors.blue, "size": 5.0},
      {"top": 40.0, "left": 200.0, "color": Colors.orange, "size": 4.0},
      {"top": 80.0, "left": 40.0, "color": Colors.red, "size": 4.0},
      {"top": 100.0, "left": 210.0, "color": Colors.yellow.shade700, "size": 5.0},
      {"top": 130.0, "left": 70.0, "color": Colors.blue, "size": 4.0},
      {"top": 160.0, "left": 50.0, "color": Colors.grey.shade400, "size": 3.0},
      {"top": 170.0, "left": 200.0, "color": Colors.yellow.shade700, "size": 4.0},
      {"top": 200.0, "left": 90.0, "color": Colors.red, "size": 4.0},
      {"top": 220.0, "left": 160.0, "color": Colors.grey.shade400, "size": 3.0},
      {"top": 5.0, "left": 160.0, "color": Colors.grey.shade500, "size": 6.0},
    ];

    return confettiData.map((c) {
      return Positioned(
        top: c["top"] as double,
        left: c["left"] as double,
        child: Transform.rotate(
          angle: (c["top"] as double) * 0.05,
          child: Container(
            width: c["size"] as double,
            height: (c["size"] as double) * 2,
            decoration: BoxDecoration(
              color: c["color"] as Color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }).toList();
  }
}
