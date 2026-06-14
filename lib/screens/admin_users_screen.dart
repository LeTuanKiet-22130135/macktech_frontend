import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user.dart';
import '../services/admin_user_service.dart';
import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<User> _users = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await AdminUserService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load users: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "User Management",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "View and manage customer and admin accounts.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                        : _users.isEmpty
                            ? const Center(child: Text("No users found."))
                            : ListView.builder(
                                itemCount: _users.length,
                                itemBuilder: (context, index) {
                                  final user = _users[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AdminUserDetailScreen(userId: user.id),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchUsers();
                                        }
                                      },
                                      child: _buildUserCard(user),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    Color roleColor = user.role.toLowerCase() == 'admin' ? AppColors.primary : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.tertiaryLight,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: TextStyle(
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}
