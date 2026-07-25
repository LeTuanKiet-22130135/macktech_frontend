import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/address_provider.dart';
import '../../../models/shipping_address.dart';
import 'address_editing_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.shippingAddresses,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: addressesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64.sp, color: Colors.grey.shade400),
                  SizedBox(height: 16.h),
                  Text(AppLocalizations.of(context)!.noAddressesFound,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(addressProvider);
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(address: address);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddressEditingScreen(address: null)),
          );
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(AppLocalizations.of(context)!.addNew, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final ShippingAddress address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: address.isDefault ? AppColors.primary : Colors.transparent, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.addressLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppColors.textPrimary),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(AppLocalizations.of(context)!.defaultText,
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              "${address.recipientName} | ${address.phoneNumber}",
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 15.sp),
            ),
            SizedBox(height: 4),
            Text(
              "${address.streetAddress}, ${address.ward}, ${address.district}, ${address.cityProvince}",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Divider(height: 1, color: AppColors.border),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: () {
                      ref.read(addressProvider.notifier).setDefaultAddress(address.id!);
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(50, 30)),
                    child: Text(AppLocalizations.of(context)!.setAsDefault, style: TextStyle(color: AppColors.primary)),
                  )
                else
                  SizedBox(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddressEditingScreen(address: address)),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteConfirmation(context, ref),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAddress),
        content: Text(AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(addressProvider.notifier).deleteAddress(address.id!);
            },
            child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
