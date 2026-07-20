import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/address_provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../models/shipping_address.dart';
import 'address_editing_screen.dart';

class CustomerDetailEditingScreen extends ConsumerStatefulWidget {
  final ShippingAddress? currentSelection;

  const CustomerDetailEditingScreen({super.key, this.currentSelection});

  @override
  ConsumerState<CustomerDetailEditingScreen> createState() => _CustomerDetailEditingScreenState();
}

class _CustomerDetailEditingScreenState extends ConsumerState<CustomerDetailEditingScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _emailController;
  ShippingAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).value;
    _nameController = TextEditingController(text: profile?.name ?? "");
    _numberController = TextEditingController(text: profile?.phone ?? "");
    _emailController = TextEditingController(text: profile?.email ?? "");
    _selectedAddress = widget.currentSelection;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.arrow_back, size: 18.sp, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Customer details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              // Save details back to provider
              try {
                await ref.read(userProfileProvider.notifier).updateProfile(
                      name: _nameController.text.trim(),
                      phone: _numberController.text.trim(),
                      email: _emailController.text.trim(),
                    );
                if (mounted) Navigator.pop(context, _selectedAddress);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update details: $e')),
                  );
                }
              }
            },
            child: Text(
              "Done",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            _buildInlineInput("Name :", _nameController),
            SizedBox(height: 24.h),
            
            // Contact Information Group
            Text(
              "Contact information",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            _buildInlineInput("Number :", _numberController, placeholder: "07*******2"),
            SizedBox(height: 16.h),
            _buildInlineInput("Email address :", _emailController, placeholder: "email@domain.com"),
            SizedBox(height: 32.h),
            
            // Shipping Address Group
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Shipping Address",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressEditingScreen()));
                  },
                  child: const Text("Add New", style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _buildAddressList(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineInput(String label, TextEditingController controller, {String? placeholder}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120.w, // Fixed width to align input boxes nicely
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.black87, width: 1.2.w),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black45, // Simulating the grayed out look from img 119
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressList() {
    final addressState = ref.watch(addressProvider);
    return addressState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (addresses) {
        if (addresses.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text("No addresses found. Please add a new address."),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: addresses.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final addr = addresses[index];
            final isSelected = _selectedAddress?.id == addr.id;

            return InkWell(
              onTap: () {
                setState(() => _selectedAddress = addr);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.tertiaryLight.withValues(alpha: 0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.tertiaryNormal : AppColors.borderGrey,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.tertiaryNormal : Colors.grey,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                addr.addressLabel.isNotEmpty ? addr.addressLabel : "Address",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                              ),
                              if (addr.isDefault) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text("Default", style: TextStyle(color: AppColors.primary, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${addr.recipientName}  |  ${addr.phoneNumber}",
                            style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            addr.fullAddress,
                            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                          ),
                        ],
                      ),
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
}
