import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../providers/session_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/navigation_provider.dart';
import 'purchase_history_screen.dart';
import 'personal_details_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'customer_support_screen.dart';
import 'address_list_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Compress image
        maxWidth: 400,    // Resize image
        maxHeight: 400,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingAvatar = true);

      final file = File(pickedFile.path);
      
      // Get the UID from Firebase or Session Service
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid ?? 'unknown_user_${DateTime.now().millisecondsSinceEpoch}';

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('$userId.jpg');

      await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get Download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update backend via provider
      await ref.read(userProfileProvider.notifier).updateAvatar(downloadUrl);

      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update avatar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final notificationsAsync = ref.watch(notificationEnabledProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error loading profile: $e')),
        data: (profile) {
          final notificationsEnabled = notificationsAsync.value ?? false;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  // Replicating the AppBar actions
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 28),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildProfileHeader(profile),
                const SizedBox(height: 40),
          
                // Options List matching 010.png
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildListTile("Personal Details", onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()));
                      }),
                      _buildDivider(),
                      
                      _buildListTile("Shipping Addresses", onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen()));
                      }),
                      _buildDivider(),
                      
                      _buildListTile("Purchase History", onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen()));
                      }),
                      _buildDivider(),
                      
                      _buildListTile(
                        "Get Customer Support", 
                        subtitle: "Raise any concerns about a product/s",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerSupportScreen()));
                        },
                      ),
                      _buildDivider(),
                      
                      _buildNotificationTile(notificationsEnabled),
                      _buildDivider(),
                      
                      _buildListTile("About", onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                      }),
                      _buildDivider(),
                      
                      _buildLogoutTile(),
                      _buildDivider(),
                    ],
                  ),
                ),
              ],
            ),
          ));
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileState profile) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickAndUploadAvatar,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  image: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(profile.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                    : null,
              ),
              if (_isUploadingAvatar)
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              if (!_isUploadingAvatar)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildNotificationTile(bool notificationsEnabled) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text(
        "Notifications",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Switch(
        value: notificationsEnabled,
        activeThumbColor: AppColors.primary,
        onChanged: (val) {
          ref.read(notificationEnabledProvider.notifier).toggle(val);
        },
      ),
    );
  }

  Widget _buildLogoutTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text(
        "Logout",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.redAccent,
        ),
      ),
      onTap: () => _showLogoutDialog(),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red prohibition icon in circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.not_interested,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Title text
                const Text(
                  "Sure you want to Log-out ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
                const SizedBox(height: 32),

                // Cancel + Yes buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Yes button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final role = ref.read(userRoleProvider);
                          if (role == 'user') {
                            await FirebaseAuth.instance.signOut();
                          }
                          await ref.read(authProvider.notifier).logout();
                          ref.read(chatFabVisibleProvider.notifier).set(false);
                          if (!context.mounted) return;
                          final nav = Navigator.of(context, rootNavigator: true);
                          nav.popUntil((route) => route.isFirst);
                          nav.pushReplacement(
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
