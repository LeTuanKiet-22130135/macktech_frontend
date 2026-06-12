import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_image.dart';
import 'order_success_screen.dart';
import '../theme/app_colors.dart';
import '../providers/notification_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/address_provider.dart';
import '../models/shipping_address.dart';
import '../services/dio_client.dart';
import '../services/shipping_service.dart';
import '../services/order_service.dart';
import 'payment_webview_screen.dart';
import 'customer_detail_editing_screen.dart';

/// Checkout / Place Order screen matching design 143.
/// Displays customer details, order items, payment method, and order info.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPayment = 'Cash on Delivery';
  String? _selectedCard;
  ShippingAddress? _selectedAddress;
  bool _paymentExpanded = false;
  bool _visaExpanded = false;

  final TextEditingController _discountController = TextEditingController();
  double _appliedDiscount = 0.0;
  String? _appliedDiscountCode;
  bool _isCheckingPromo = false;

  double _shippingFee = 0.0;
  bool _isCalculatingShipping = false;
  bool _isCheckingOut = false;

  final List<Map<String, dynamic>> _savedCards = [
    {'label': '**** **** **** 7690', 'holder': 'Joyce Maxwell'},
    {'label': '**** **** **** 1122', 'holder': 'Maxwell'},
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Cash on Delivery', 'icon': Icons.money, 'color': Colors.green},
    {'name': 'Visa Payment', 'icon': Icons.credit_card, 'color': Colors.blue},
    {'name': 'MoMo', 'icon': Icons.account_balance_wallet, 'color': Colors.pink},
    {'name': 'VnPAY', 'icon': Icons.payment, 'color': Colors.deepOrange},
  ];

  double get _subtotal {
    double total = 0;
    final items = ref.read(cartProvider).value ?? [];
    for (var item in items) {
      if (item.selected) {
        total += item.product.price * item.qty;
      }
    }
    return total;
  }

  double get _total {
    double total = _subtotal - _appliedDiscount + _shippingFee;
    return total < 0 ? 0 : total;
  }

  String _getPaymentMethodCode() {
    switch (_selectedPayment) {
      case 'Cash on Delivery':
        return 'cod';
      case 'Visa Payment':
        return 'visa';
      case 'MoMo':
        return 'momo';
      case 'VnPAY':
        return 'vnpay';
      default:
        return 'cod';
    }
  }

  Future<void> _applyDiscount() async {
    final code = _discountController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isCheckingPromo = true);

    try {
      final response = await DioClient.instance.post(
        '/api/promo/check',
        data: {
          'code': code,
          'subtotal': _subtotal,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final eligible = data['eligible'] as bool? ?? false;
      final discountAmount = (data['discountAmount'] as num?)?.toDouble() ?? 0.0;
      final message = data['message'] as String? ?? '';

      if (mounted) {
        setState(() {
          if (eligible) {
            _appliedDiscount = discountAmount;
            _appliedDiscountCode = code;
          } else {
            _appliedDiscount = 0.0;
            _appliedDiscountCode = null;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appliedDiscount = 0.0;
          _appliedDiscountCode = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check promo code: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingPromo = false);
    }
  }

  void _sendOrderNotification() {
    try {
      final enabled = ref.read(notificationEnabledProvider).value ?? false;
      if (enabled) {
        ref.read(notificationEnabledProvider.notifier).sendOrderNotification();
      }
    } catch (e) {
      debugPrint("Error sending notification: $e");
    }
  }

  Future<void> _calculateShippingFee(ShippingAddress address) async {
    setState(() => _isCalculatingShipping = true);
    
    try {
      final districtId = await ShippingService.getDistrictId(address.district, address.cityProvince);
      if (districtId != null) {
        final wardCode = await ShippingService.getWardCode(districtId, address.ward);
        if (wardCode != null) {
          final fee = await ShippingService.calculateFee(districtId, wardCode, _getPaymentMethodCode());
          if (mounted && _selectedAddress?.id == address.id) {
            setState(() {
              _shippingFee = fee;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error calculating shipping: $e");
    } finally {
      if (mounted && _selectedAddress?.id == address.id) {
        setState(() => _isCalculatingShipping = false);
      }
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _showAddCardDialog() {
    final ownerController = TextEditingController();
    final numberController = TextEditingController();
    final expController = TextEditingController();
    final cvvController = TextEditingController();
    bool saveCardInfo = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Owner
                    const Text(
                      "Card Owner",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ownerController,
                      decoration: _dialogInputDecoration("Joyce Maxwell"),
                    ),
                    const SizedBox(height: 20),

                    // Card Number
                    const Text(
                      "Card Number",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: _dialogInputDecoration("5254 7634 8734 7690"),
                    ),
                    const SizedBox(height: 20),

                    // EXP & CVV
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "EXP",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: expController,
                                decoration: _dialogInputDecoration("24/24"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "CVV",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: cvvController,
                                decoration: _dialogInputDecoration("7763"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Save card info toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Save card info",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        Switch(
                          value: saveCardInfo,
                          activeThumbColor: AppColors.success,
                          onChanged: (val) {
                            setDialogState(() => saveCardInfo = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Cancel & Save Card buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (numberController.text.isNotEmpty) {
                                final lastFour = numberController.text.replaceAll(' ', '');
                                final display = '**** **** **** ${lastFour.length >= 4 ? lastFour.substring(lastFour.length - 4) : lastFour}';
                                setState(() {
                                  _savedCards.add({
                                    'label': display,
                                    'holder': ownerController.text.isNotEmpty ? ownerController.text : 'Card Holder',
                                  });
                                  _selectedCard = display;
                                });
                              }
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tertiaryDarker,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Save Card",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Eagerly pick the default address on first build if already loaded
    final addressState = ref.watch(addressProvider);
    if (_selectedAddress == null && addressState.hasValue && addressState.value!.isNotEmpty) {
      final addresses = addressState.value!;
      final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull;
      if (defaultAddr != null) {
        // Schedule the setState + shipping calc after the current build frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedAddress == null) {
            setState(() {
              _selectedAddress = defaultAddr;
            });
            _calculateShippingFee(defaultAddr);
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Place Order",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCustomerDetails(context),
            const SizedBox(height: 16),
            _buildItemsSection(),
            const SizedBox(height: 16),
            _buildPaymentMethod(),
            const SizedBox(height: 16),
            _buildDiscountSection(),
            const SizedBox(height: 16),
            _buildOrderInfoCard(),
            const SizedBox(height: 24),

            // Phone number warning
            Builder(
              builder: (context) {
                final profile = ref.watch(userProfileProvider).value;
                final hasPhone = profile != null && profile.phone.isNotEmpty;
                if (!hasPhone) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please add your phone number in your profile before checking out.',
                              style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Checkout button
            SizedBox(
              width: 260,
              height: 56,
              child: Builder(
                builder: (context) {
                  final profile = ref.watch(userProfileProvider).value;
                  final hasPhone = profile != null && profile.phone.isNotEmpty;
                  return ElevatedButton(
                onPressed: _isCalculatingShipping || _selectedAddress == null || _isCheckingOut || !hasPhone ? null : () async {
                  setState(() => _isCheckingOut = true);

                  // Create order
                  final districtId = await ShippingService.getDistrictId(_selectedAddress!.district, _selectedAddress!.cityProvince);
                  if (districtId == null) {
                    setState(() => _isCheckingOut = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to resolve district ID.')));
                    }
                    return;
                  }
                  
                  final wardCode = await ShippingService.getWardCode(districtId, _selectedAddress!.ward);
                  if (wardCode == null) {
                    setState(() => _isCheckingOut = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to resolve ward code.')));
                    }
                    return;
                  }

                  // Gather item names from selected cart items
                  final cartItems = ref.read(cartProvider).value ?? [];
                  final itemNames = cartItems
                      .where((item) => item.selected)
                      .map((item) => item.product.title)
                      .toList();

                  final result = await OrderService.createOrder(
                    addressId: _selectedAddress!.id!,
                    toDistrictId: districtId,
                    toWardCode: wardCode,
                    paymentMethod: _getPaymentMethodCode(),
                    finalCost: _total,
                    itemNames: itemNames,
                    promoCode: _appliedDiscountCode,
                    paymentCardId: null,
                  );

                  if (mounted) {
                    setState(() => _isCheckingOut = false);
                  }

                  if (result != null) {
                    final paymentUrl = result['paymentUrl'] as String?;
                    if (paymentUrl != null && paymentUrl.isNotEmpty) {
                      // Online payment flow — open WebView
                      // The backend will redirect to macktech://payment-result
                      // after processing. The app_links listener in main.dart
                      // handles navigation to success/failure screen.
                      if (mounted) {
                        final paymentTitle = _selectedPayment == 'MoMo' ? 'MoMo Payment' : 'VNPAY Payment';
                        final success = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentWebviewScreen(paymentUrl: paymentUrl, title: paymentTitle),
                          ),
                        );
                        
                        if (success == true) {
                          // Web payment succeeded (caught by webview URL intercept)
                          _sendOrderNotification();
                          ref.read(cartProvider.notifier).clearCart();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                            );
                          }
                        } else if (success == false) {
                          // Web payment failed (caught by webview URL intercept)
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment failed or cancelled.')),
                            );
                          }
                        }
                        // If success == null, the webview was either closed manually or an external app was launched.
                        // In the latter case, the app_links listener in main.dart will handle the result.
                      }
                    } else {
                      // COD flow — order created successfully
                      _sendOrderNotification();
                      ref.read(cartProvider.notifier).clearCart();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                        );
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to create order.')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiaryDarker,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isCalculatingShipping || _isCheckingOut
                  ? const SizedBox(
                      width: 24, 
                      height: 24, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(BuildContext context) {
    final profileState = ref.watch(userProfileProvider).value;
    final name = profileState?.name ?? 'Unknown User';
    final phone = (profileState != null && profileState.phone.isNotEmpty) ? profileState.phone : 'Not provided';
    final email = (profileState != null && profileState.email.isNotEmpty) ? profileState.email : 'Not provided';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Customer details",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<ShippingAddress>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerDetailEditingScreen(),
                    ),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _selectedAddress = result;
                    });
                    _calculateShippingFee(result);
                  }
                },
                child: Text(
                  "Edit",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: "Name : ",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                TextSpan(
                  text: name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Contact information",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Number : ",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      TextSpan(
                        text: phone,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Email address : ",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      TextSpan(
                        text: email,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Shipping address",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _selectedAddress != null
              ? Text(
                  _selectedAddress!.fullAddress,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                )
              : const Text("No address selected", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Items",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...(ref.read(cartProvider).value ?? []).where((item) => item.selected).map((item) {
            final product = item.product;
            final qty = item.qty;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: CustomImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.brand,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Color: Blue  ·  Storage: 512 GB",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Units: $qty",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "₫${(product.price * qty).toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - tap to expand/collapse
          GestureDetector(
            onTap: () {
              setState(() => _paymentExpanded = !_paymentExpanded);
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Payment Method",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedPayment == 'Visa Payment' && _selectedCard != null
                            ? 'Visa $_selectedCard'
                            : _selectedPayment,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _paymentExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable dropdown list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildPaymentDropdown(),
            crossFadeState: _paymentExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDropdown() {
    return Column(
      children: [
        Divider(height: 1, color: AppColors.borderGrey),
        ..._paymentMethods.map((method) {
          final name = method['name'] as String;
          final isSelected = _selectedPayment == name;
          final isVisa = name == 'Visa Payment';

          return Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedPayment = name;
                    if (isVisa) {
                      _visaExpanded = !_visaExpanded;
                    } else {
                      _visaExpanded = false;
                      _selectedCard = null;
                      _paymentExpanded = false;
                    }
                  });
                  if (_selectedAddress != null) {
                    _calculateShippingFee(_selectedAddress!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.tertiaryLight.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (method['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          color: method['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.tertiaryDark : Colors.black87,
                          ),
                        ),
                      ),
                      if (isVisa)
                        AnimatedRotation(
                          turns: _visaExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20),
                        )
                      else if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.tertiaryNormal, size: 20),
                    ],
                  ),
                ),
              ),

              // Visa sub-dropdown: saved cards + Add Card
              if (isVisa && _visaExpanded)
                _buildVisaSubList(),
            ],
          );
        }),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildVisaSubList() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Saved cards
          ..._savedCards.map((card) {
            final label = card['label'] as String;
            final isCardSelected = _selectedCard == label;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedPayment = 'Visa Payment';
                  _selectedCard = label;
                  _paymentExpanded = false;
                });
                if (_selectedAddress != null) {
                  _calculateShippingFee(_selectedAddress!);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.credit_card, size: 18, color: Colors.blue.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCardSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isCardSelected ? AppColors.tertiaryDark : Colors.black87,
                            ),
                          ),
                          Text(
                            card['holder'] as String,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    if (isCardSelected)
                      const Icon(Icons.check_circle, color: AppColors.tertiaryNormal, size: 18),
                  ],
                ),
              ),
            );
          }),

          // Add Card button
          InkWell(
            onTap: _showAddCardDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.tertiaryNormal, width: 1.5),
                    ),
                    child: const Icon(Icons.add, size: 16, color: AppColors.tertiaryNormal),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Add Card",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tertiaryNormal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Discount Code",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  decoration: InputDecoration(
                    hintText: "Enter code (e.g. SAVE10)",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isCheckingPromo ? null : _applyDiscount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiaryDarker,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 48),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isCheckingPromo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Apply",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
              ),
            ],
          ),
          if (_appliedDiscountCode != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Code '$_appliedDiscountCode' applied",
                  style: const TextStyle(color: AppColors.success, fontSize: 13),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _discountController.clear();
                      _appliedDiscount = 0.0;
                      _appliedDiscountCode = null;
                    });
                  },
                  child: const Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Info",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 14),
          _buildInfoRow("Subtotal", "₫${_subtotal.toStringAsFixed(0)}"),
          const SizedBox(height: 6),
          _buildInfoRow("Shipping Fee", _isCalculatingShipping ? "..." : "₫${_shippingFee.toStringAsFixed(0)}"),
          const SizedBox(height: 6),
          _buildInfoRow("Discount", "-₫${_appliedDiscount.toStringAsFixed(0)}", 
            valueColor: _appliedDiscount > 0 ? AppColors.success : null),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 10),
          _buildInfoRow(
            "Total",
            "₫${_total.toStringAsFixed(0)}",
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
