import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'session_provider.dart';
import 'navigation_provider.dart';

/// Auth state for tracking login/register flow status.
enum AuthStatus { idle, loading, error, authenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? role;

  const AuthState({this.status = AuthStatus.idle, this.errorMessage, this.role});

  AuthState copyWith({AuthStatus? status, String? errorMessage, String? role}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void resetState() => state = const AuthState();

  /// Unified login via Firebase Auth email/password → backend.
  /// Falls back to admin login if Firebase auth fails.
  Future<void> performLogin(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      Map<String, dynamic> result;

      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        final user = userCredential.user;
        if (user != null && !user.emailVerified) {
          throw Exception('Please verify your email address before logging in.');
        }

        final idToken = await user?.getIdToken();
        if (idToken == null) {
          throw Exception('Failed to retrieve Firebase token.');
        }

        result = await AuthService.login(idToken: idToken, provider: 'email');
      } on FirebaseAuthException catch (_) {
        result = await AuthService.adminLogin(email: email, password: password);
      }

      await ref.read(sessionProvider.notifier).login(result);
      final role = result['role'] as String? ?? 'user';

      // Register FCM token with backend
      await NotificationService.registerToken(force: true);

      // Set chat FAB visibility based on role
      ref.read(chatFabVisibleProvider.notifier).set(role == 'user');

      state = AuthState(status: AuthStatus.authenticated, role: role);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Google Sign-In → Firebase → backend.
  Future<void> performGoogleLogin() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve Firebase token.');
      }

      final result =
          await AuthService.login(idToken: idToken, provider: 'google');
      await ref.read(sessionProvider.notifier).login(result);
      final role = result['role'] as String? ?? 'user';

      await NotificationService.registerToken(force: true);
      ref.read(chatFabVisibleProvider.notifier).set(role == 'user');

      state = AuthState(status: AuthStatus.authenticated, role: role);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Facebook Sign-In → Firebase → backend.
  Future<void> performFacebookLogin() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final fbResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (fbResult.status == LoginStatus.cancelled) {
        state = const AuthState(status: AuthStatus.idle);
        return;
      }
      if (fbResult.status != LoginStatus.success ||
          fbResult.accessToken == null) {
        throw Exception('Facebook login failed.');
      }

      final credential = FacebookAuthProvider.credential(
        fbResult.accessToken!.tokenString,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve Firebase token.');
      }

      final result =
          await AuthService.login(idToken: idToken, provider: 'facebook');
      await ref.read(sessionProvider.notifier).login(result);
      final role = result['role'] as String? ?? 'user';

      await NotificationService.registerToken(force: true);
      ref.read(chatFabVisibleProvider.notifier).set(role == 'user');

      state = AuthState(status: AuthStatus.authenticated, role: role);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Register a new user.
  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await AuthService.registerUser(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      state = const AuthState(status: AuthStatus.authenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Logout completely from Firebase, Social Providers, and local session.
  Future<void> logout() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        for (final provider in user.providerData) {
          if (provider.providerId == 'google.com') {
            try {
              await GoogleSignIn.instance.signOut();
            } catch (_) {}
          } else if (provider.providerId == 'facebook.com') {
            try {
              await FacebookAuth.instance.logOut();
            } catch (_) {}
          }
        }
        // Sign out from Firebase
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }

      // Clear backend/local session
      await ref.read(sessionProvider.notifier).logout();
      
      state = const AuthState(status: AuthStatus.idle);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Delete user account.
  Future<void> deleteAccount(String firebaseToken) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await AuthService.deleteAccount(firebaseToken);
      await ref.read(sessionProvider.notifier).logout();
      state = const AuthState(status: AuthStatus.idle);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Send password recovery OTP.
  Future<void> sendPasswordRecoveryOtp(String email) async {
    try {
      await AuthService.sendPasswordRecoveryOtp(email);
    } catch (e) {
      debugPrint('sendPasswordRecoveryOtp error: $e');
      rethrow;
    }
  }

  /// Verify password recovery OTP. Returns resetToken.
  Future<String> verifyOtp(String email, String otp) async {
    try {
      return await AuthService.verifyPasswordRecoveryOtp(email, otp);
    } catch (e) {
      debugPrint('verifyOtp error: $e');
      rethrow;
    }
  }

  /// Reset password using resetToken.
  Future<void> resetPassword(
      String email, String resetToken, String newPassword) async {
    try {
      await AuthService.resetPassword(email, resetToken, newPassword);
    } catch (e) {
      debugPrint('resetPassword error: $e');
      rethrow;
    }
  }

  /// Check if phone exists.
  Future<bool> checkPhoneExists(String phone) async {
    try {
      return await AuthService.checkPhoneExists(phone);
    } catch (e) {
      debugPrint('checkPhoneExists error: $e');
      rethrow;
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
