import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_blob_background.dart';
import '../providers/auth_provider.dart';
import 'main_layout_screen.dart';
import 'admin_main_layout_screen.dart';
import 'agent_main_layout_screen.dart';
import 'password_recovery_methods_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Color _navyBlue = AppColors.tertiaryNormal;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Routes the user to the correct portal based on their role.
  void _routeByRole(String role) {
    switch (role) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainLayoutScreen()),
        );
        break;
      case 'agent':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AgentMainLayoutScreen()),
        );
        break;
      default: // 'user'
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
        );
    }
  }

  /// Performs login via auth provider.
  Future<void> _performLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).performLogin(email, password);
    final authState = ref.read(authProvider);

    if (!mounted) return;

    if (authState.status == AuthStatus.authenticated && authState.role != null) {
      _routeByRole(authState.role!);
    } else if (authState.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage ?? 'Login failed.')),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Google Sign-In via auth provider.
  Future<void> _performGoogleLogin() async {
    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).performGoogleLogin();
    final authState = ref.read(authProvider);

    if (!mounted) return;

    if (authState.status == AuthStatus.authenticated && authState.role != null) {
      _routeByRole(authState.role!);
    } else if (authState.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage ?? 'Login failed.')),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Facebook Sign-In via auth provider.
  Future<void> _performFacebookLogin() async {
    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).performFacebookLogin();
    final authState = ref.read(authProvider);

    if (!mounted) return;

    if (authState.status == AuthStatus.authenticated && authState.role != null) {
      _routeByRole(authState.role!);
    } else if (authState.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage ?? 'Login failed.')),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Shared blob background
          SizedBox.expand(child: CustomPaint(painter: AuthBlobPainter())),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.18),

                  // "Login" title
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Email field
                  buildAuthPillField(
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  buildAuthPillField(
                    hintText: "Password",
                    obscure: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 10),

                  // "Forgot your password?"
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PasswordRecoveryMethodsScreen(
                            initialEmail: _emailController.text,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot your password?",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // "Next" button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _performLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navyBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // "Cancel" text link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider with "Or login with"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or login with",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google & Facebook buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _performGoogleLogin,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text("Google"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _performFacebookLogin,
                          icon: const Icon(
                            Icons.facebook,
                            size: 24,
                            color: Color(0xFF1877F2),
                          ),
                          label: const Text("Facebook"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
