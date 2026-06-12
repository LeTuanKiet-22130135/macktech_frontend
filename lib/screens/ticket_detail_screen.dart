import 'package:flutter/material.dart';
import 'package:app_frontend/theme/app_colors.dart';
import 'chatbot_screen.dart';

/// Ticket detail screen matching design 082.
/// Shows full ticket information: customer info, ticket type,
/// issue description, uploaded image, preferred contact method,
/// number, and status.
import '../models/ticket.dart';
import '../services/session_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  final Color statusColor;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
    required this.statusColor,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  String _customerName = "";
  String _email = "";
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getUser();
    if (mounted) {
      setState(() {
        _customerName = user['name'] ?? "";
        _email = user['email'] ?? "";
        _isLoadingUser = false;
      });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ticket no.${widget.ticket.ticketNumber}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information header
                  const Text(
                    "Customer Information",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Customer Name
                  _buildFieldLabel("Customer Name"),
                  const SizedBox(height: 4),
                  _buildFieldValue(_customerName),
                  const SizedBox(height: 16),

                  // Email Address
                  _buildFieldLabel("Email Address"),
                  const SizedBox(height: 4),
                  _buildFieldValue(_email),
                  const SizedBox(height: 24),

                  // Ticket Type / Category
                  const Text(
                    "Ticket Type / Category",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldValue(widget.ticket.type),
                  const SizedBox(height: 24),

                  // Issue
                  const Text(
                    "Issue",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ticket.issueDescription,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Attachments
                  if (widget.ticket.attachments.isNotEmpty) ...[
                    const Text(
                      "Attachments",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiaryDarker,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.ticket.attachments.map(
                      (attachment) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey.shade300,
                                image: DecorationImage(
                                  image: NetworkImage(attachment.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Image attached",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Status row
                  Row(
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiaryDarker,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        widget.ticket.status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatbotScreen(
                ticketId: widget.ticket.id,
                activeRole: 'user', // Customer enters chat as user
              ),
            ),
          );
        },
        backgroundColor: AppColors.tertiaryDarkHover,
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          "Chat with Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.tertiaryDarker,
      ),
    );
  }

  Widget _buildFieldValue(String value) {
    return Text(
      value,
      style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
    );
  }
}
