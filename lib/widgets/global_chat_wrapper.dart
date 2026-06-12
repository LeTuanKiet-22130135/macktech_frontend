import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';

import '../screens/conversation_list_screen.dart';
import '../main.dart';
import '../theme/app_colors.dart';

/// Whether the floating chat button is visible — now managed by chatFabVisibleProvider.
/// This file no longer exports isChatFabVisible ValueNotifier.

class GlobalChatWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalChatWrapper({super.key, required this.child});

  @override
  ConsumerState<GlobalChatWrapper> createState() => _GlobalChatWrapperState();
}

class _GlobalChatWrapperState extends ConsumerState<GlobalChatWrapper> {
  // FAB position — null means use default position (bottom-right).
  double? _fabX;
  double? _fabY;
  bool _isDragging = false;

  static const double _fabSize = 56;

  @override
  Widget build(BuildContext context) {
    final visible = ref.watch(chatFabVisibleProvider);
    if (!visible) return widget.child;

    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Default position: bottom-right
    final effectiveX = _fabX ?? (screenSize.width - _fabSize - 16);
    final effectiveY = _fabY ?? (screenSize.height - _fabSize - 90 - padding.bottom);

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: effectiveX,
          top: effectiveY,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onPanStart: (_) {
                  _isDragging = false;
                },
                onPanUpdate: (details) {
                  _isDragging = true;
                  setState(() {
                    final newX = ((_fabX ?? effectiveX) + details.delta.dx)
                        .clamp(0.0, screenSize.width - _fabSize);
                    final newY = ((_fabY ?? effectiveY) + details.delta.dy)
                        .clamp(padding.top, screenSize.height - _fabSize - padding.bottom);
                    _fabX = newX;
                    _fabY = newY;
                  });
                },
                onPanEnd: (_) {
                  // If user barely moved, treat it as a tap
                  if (!_isDragging) {
                    _openChat();
                  }
                },
                onTap: _openChat,
                child: Container(
                  width: _fabSize,
                  height: _fabSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.tertiaryNormal,
                        AppColors.tertiaryDarker
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.tertiaryNormal.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openChat() {
    appNavigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const ConversationListScreen()),
    );
  }
}
