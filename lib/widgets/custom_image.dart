import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Icon(Icons.image, color: Colors.grey, size: 40);
    }
    
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey, size: 40),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey, size: 40),
      );
    }
  }
}
