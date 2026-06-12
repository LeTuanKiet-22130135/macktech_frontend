import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

/// User profile state.
class UserProfileState {
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool isLoading;

  const UserProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.avatarUrl,
    this.isLoading = true,
  });

  UserProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isLoading,
  }) {
    return UserProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserProfileNotifier extends AsyncNotifier<UserProfileState> {
  @override
  Future<UserProfileState> build() async {
    return _fetch();
  }

  Future<UserProfileState> _fetch() async {
    try {
      final profile = await UserService.fetchProfile();
      return UserProfileState(
        name: profile['name'] as String? ?? 'Unknown User',
        email: profile['email'] as String? ?? '',
        phone: profile['phone'] as String? ?? '',
        avatarUrl:
            profile['avatarUrl'] as String? ?? profile['avatar_url'] as String?,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('UserProfileNotifier._fetch error: $e');
      return const UserProfileState(name: 'User', isLoading: false);
    }
  }

  /// Update user avatar URL.
  Future<void> updateAvatar(String url) async {
    try {
      await UserService.updateAvatar(url);
      final current = state.value ?? const UserProfileState();
      state = AsyncData(current.copyWith(avatarUrl: url));
    } catch (e) {
      debugPrint('updateAvatar error: $e');
      rethrow;
    }
  }

  /// Update user profile (name, phone, email).
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      await UserService.updateProfile(name: name, phone: phone, email: email);
      final current = state.value ?? const UserProfileState();
      state = AsyncData(
          current.copyWith(name: name, phone: phone, email: email));
    } catch (e) {
      debugPrint('updateProfile error: $e');
      rethrow;
    }
  }

  /// Change password (Admin/Agent only).
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await UserService.changePassword(
          oldPassword: oldPassword, newPassword: newPassword);
    } catch (e) {
      debugPrint('changePassword error: $e');
      rethrow;
    }
  }

  /// Force refresh profile from server.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfileState>(
        UserProfileNotifier.new);
