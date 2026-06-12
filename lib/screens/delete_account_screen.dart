import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';
import '../providers/navigation_provider.dart';
import 'login_screen.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.priority_high, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  "You are going to delete\nyour account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "You won't be able to restore your data",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9FBEE4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          _showPasswordVerification();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text(
                          "DELETE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
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

  void _showPasswordVerification() {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lock icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.red.shade700,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Confirm Your Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Enter your password to permanently\ndelete your account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Password field
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      enabled: !isProcessing,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red.shade400,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                                    passwordController.dispose();
                                    Navigator.pop(dialogCtx);
                                  },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    final password = passwordController.text
                                        .trim();
                                    if (password.isEmpty) {
                                      ScaffoldMessenger.of(
                                        dialogCtx,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter your password',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setDialogState(() {
                                      isProcessing = true;
                                    });

                                    try {
                                      await _performAccountDeletion(password);
                                      // Navigation already happened inside
                                      // _performAccountDeletion — dialog route
                                      // is gone, nothing more to do here.
                                    } catch (e) {
                                      setDialogState(() {
                                        isProcessing = false;
                                      });
                                      if (!dialogCtx.mounted) return;
                                      ScaffoldMessenger.of(
                                        dialogCtx,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              disabledBackgroundColor: const Color(
                                0xFFC62828,
                              ).withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
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
      },
    );
  }

  Future<void> _performAccountDeletion(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user found. Please log in again.');
    }

    // 1. Re-authenticate with Firebase using entered password
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Get a fresh Firebase ID token
    final idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase token.');
    }

    // 3. Send DELETE request to backend
    await ref.read(authProvider.notifier).deleteAccount(idToken);

    // 4. Clear local session first (before any navigation)
    await ref.read(sessionProvider.notifier).logout();

    // 5. Hide the chat FAB
    ref.read(chatFabVisibleProvider.notifier).set(false);

    // 6. Navigate to Login screen BEFORE signing out of Firebase.
    //    This avoids the StreamBuilder in main.dart racing with our navigation.
    if (!mounted) return;
    final nav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    nav.popUntil((route) => route.isFirst);
    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );

    // 7. Now sign out of Firebase (after we've already navigated away)
    await FirebaseAuth.instance.signOut();

    messenger.showSnackBar(
      const SnackBar(content: Text("Account successfully deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Delete Account",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text("⚠️ ", style: TextStyle(fontSize: 18)),
                  Text(
                    "Delete Your Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "This will permanently erase your profile, order history, and saved payment methods. You'll lose access to all MACKTECH MOBILES app benefits.",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showDeleteConfirmation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9FBEE4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "I understand",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
