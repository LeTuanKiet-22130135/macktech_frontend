import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom navigation tab index.
class BottomNavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

final bottomNavIndexProvider =
    NotifierProvider<BottomNavIndexNotifier, int>(BottomNavIndexNotifier.new);

/// Whether the floating chat button is visible.
class ChatFabVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool visible) => state = visible;
}

final chatFabVisibleProvider =
    NotifierProvider<ChatFabVisibleNotifier, bool>(ChatFabVisibleNotifier.new);
