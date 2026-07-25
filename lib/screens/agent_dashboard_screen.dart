import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'agent_ticket_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:app_frontend/l10n/app_localizations.dart';

class AgentDashboardScreen extends ConsumerStatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  ConsumerState<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends ConsumerState<AgentDashboardScreen> {
  bool _isLoading = true;
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final tickets = await TicketService.getAllTickets();
      if (mounted) {
        setState(() {
          _tickets = tickets;
        });
      }
    } catch (e) {
      debugPrint("Error fetching tickets: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Closed':
        return Colors.grey;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _tickets.isEmpty
              ? Center(
                  child: Text(AppLocalizations.of(context)!.noTicketsAssignedYet,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Text(AppLocalizations.of(context)!.allTickets,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiaryDarker,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _fetchTickets,
                          child: ListView.separated(
                            itemCount: _tickets.length,
                            separatorBuilder: (_, _) => SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final ticket = _tickets[index];
                              return _buildAgentTicketCard(
                                context: context,
                                ticket: ticket,
                                onRefresh: _fetchTickets,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAgentTicketCard({
    required BuildContext context,
    required Ticket ticket,
    required VoidCallback onRefresh,
  }) {
    final statusColor = _getStatusColor(ticket.status);
    final dateStr = DateFormat('dd-MM-yyyy').format(ticket.createdAt);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AgentTicketDetailScreen(
              ticket: ticket,
              statusColor: statusColor,
            ),
          ),
        );
        if (result == true) {
          onRefresh();
        }
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ticket no. ${ticket.ticketNumber.substring(ticket.ticketNumber.length - 4)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _buildDetailRow("Type", ticket.type),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100.w,
                  child: Text(AppLocalizations.of(context)!.status,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    ticket.status,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.tertiaryDarker,
            ),
          ),
        ),
      ],
    );
  }
}
