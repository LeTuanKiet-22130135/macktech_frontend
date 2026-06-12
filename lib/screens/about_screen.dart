import 'package:flutter/material.dart';
import 'package:app_frontend/theme/app_colors.dart';

/// About screen matching designs 060 and 102.
/// Shows the Macktech Mobiles dark circle logo, "About Shoppe" heading,
/// descriptive text, and a contact note.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "User Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Dark circle logo (img 102)
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/about_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: AppColors.primary,
                      child: const Center(
                        child: Icon(
                          Icons.phone_android,
                          color: Colors.blue,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // "About Shoppe" heading
            const Text(
              "About Shoppe",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiaryDarker,
              ),
            ),
            const SizedBox(height: 20),

            // Description paragraph
            Text(
              'Shoppe - Shopping UI kit" is likely a user interface (UI) kit designed to facilitate the development of e-commerce or shopping-related applications. UI kits are collections of pre-designed elements, components, and templates that developers and designers can use to create consistent and visually appealing user interfaces.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),

            // Contact note
            Text(
              "If you need help or you have any questions, feel free to contact me by email.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
