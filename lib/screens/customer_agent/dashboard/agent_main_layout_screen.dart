import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'agent_dashboard_screen.dart';
import '../chat/agent_conversation_list_screen.dart';
import '../../user/auth/login_screen.dart';
import '../../user/profile/change_password_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AgentMainLayoutScreen extends ConsumerStatefulWidget {
  const AgentMainLayoutScreen({super.key});

  @override
  ConsumerState<AgentMainLayoutScreen> createState() => _AgentMainLayoutScreenState();
}

class _AgentMainLayoutScreenState extends ConsumerState<AgentMainLayoutScreen> {
  int _selectedIndex = 0; // Only Dashboard for now

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.tertiaryNormal,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.rocket_launch, color: Colors.blueAccent),
            ),
            SizedBox(width: 8.w),
            Text(AppLocalizations.of(context)!.supportAgentPortal,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0.w),
            child: PopupMenuButton<int>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              offset: Offset(0, 50),
              color: Colors.white,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.support_agent, color: AppColors.textPrimary),
              ),
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
                  );
                } else if (value == 2) {
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0.h),
                    child: Text(AppLocalizations.of(context)!.agent,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.changePassword,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24.w),
                      Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.textPrimary),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context)!.logOut,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24.w),
                      Icon(Icons.logout, size: 20.sp, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      drawer: _buildAgentDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AgentDashboardScreen(),
          AgentConversationListScreen(),
        ],
      ),
    );
  }

  Widget _buildAgentDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDrawerItem(
                icon: Icons.dashboard_outlined,
                title: "TICKET DASHBOARD",
                isSelected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16.h),
              _buildDrawerItem(
                icon: Icons.chat_bubble_outline,
                title: "MESSAGES",
                isSelected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = isSelected ? AppColors.tertiaryNormal : Colors.transparent;
    final fgColor = isSelected ? Colors.white : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: fgColor),
        title: Text(
          title,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
