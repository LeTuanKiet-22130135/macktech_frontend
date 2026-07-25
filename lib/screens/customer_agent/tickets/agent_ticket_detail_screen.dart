import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/ticket.dart';
import '../../../services/ticket_service.dart';
import '../../user/support/chatbot_screen.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AgentTicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  final Color statusColor;

  const AgentTicketDetailScreen({
    super.key,
    required this.ticket,
    required this.statusColor,
  });

  @override
  State<AgentTicketDetailScreen> createState() => _AgentTicketDetailScreenState();
}

class _AgentTicketDetailScreenState extends State<AgentTicketDetailScreen> {
  late String _currentStatus;
  bool _isUpdating = false;

  final List<String> _statuses = [
    "Open",
    "Pending",
    "Closed",
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ticket.status;
    if (!_statuses.contains(_currentStatus)) {
      _statuses.add(_currentStatus);
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
        title: Text(
          "Ticket no.${widget.ticket.ticketNumber.substring(widget.ticket.ticketNumber.length - 4)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.customerInformation,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiaryDarker,
              ),
            ),
            SizedBox(height: 16.h),
            _buildFieldLabel("Customer Name"),
            SizedBox(height: 4),
            _buildFieldValue("Unknown"), // No customer data in basic Ticket model
            SizedBox(height: 16.h),
            _buildFieldLabel("Email Address"),
            SizedBox(height: 4),
            _buildFieldValue("Unknown"), // No customer data in basic Ticket model
            SizedBox(height: 24.h),
            Text(AppLocalizations.of(context)!.ticketTypeCategory,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiaryDarker,
              ),
            ),
            SizedBox(height: 8.h),
            _buildFieldValue(widget.ticket.type),
            SizedBox(height: 24.h),
            Text(AppLocalizations.of(context)!.issue,
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
            Text(AppLocalizations.of(context)!.updateStatus,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiaryDarker,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: _isUpdating
                  ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currentStatus,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                        items: _statuses.map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, style: TextStyle(fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (val) async {
                          if (val != null && val != _currentStatus) {
                            setState(() => _isUpdating = true);
                            try {
                              final updatedTicket = await TicketService.updateTicketStatus(widget.ticket.id, val);
                              if (updatedTicket != null && mounted) {
                                setState(() => _currentStatus = val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Status updated to $_currentStatus')),
                                );
                              } else {
                                throw Exception("Failed to update status");
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.errorUpdatingStatus)),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isUpdating = false);
                              }
                            }
                          }
                        },
                      ),
                    ),
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatbotScreen(
                ticketId: widget.ticket.id,
                activeRole: 'agent', // Agent enters chat as agent
                targetName: 'Customer', // No customer name available in model
              ),
            ),
          );
        },
        backgroundColor: AppColors.tertiaryDarkHover,
        icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: Text(AppLocalizations.of(context)!.chatWithCustomer,
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
      style: TextStyle(
        fontSize: 15.sp,
        color: Colors.grey.shade500,
      ),
    );
  }
}
