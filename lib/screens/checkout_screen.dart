import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Owner
                    Text(
                      "Card Owner",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: ownerController,
                      decoration: _dialogInputDecoration("Joyce Maxwell"),
                    ),
                    SizedBox(height: 20.h),

                    // Card Number
                    Text(
                      "Card Number",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      decoration: _dialogInputDecoration("5254 7634 8734 7690"),
                    ),
                    SizedBox(height: 20.h),

                    // EXP & CVV
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "EXP",
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: expController,
                                decoration: _dialogInputDecoration("24/24"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "CVV",
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: cvvController,
                                decoration: _dialogInputDecoration("7763"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Save card info toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Save card info",
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
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
                    SizedBox(height: 16.h),

                    // Cancel & Save Card buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey.shade500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
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
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Save Card",
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.arrow_back, size: 18.sp),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Place Order",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildCustomerDetails(context),
            SizedBox(height: 16.h),
            _buildItemsSection(),
            SizedBox(height: 16.h),
            _buildPaymentMethod(),
            SizedBox(height: 16.h),
            _buildDiscountSection(),
            SizedBox(height: 16.h),
            _buildOrderInfoCard(),
            SizedBox(height: 24.h),

            // Phone number warning
            Builder(
              builder: (context) {
                final profile = ref.watch(userProfileProvider).value;
                final hasPhone = profile != null && profile.phone.isNotEmpty;
                if (!hasPhone) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Please add your phone number in your profile before checking out.',
                              style: TextStyle(fontSize: 13.sp, color: Colors.orange.shade900),
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
              width: 260.w,
              height: 56.h,
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
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: _isCalculatingShipping || _isCheckingOut
                  ? SizedBox(
                      width: 24.w, 
                      height: 24.h, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32.h),
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Customer details",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Name : ",
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
                TextSpan(
                  text: name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "Contact information",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Number : ",
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                      TextSpan(
                        text: phone,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Email address : ",
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                      TextSpan(
                        text: email,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Shipping address",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: _selectedAddress != null
              ? Text(
                  _selectedAddress!.fullAddress,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
                )
              : Text("No address selected", style: TextStyle(color: Colors.redAccent, fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Items",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
          ),
          SizedBox(height: 12.h),
          ...(ref.read(cartProvider).value ?? []).where((item) => item.selected).map((item) {
            final product = item.product;
            final qty = item.qty;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: CustomImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.brand,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.sp,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Color: Blue  ·  Storage: 512 GB",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Units: $qty",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "₫${(product.price * qty).toStringAsFixed(0)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
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
        borderRadius: BorderRadius.circular(16.r),
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
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Payment Method",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedPayment == 'Visa Payment' && _selectedCard != null
                            ? 'Visa $_selectedCard'
                            : _selectedPayment,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                      ),
                      SizedBox(width: 4.w),
                      AnimatedRotation(
                        turns: _paymentExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 22.sp),
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
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.tertiaryLight.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: (method['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          color: method['color'] as Color,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.tertiaryDark : Colors.black87,
                          ),
                        ),
                      ),
                      if (isVisa)
                        AnimatedRotation(
                          turns: _visaExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 20.sp),
                        )
                      else if (isSelected)
                        Icon(Icons.check_circle, color: AppColors.tertiaryNormal, size: 20.sp),
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
                padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 12.h),
                child: Row(
                  children: [
                    Icon(Icons.credit_card, size: 18.sp, color: Colors.blue.shade400),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isCardSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isCardSelected ? AppColors.tertiaryDark : Colors.black87,
                            ),
                          ),
                          Text(
                            card['holder'] as String,
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    if (isCardSelected)
                      Icon(Icons.check_circle, color: AppColors.tertiaryNormal, size: 18.sp),
                  ],
                ),
              ),
            );
          }),

          // Add Card button
          InkWell(
            onTap: _showAddCardDialog,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.tertiaryNormal, width: 1.5.w),
                    ),
                    child: Icon(Icons.add, size: 16.sp, color: AppColors.tertiaryNormal),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Add Card",
                    style: TextStyle(
                      fontSize: 13.sp,
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Discount Code",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  decoration: InputDecoration(
                    hintText: "Enter code (e.g. SAVE10)",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton(
                onPressed: _isCheckingPromo ? null : _applyDiscount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiaryDarker,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 48),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: _isCheckingPromo
                    ? SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Apply",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
              ),
            ],
          ),
          if (_appliedDiscountCode != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  "Code '$_appliedDiscountCode' applied",
                  style: TextStyle(color: AppColors.success, fontSize: 13.sp),
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
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13.sp,
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Info",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp),
          ),
          SizedBox(height: 14.h),
          _buildInfoRow("Subtotal", "₫${_subtotal.toStringAsFixed(0)}"),
          SizedBox(height: 6.h),
          _buildInfoRow("Shipping Fee", _isCalculatingShipping ? "..." : "₫${_shippingFee.toStringAsFixed(0)}"),
          SizedBox(height: 6.h),
          _buildInfoRow("Discount", "-₫${_appliedDiscount.toStringAsFixed(0)}", 
            valueColor: _appliedDiscount > 0 ? AppColors.success : null),
          SizedBox(height: 10.h),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 10.h),
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
            fontSize: 15.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 15.sp,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
