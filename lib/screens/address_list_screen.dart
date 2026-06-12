import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/address_provider.dart';
import '../models/shipping_address.dart';
import 'address_editing_screen.dart';

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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Shipping Addresses",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: addressesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No addresses found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(address: address);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressEditingScreen(address: null)),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add New", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: address.isDefault ? AppColors.primary : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.addressLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Default",
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${address.recipientName} | ${address.phoneNumber}",
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              "${address.streetAddress}, ${address.ward}, ${address.district}, ${address.cityProvince}",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: () {
                      ref.read(addressProvider.notifier).setDefaultAddress(address.id!);
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                    child: const Text("Set as Default", style: TextStyle(color: AppColors.primary)),
                  )
                else
                  const SizedBox(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddressEditingScreen(address: address)),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(addressProvider.notifier).deleteAddress(address.id!);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
