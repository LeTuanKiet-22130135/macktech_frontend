import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              padding: EdgeInsets.symmetric(horizontal: 32.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.18),

                  // "Login" title
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Email field
                  buildAuthPillField(
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  SizedBox(height: 20.h),

                  // Password field
                  buildAuthPillField(
                    hintText: "Password",
                    obscure: true,
                    controller: _passwordController,
                  ),
                  SizedBox(height: 10.h),

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
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // "Next" button
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _performLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navyBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // "Cancel" text link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Divider with "Or login with"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          "Or login with",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Google & Facebook buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _performGoogleLogin,
                          icon: Icon(Icons.g_mobiledata, size: 28.sp),
                          label: const Text("Google"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _performFacebookLogin,
                          icon: Icon(
                            Icons.facebook,
                            size: 24.sp,
                            color: Color(0xFF1877F2),
                          ),
                          label: const Text("Facebook"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
