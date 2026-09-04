import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../services/chat_service.dart';
import '../../../services/stomp_chat_service.dart';
import '../../../services/session_service.dart';
import '../../../providers/navigation_provider.dart';
import '../../../theme/app_colors.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  final String? ticketId;
  final String activeRole; // 'user' or 'agent'
  final String? targetName;
  final String initialProviderId;
  final String? chatSessionId;

  const ChatbotScreen({
    super.key,
    this.ticketId,
    this.activeRole = 'user',
    this.targetName,
    this.initialProviderId = 'bot',
    this.chatSessionId,
  });

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  late String _activeProviderId;
  bool _isBotTyping = false;
  bool _isLoadingHistory = false;
  StreamSubscription<String>? _streamSubscription;

  // STOMP Live Chat
  StompChatService? _stompService;
  StreamSubscription<Map<String, dynamic>>? _stompSubscription;
  String? _currentUserId;

  /// Whether this screen is in live human-to-human chat mode.
  bool get _isLiveChatMode => widget.ticketId != null;

  late final ChatFabVisibleNotifier _chatFabVisibleNotifier;

  @override
  void initState() {
    super.initState();
    // Save notifier so we can use it safely in dispose()
    _chatFabVisibleNotifier = ref.read(chatFabVisibleProvider.notifier);
    
    // Hide global FAB when in chat screen
    Future.microtask(() => _chatFabVisibleNotifier.set(false));
    _activeProviderId = widget.initialProviderId;
    _initializeChat();
  }

  String _formatTime(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat.jm().format(date);
    } catch (_) {
      return '';
    }
  }

  Future<void> _initializeChat() async {
    if (_isLiveChatMode) {
      // ── Live Chat Mode (Agent ↔ Customer via STOMP) ──
      await _initializeLiveChat();
    } else if (widget.chatSessionId != null) {
      // ── Historical AI Bot Chat Session ──
      setState(() => _isLoadingHistory = true);
      final history = await ChatService.getSessionMessages(
        widget.chatSessionId!,
      );
      if (mounted) {
        setState(() {
          _messages.clear();
          for (var msg in history) {
            _messages.add({
              'text': msg['textPayload'] ?? '',
              'senderType': msg['senderType'] ?? 'bot',
              'time': _formatTime(msg['createdAt'] as String?),
            });
          }
          _isLoadingHistory = false;
        });
        _scrollToBottom();
      }
    } else {
      // ── New AI Bot Chat ──
      _messages.addAll([
        {
          'text':
              'Hi there! 👋 I\'m Macktech Assistant. How can I help you today?',
          'senderType': 'bot',
          'time': '09:00',
        },
        {
          'text':
              'You can ask me about:\n• Product recommendations\n• Order tracking\n• Return & refund policies\n• Technical specifications',
          'senderType': 'bot',
          'time': '09:00',
        },
      ]);
    }
  }

  /// Initialize a live chat session:
  /// 1. Load existing message history using ticketId as sessionId.
  /// 2. Connect STOMP and subscribe to real-time messages.
  Future<void> _initializeLiveChat() async {
    setState(() => _isLoadingHistory = true);

    // Get current user ID for filtering echo messages
    final user = await SessionService.getUser();
    _currentUserId = user['id'];

    // Load existing chat history using ticketId as sessionId
    final history = await ChatService.getSessionMessages(widget.ticketId!);
    if (mounted) {
      setState(() {
        _messages.clear();
        for (var msg in history) {
          _messages.add({
            'text': msg['textPayload'] ?? '',
            'senderType': msg['senderType'] ?? 'user',
            'time': _formatTime(msg['createdAt'] as String?),
          });
        }
        _isLoadingHistory = false;
      });
      _scrollToBottom();
    }

    // Connect STOMP
    _stompService = StompChatService(
      sessionId: widget.ticketId!,
      senderType: widget.activeRole,
      senderId: _currentUserId ?? '',
    );

    _stompSubscription = _stompService!.messages.listen((data) {
      if (!mounted) return;

      // Skip messages sent by ourselves (the server echoes them back)
      final incomingSenderId = data['senderId'] as String?;
      if (incomingSenderId == _currentUserId) return;

      setState(() {
        _messages.add({
          'text': data['textPayload'] ?? '',
          'senderType': data['senderType'] ?? 'user',
          'time': _formatTime(data['createdAt'] as String?),
        });
      });
      _scrollToBottom();
    });

    await _stompService!.connect();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isBotTyping) return;

    setState(() {
      _messages.add({
        'text': text,
        'senderType': widget.activeRole,
        'time': TimeOfDay.now().format(context),
      });
    });
    _messageController.clear();
    _scrollToBottom();

    if (_isLiveChatMode) {
      // ── Live Chat: send via STOMP ──
      _stompService?.sendMessage(text);
    } else {
      // ── AI Bot Chat: stream response via SSE ──
      if (_activeProviderId == 'bot') {
        _streamBotResponse(text);
      }
    }
  }

  /// Stream the AI chatbot response from the backend SSE endpoint.
  void _streamBotResponse(String userMessage) {
    setState(() => _isBotTyping = true);

    // Add a placeholder bot message that we'll fill in as chunks arrive
    final botMessageIndex = _messages.length;
    _messages.add({
      'text': '',
      'senderType': 'bot',
      'time': TimeOfDay.now().format(context),
      'isStreaming': true,
    });
    _scrollToBottom();

    _streamSubscription?.cancel();
    _streamSubscription = ChatService.streamChat(userMessage).listen(
      (chunk) {
        if (!mounted) return;

        setState(() {
          _messages[botMessageIndex]['text'] =
              (_messages[botMessageIndex]['text'] as String) + chunk;
        });
        _scrollToBottom();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          if ((_messages[botMessageIndex]['text'] as String).isEmpty) {
            _messages[botMessageIndex]['text'] =
                'Sorry, I couldn\'t process your request. Please try again later.';
          }
          _messages[botMessageIndex]['isStreaming'] = false;
          _isBotTyping = false;
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _messages[botMessageIndex]['isStreaming'] = false;
          _isBotTyping = false;
        });
        _scrollToBottom();
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    Future.microtask(() => _chatFabVisibleNotifier.set(true));
    _streamSubscription?.cancel();
    _stompSubscription?.cancel();
    _stompService?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Determine chat header properties
  String get _headerTitle {
    if (widget.activeRole == 'agent') {
      return widget.targetName ?? "Customer";
    }
    if (_activeProviderId == 'agent_1') return "Sarah Jenkins";
    if (_activeProviderId == 'agent_2') return "Mark Anthony";
    return "Macktech Assistant";
  }

  String get _headerSubtitle {
    if (widget.activeRole == 'agent') {
      return "Ticket: ${widget.ticketId}";
    }
    return "Online";
  }

  IconData get _headerIcon {
    if (widget.activeRole == 'agent' || _activeProviderId != 'bot') {
      return Icons.person; // Human
    }
    return Icons.smart_toy_outlined; // Bot
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.tertiaryDarker,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_headerIcon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _headerTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _isBotTyping ? 'Typing...' : _headerSubtitle,
                    style: TextStyle(
                      color: _isBotTyping
                          ? Colors.white70
                          : (widget.activeRole == 'agent'
                                ? Colors.white70
                                : Colors.greenAccent),
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingHistory
          ? Center(
              child: CircularProgressIndicator(color: AppColors.tertiaryDarker),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(
                        text: msg['text'] as String,
                        senderType: msg['senderType'] as String,
                        senderName: msg['senderName'] as String?,
                        time: msg['time'] as String,
                        isStreaming: msg['isStreaming'] == true,
                      );
                    },
                  ),
                ),
                _buildInputBar(),
              ],
            ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required String senderType,
    String? senderName,
    required String time,
    bool isStreaming = false,
  }) {
    final bool isMe = senderType == widget.activeRole;
    final bool isBot = senderType == 'bot';

    Color bubbleColor;
    Color textColor;

    if (isMe) {
      bubbleColor = AppColors.tertiaryDarker;
      textColor = Colors.white;
    } else {
      bubbleColor = Colors.white;
      textColor = AppColors.textPrimary;
    }

    if (senderType == 'system') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isMe ? 48 : 0,
          right: isMe ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe && senderName != null) ...[
              Padding(
                padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBot ? Icons.smart_toy : Icons.person,
                      size: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      senderName,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: text.isEmpty && isStreaming
                  ? _buildTypingIndicator()
                  : (isBot
                      ? MarkdownBody(
                          data: text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              fontSize: 14.sp,
                              color: textColor,
                              height: 1.4,
                            ),
                            listBullet: TextStyle(
                              color: textColor,
                            ),
                          ),
                        )
                      : Text(
                          text,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: textColor,
                            height: 1.4,
                          ),
                        )),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
                ),
                if (isStreaming) ...[
                  SizedBox(width: 6.w),
                  SizedBox(
                    width: 10.w,
                    height: 10.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Animated typing indicator (three bouncing dots)
  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + i * 200),
          builder: (context, value, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Opacity(
                opacity: 0.3 + 0.7 * ((value + i * 0.3) % 1.0),
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.typeAMessage,
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46.w,
                height: 46.h,
                decoration: BoxDecoration(
                  color: _isBotTyping ? Colors.grey : AppColors.tertiaryDarker,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
