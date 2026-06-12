import 'package:flutter/material.dart';
import '../models/payment_card.dart';
import 'package:app_frontend/theme/app_colors.dart';

class PaymentCardWidget extends StatelessWidget {
  final PaymentCard card;

  const PaymentCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.brand == 'visa' 
              ? [AppColors.tertiaryDark, AppColors.primary] 
              : [AppColors.primary, AppColors.textSecondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.credit_card, color: Colors.white, size: 30),
              Text(card.brand.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            card.cardNumber,
            style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Card Holder", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(card.cardHolder.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Expires", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(card.expiryDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
