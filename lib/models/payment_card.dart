class PaymentCard {
  final String id;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String brand; // 'visa' or 'mastercard'
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.brand,
    this.isDefault = false,
  });
}
