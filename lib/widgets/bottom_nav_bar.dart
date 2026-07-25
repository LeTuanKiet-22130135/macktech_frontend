import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_frontend/theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

class BottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final wishlistAsync = ref.watch(wishlistProvider);

    final cartCount = cartAsync.value?.length ?? 0;
    final wishlistCount = wishlistAsync.value?.length ?? 0;

    return Positioned(
      bottom: 24.h,
      left: 24.w,
      right: 24.w,
      child: Container(
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          color: AppColors.tertiaryDarker, // Deep dark blue
          borderRadius: BorderRadius.circular(40.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildIcon(0, Icons.home, Icons.home_outlined),
            _buildIcon(
                1, Icons.shopping_bag, Icons.shopping_bag_outlined, cartCount),
            _buildIcon(
                2, Icons.favorite, Icons.favorite_outline, wishlistCount),
            _buildIcon(3, Icons.person, Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(int index, IconData activeIcon, IconData inactiveIcon,
      [int badgeCount = 0]) {
    final isSelected = currentIndex == index;
    Widget iconWidget = Icon(
      isSelected ? activeIcon : inactiveIcon,
      color: isSelected ? Colors.white : Colors.white70,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(badgeCount.toString()),
        backgroundColor: Colors.redAccent,
        child: iconWidget,
      );
    }

    return IconButton(
      icon: iconWidget,
      onPressed: () => onTap(index),
    );
  }
}
