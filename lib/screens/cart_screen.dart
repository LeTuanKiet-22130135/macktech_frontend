import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_image.dart';
import 'checkout_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Cart",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: cartAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text('Failed to load cart'),
              TextButton(
                onPressed: () => ref.invalidate(cartProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (cartItems) {
          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(
                        context, ref, cartItems[index], index);
                  },
                ),
              ),
              // Order Info + Place Order
              _buildOrderInfo(context, ref, subtotal),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, WidgetRef ref, CartItem item, int index) {
    final product = item.product;
    final qty = item.qty;
    final selected = item.selected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              ref.read(cartProvider.notifier).toggleSelection(index);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Product image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLightAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.selectedColor != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.selectedColor!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          "₫${product.price.toStringAsFixed(0)}.",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Qty controls
                            Row(
                              children: [
                                _buildQtyBtn(Icons.keyboard_arrow_down, () {
                                  if (qty > 1) {
                                    ref
                                        .read(cartProvider.notifier)
                                        .updateQty(index, qty - 1);
                                  }
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    "$qty",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                _buildQtyBtn(Icons.keyboard_arrow_up, () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .updateQty(index, qty + 1);
                                }),
                              ],
                            ),
                            // Delete icon
                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .removeItem(index);
                              },
                              child: Icon(
                                Icons.delete_outline,
                                size: 22,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildOrderInfo(
      BuildContext context, WidgetRef ref, double subtotal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.borderGrey, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Info",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          _buildInfoRow("Subtotal", "₫${subtotal.toStringAsFixed(0)}"),
          const SizedBox(height: 6),
          _buildInfoRow("Discount", "₫0"),
          const SizedBox(height: 6),
          _buildInfoRow(
            "Total",
            "₫${subtotal.toStringAsFixed(0)}",
            isBold: true,
          ),
          const SizedBox(height: 20),

          // Place Order button
          Center(
            child: SizedBox(
              width: 220,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiaryDarker,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Place Order",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
