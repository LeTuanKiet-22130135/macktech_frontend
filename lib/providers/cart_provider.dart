import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/dio_client.dart';
import 'session_provider.dart';

/// A single cart item backed by the API.
class CartItem {
  final String? cartItemId;
  final Product product;
  final int qty;
  final String? selectedColor;
  final bool selected; // local-only, for checkout selection

  const CartItem({
    this.cartItemId,
    required this.product,
    this.qty = 1,
    this.selectedColor,
    this.selected = true,
  });

  CartItem copyWith({int? qty, String? selectedColor, bool? selected}) {
    return CartItem(
      cartItemId: cartItemId,
      product: product,
      qty: qty ?? this.qty,
      selectedColor: selectedColor ?? this.selectedColor,
      selected: selected ?? this.selected,
    );
  }

  /// Parse a cart item from the GET /api/cart response JSON.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['id']?.toString(),
      product: Product(
        id: json['productId'].toString(),
        title: json['title'] as String? ?? '',
        brand: json['brand'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['imageUrl'] as String? ?? '',
      ),
      qty: (json['quantity'] as num?)?.toInt() ?? 1,
      selectedColor: json['selectedColor'] as String?,
    );
  }
}

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    final session = await ref.watch(sessionProvider.future);
    if (!session.isLoggedIn) return [];

    try {
      final response = await DioClient.instance.get('/api/cart');
      final data = response.data as List<dynamic>? ?? [];
      return data
          .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a product to cart or update its qty/color via the API.
  Future<void> addItem(
    Product product, {
    int qty = 1,
    String? selectedColor,
  }) async {
    final currentList = state.value ?? [];
    final existingIndex = currentList.indexWhere(
      (item) => item.product.id == product.id,
    );

    // Optimistic update
    if (existingIndex >= 0) {
      final existing = currentList[existingIndex];
      final newQty = existing.qty + qty;
      state = AsyncData([
        ...currentList.sublist(0, existingIndex),
        existing.copyWith(
          qty: newQty,
          selectedColor: selectedColor ?? existing.selectedColor,
        ),
        ...currentList.sublist(existingIndex + 1),
      ]);
    } else {
      state = AsyncData([
        ...currentList,
        CartItem(product: product, qty: qty, selectedColor: selectedColor),
      ]);
    }

    try {
      final productIdInt = int.tryParse(product.id) ?? product.id;
      final body = <String, dynamic>{
        'productId': productIdInt,
        'quantity': existingIndex >= 0
            ? (currentList[existingIndex].qty + qty)
            : qty,
      };
      if (selectedColor != null) {
        body['selectedColor'] = selectedColor;
      }
      await DioClient.instance.post('/api/cart/add', data: body);
    } catch (e) {
      // Revert on failure
      ref.invalidateSelf();
    }
  }

  /// Remove a product from the cart via the API.
  Future<void> removeItem(int index) async {
    final currentList = state.value ?? [];
    if (index < 0 || index >= currentList.length) return;

    final item = currentList[index];
    // Optimistic remove
    final newList = [...currentList]..removeAt(index);
    state = AsyncData(newList);

    try {
      final productIdInt = int.tryParse(item.product.id) ?? item.product.id;
      await DioClient.instance.post(
        '/api/cart/remove',
        data: {'productId': productIdInt},
      );
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  /// Update quantity of a cart item via PUT /api/cart.
  Future<void> updateQty(int index, int qty) async {
    if (qty < 1) return;
    final currentList = state.value ?? [];
    if (index < 0 || index >= currentList.length) return;

    final item = currentList[index];
    // Optimistic update
    state = AsyncData([
      for (int i = 0; i < currentList.length; i++)
        if (i == index) currentList[i].copyWith(qty: qty) else currentList[i],
    ]);

    try {
      final productIdInt = int.tryParse(item.product.id) ?? item.product.id;
      final body = <String, dynamic>{
        'productId': productIdInt,
        'quantity': qty,
      };
      if (item.selectedColor != null) {
        body['selectedColor'] = item.selectedColor!;
      }
      await DioClient.instance.put('/api/cart', data: body);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  /// Toggle item selection (local only — for checkout).
  void toggleSelection(int index) {
    final currentList = state.value ?? [];
    if (index < 0 || index >= currentList.length) return;
    state = AsyncData([
      for (int i = 0; i < currentList.length; i++)
        if (i == index)
          currentList[i].copyWith(selected: !currentList[i].selected)
        else
          currentList[i],
    ]);
  }

  /// Clear all items from the cart.
  Future<void> clearCart() async {
    final currentList = state.value ?? [];
    state = const AsyncData([]);

    try {
      for (final item in currentList) {
        final productIdInt = int.tryParse(item.product.id) ?? item.product.id;
        await DioClient.instance.post(
          '/api/cart/remove',
          data: {'productId': productIdInt},
        );
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  /// Get only selected items (for checkout).
  List<CartItem> get selectedItems =>
      (state.value ?? []).where((item) => item.selected).toList();
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

/// Derived: subtotal of selected items.
final cartSubtotalProvider = Provider<double>((ref) {
  final cartAsync = ref.watch(cartProvider);
  final items = cartAsync.value ?? [];
  double total = 0;
  for (final item in items) {
    if (item.selected) {
      total += item.product.price * item.qty;
    }
  }
  return total;
});
