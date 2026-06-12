import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_service.dart';

/// Immutable session state.
class SessionState {
  final String? token;
  final String? refreshToken;
  final String? id;
  final String? name;
  final String? email;
  final String? role;

  const SessionState({this.token, this.refreshToken, this.id, this.name, this.email, this.role});

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  SessionState copyWith({
    String? token,
    String? refreshToken,
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return SessionState(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

/// Manages the persistent user session (JWT token, role, user info).
class SessionNotifier extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    return _loadFromPrefs();
  }

  Future<SessionState> _loadFromPrefs() async {
    final isLoggedIn = await SessionService.isLoggedIn();
    if (!isLoggedIn) return const SessionState();

    final user = await SessionService.getUser();
    return SessionState(
      token: user['token'],
      refreshToken: user['refreshToken'],
      id: user['id'],
      name: user['name'],
      email: user['email'],
      role: user['role'],
    );
  }

  /// Save a full session from the backend auth response.
  Future<void> login(Map<String, dynamic> data) async {
    await SessionService.save(data);
    state = AsyncData(SessionState(
      token: data['token'] as String? ?? '',
      refreshToken: data['refreshToken'] as String? ?? '',
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
    ));
  }

  /// Clear session (logout).
  Future<void> logout() async {
    await SessionService.clear();
    state = const AsyncData(SessionState());
  }

  /// Reload session from SharedPreferences.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _loadFromPrefs());
  }
}

/// Main session provider.
final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

/// Derived: whether the user is logged in.
final isLoggedInProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  return session.value?.isLoggedIn ?? false;
});

/// Derived: the user's role.
final userRoleProvider = Provider<String?>((ref) {
  final session = ref.watch(sessionProvider);
  return session.value?.role;
});
