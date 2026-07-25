import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../services/order_service.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final details = await OrderService.getOrderDetails(widget.orderId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (details != null) {
          _order = details;
        } else {
          _error = "Could not load order details.";
        }
      });
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'PROCESSING':
        color = Colors.blue;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'CANCELED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.orderDetails,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final items = _order!['items'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${widget.orderId.split('-').last.toUpperCase()}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Placed on: ${_formatDate(_order!['createdAt'])}",
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(_order!['status'] as String? ?? 'UNKNOWN'),
            ],
          ),
          SizedBox(height: 24.h),

          // Items
          Text(AppLocalizations.of(context)!.items,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          ...items.map((item) {
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLightAlt,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['productTitle']?.toString() ?? 'Item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Color: ${item['selectedColor'] ?? 'N/A'}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₫${(item['productPrice'] ?? 0).toString()}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "x${item['quantity'] ?? 1}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: 24.h),
          // Shipping Info
          Text(AppLocalizations.of(context)!.shippingDetails,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _order!['shippingName'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _order!['shippingPhone'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                ),
                SizedBox(height: 4),
                Text(
                  _order!['shippingAddress'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          // Payment Summary
          Text(AppLocalizations.of(context)!.paymentSummary,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  "Payment Method",
                  _order!['paymentMethod'] ?? '',
                ),
                Divider(height: 24.h),
                _buildSummaryRow(
                  "Subtotal",
                  "₫${(_order!['subtotal'] ?? 0).toString()}",
                ),
                SizedBox(height: 8.h),
                _buildSummaryRow(
                  "Discount",
                  "- ₫${(_order!['discount'] ?? 0).toString()}",
                  color: Colors.green,
                ),
                SizedBox(height: 8.h),
                _buildSummaryRow(
                  "Shipping Fee",
                  "₫${(_order!['shippingFee'] ?? 0).toString()}",
                ),
                Divider(height: 24.h),
                _buildSummaryRow(
                  "Total",
                  "₫${(_order!['total'] ?? 0).toString()}",
                  isTotal: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey.shade600,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? (isTotal ? AppColors.primary : Colors.black),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
