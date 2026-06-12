import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'chatbot_screen.dart';

class AgentConversationListScreen extends StatelessWidget {
  const AgentConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // The parent layout has a drawer and appbar already... wait.
        // Actually, this is rendered inside an IndexedStack whose parent Scaffold already has the AppBar.
        // I don't need a nested AppBar if it's in the main layout tab. Let's return just the body.
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Customer Messages",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.tertiaryDarker,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildConversationTile(
            context: context,
            targetProviderId: 'ticket_00001',
            name: "Mark Anthony",
            ticketId: "00001",
            lastMessage: "I recently purchased a phone from your store...",
            time: "09:50",
            icon: Icons.person,
          ),
          const Divider(height: 1),
          _buildConversationTile(
            context: context,
            targetProviderId: 'ticket_00002',
            name: "Sarah Jenkins",
            ticketId: "00002",
            lastMessage: "Okay, thank you.",
            time: "Yesterday",
            icon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile({
    required BuildContext context,
    required String targetProviderId,
    required String name,
    required String ticketId,
    required String lastMessage,
    required String time,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.amber.shade700,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.tertiaryDarker,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          lastMessage,
          style: TextStyle(
            fontSize: 14,
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
              activeRole: 'agent',
              ticketId: ticketId,
              targetName: name,
            ),
          ),
        );
      },
    );
  }
}
