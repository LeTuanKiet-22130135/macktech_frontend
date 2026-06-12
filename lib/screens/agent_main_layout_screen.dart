import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'agent_dashboard_screen.dart';
import 'agent_conversation_list_screen.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';

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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rocket_launch, color: Colors.blueAccent),
            ),
            const SizedBox(width: 8),
            const Text(
              "Support Agent Portal",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<int>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              offset: const Offset(0, 50),
              color: Colors.white,
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.support_agent, color: AppColors.textPrimary),
              ),
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                } else if (value == 2) {
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  enabled: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Agent",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "CHANGE PASSWORD",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24),
                      Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textPrimary),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "LOG OUT",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 24),
                      Icon(Icons.logout, size: 20, color: AppColors.textPrimary),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
              const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: fgColor),
        title: Text(
          title,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
