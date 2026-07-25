import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:app_frontend/l10n/app_localizations.dart';

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
          SnackBar(content: Text(AppLocalizations.of(context)!.avatarUpdatedSuccessfully)),
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
        loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error loading profile: $e')),
        data: (profile) {
          final notificationsEnabled = notificationsAsync.value ?? false;
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 120.h),
              child: Column(
                children: [
                  // Replicating the AppBar actions
                  Padding(
                    padding: EdgeInsets.only(right: 16.w, top: 8.h),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 28.sp),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildProfileHeader(profile),
                SizedBox(height: 40.h),
          
                // Options List matching 010.png
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildListTile(AppLocalizations.of(context)!.personalDetails, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PersonalDetailsScreen()));
                      }),
                      _buildDivider(),
                      
                      _buildListTile(AppLocalizations.of(context)!.shippingAddresses, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AddressListScreen()));
                      }),
                      _buildDivider(),
                      
                      _buildListTile(AppLocalizations.of(context)!.purchaseHistory, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PurchaseHistoryScreen()));
                      }),
                      _buildDivider(),
                      
                      _buildListTile(
                        AppLocalizations.of(context)!.getCustomerSupport, 
                        subtitle: AppLocalizations.of(context)!.raiseAnyConcerns,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerSupportScreen()));
                        },
                      ),
                      _buildDivider(),
                      
                      _buildNotificationTile(notificationsEnabled),
                      _buildDivider(),
                      
                      _buildListTile(AppLocalizations.of(context)!.about, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()));
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
                width: 110.w,
                height: 110.h,
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
                    ? Icon(Icons.person, size: 60.sp, color: AppColors.primary)
                    : null,
              ),
              if (_isUploadingAvatar)
                Container(
                  width: 110.w,
                  height: 110.h,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              if (!_isUploadingAvatar)
                Positioned(
                  bottom: 0.h,
                  right: 0.w,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          profile.name,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          profile.email,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
      ) : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildNotificationTile(bool notificationsEnabled) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      title: Text(AppLocalizations.of(context)!.notifications,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      leading: Icon(Icons.logout, color: Colors.redAccent),
      title: Text(AppLocalizations.of(context)!.logout,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
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
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red prohibition icon in circle
                Container(
                  width: 72.w,
                  height: 72.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.not_interested,
                      color: Colors.red,
                      size: 48.sp,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // Title text
                Text(AppLocalizations.of(context)!.sureYouWantToLogout,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
                SizedBox(height: 32.h),

                // Cancel + Yes buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(AppLocalizations.of(context)!.cancel,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
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
                            MaterialPageRoute(builder: (_) => WelcomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(AppLocalizations.of(context)!.yes,
                          style: TextStyle(
                            fontSize: 18.sp,
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
    return Divider(height: 1, thickness: 1, color: AppColors.border);
  }
}
