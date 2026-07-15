import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainLayoutScreen extends ConsumerWidget {
  const MainLayoutScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    CartScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Ensure chat FAB is handled properly elsewhere, removed redundant build-phase modification

    return Scaffold(
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          BottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(bottomNavIndexProvider.notifier).set(index);
            },
          ),
        ],
      ),
    );
  }
}
