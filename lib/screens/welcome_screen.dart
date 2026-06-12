import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';

/// Welcome/splash screen matching design 140.
/// Uses a dark textured background (full-104) with the Macktech logo
/// centered, a "Let's get started" button, and an
/// "I already have an account" link.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _navyBlue = AppColors.tertiaryNormal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen dark background (img 104)
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
          ),

          // Slight dark overlay for depth
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo image (logohomecscreen.png)
                  Image.asset(
                    'assets/images/logohomecscreen.png',
                    width: 280,
                    fit: BoxFit.contain,
                  ),

                  const Spacer(flex: 4),

                  // "Let's get started" button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navyBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Let's get started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "I already have an account" row
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "I already have an account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _navyBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
