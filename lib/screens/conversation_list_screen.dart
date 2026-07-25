import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_colors.dart';
import '../services/chat_service.dart';
import 'chatbot_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];

  late final ChatFabVisibleNotifier _chatFabVisibleNotifier;

  @override
  void initState() {
    super.initState();
    _chatFabVisibleNotifier = ref.read(chatFabVisibleProvider.notifier);
    Future.microtask(() => _chatFabVisibleNotifier.set(false));
    _loadSessions();
  }

  @override
  void dispose() {
    Future.microtask(() => _chatFabVisibleNotifier.set(true));
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await ChatService.getChatSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return DateFormat.jm().format(date); // e.g., 5:30 PM
      }
      return DateFormat('MMM d').format(date); // e.g., Jun 7
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.messages,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.tertiaryDarker),
            onPressed: _loadSessions,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.tertiaryDarker))
          : ListView(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              children: [
                // Static entry point to start a new chat
                _buildConversationTile(
                  context: context,
                  targetProviderId: 'bot',
                  chatSessionId: null, // Null indicates a new session will be created
                  name: "Macktech Assistant (New Chat)",
                  lastMessage: "Start a new conversation with AI",
                  time: "",
                  icon: Icons.smart_toy,
                ),
                Divider(height: 1),
                
                // Dynamic history from the backend
                if (_sessions.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, top: 16.h, bottom: 8.h),
                    child: Text(AppLocalizations.of(context)!.chatHistory,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ..._sessions.map((s) {
                    final isTicket = s['ticketId'] != null;
                    final displayTime = s['updatedAt'] != null 
                        ? _formatDate(s['updatedAt']) 
                        : _formatDate(s['createdAt']);
                        
                    return Column(
                      children: [
                        _buildConversationTile(
                          context: context,
                          targetProviderId: isTicket ? 'agent' : 'bot',
                          chatSessionId: s['id'] as String,
                          ticketId: isTicket ? s['ticketId']?.toString() : null,
                          name: isTicket ? "Support Ticket #${s['ticketId']}" : "Macktech Assistant",
                          lastMessage: "Session from $displayTime",
                          time: displayTime,
                          icon: isTicket ? Icons.support_agent : Icons.history,
                        ),
                        Divider(height: 1),
                      ],
                    );
                  }),
                ],
                
                // Keep the mock agents for testing UI states
                Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 16.h, bottom: 8.h),
                  child: Text(AppLocalizations.of(context)!.customerSupportMock,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                _buildConversationTile(
                  context: context,
                  targetProviderId: 'agent_1',
                  chatSessionId: null,
                  name: "Sarah Jenkins",
                  lastMessage: "Thank you for your message...",
                  time: "Yesterday",
                  icon: Icons.person,
                ),
                Divider(height: 1),
                _buildConversationTile(
                  context: context,
                  targetProviderId: 'agent_2',
                  chatSessionId: null,
                  name: "Mark Anthony",
                  lastMessage: "Okay, thank you.",
                  time: "Monday",
                  icon: Icons.person,
                ),
              ],
            ),
    );
  }

  Widget _buildConversationTile({
    required BuildContext context,
    required String targetProviderId,
    required String? chatSessionId,
    String? ticketId,
    required String name,
    required String lastMessage,
    required String time,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      leading: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: AppColors.tertiaryNormal,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: AppColors.tertiaryDarker,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 6.h),
        child: Text(
          lastMessage,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatbotScreen(
              activeRole: 'user',
              initialProviderId: targetProviderId,
              chatSessionId: chatSessionId,
              ticketId: ticketId,
            ),
          ),
        );
      },
    );
  }
}
