import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImagePlaceholder('assets/images/banner.jpg'),
          const SizedBox(height: 16),
          _buildImagePlaceholder('assets/images/084.png'),
          const SizedBox(height: 16),
          _buildImagePlaceholder('assets/images/banner.jpg'),
          const SizedBox(height: 16),
          _buildImagePlaceholder('assets/images/084.png'),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 160,
            width: double.infinity,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  "Image missing: ${imagePath.split('/').last}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
