import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information header
                  Text(
                    "Customer Information",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Customer Name
                  _buildFieldLabel("Customer Name"),
                  const SizedBox(height: 4),
                  _buildFieldValue(_customerName),
                  SizedBox(height: 16.h),

                  // Email Address
                  _buildFieldLabel("Email Address"),
                  const SizedBox(height: 4),
                  _buildFieldValue(_email),
                  SizedBox(height: 24.h),

                  // Ticket Type / Category
                  Text(
                    "Ticket Type / Category",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildFieldValue(widget.ticket.type),
                  SizedBox(height: 24.h),

                  // Issue
                  Text(
                    "Issue",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tertiaryDarker,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.ticket.issueDescription,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey.shade500,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Attachments
                  if (widget.ticket.attachments.isNotEmpty) ...[
                    Text(
                      "Attachments",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tertiaryDarker,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...widget.ticket.attachments.map(
                      (attachment) => Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade200),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.r),
                                color: Colors.grey.shade300,
                                image: DecorationImage(
                                  image: NetworkImage(attachment.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                "Image attached",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Status row
                  Row(
                    children: [
                      Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiaryDarker,
                        ),
                      ),
                      SizedBox(width: 24.w),
                      Text(
                        widget.ticket.status,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.statusColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
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
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.tertiaryDarker,
      ),
    );
  }

  Widget _buildFieldValue(String value) {
    return Text(
      value,
      style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade500),
    );
  }
}
