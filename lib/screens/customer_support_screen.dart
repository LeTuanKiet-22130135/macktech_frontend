import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'raise_ticket_screen.dart';
import 'ticket_detail_screen.dart';
import 'package:app_frontend/theme/app_colors.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'package:intl/intl.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    final tickets = await TicketService.getUserTickets();
    if (mounted) {
      setState(() {
        _tickets = tickets;
        // Sort by newest first
        _tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return AppColors.success;
      case 'in progress':
        return Colors.orange;
      case 'open':
      default:
        return Colors.red;
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
          "Customer Support",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Section title
            Text(
              "Raised ticket history",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiaryDarker,
              ),
            ),
            SizedBox(height: 20.h),

            // Ticket cards
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tickets.isEmpty
                      ? Center(
                          child: Text(
                            "No tickets raised yet.",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _tickets.length,
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            final t = _tickets[index];
                            final dateStr = DateFormat('dd-MM-yyyy').format(t.createdAt);
                            final shortDesc = t.issueDescription.length > 50
                                ? "${t.issueDescription.substring(0, 50)}..."
                                : t.issueDescription;

                            return _buildTicketCard(
                              context: context,
                              ticketNo: t.ticketNumber,
                              date: dateStr,
                              category: t.type,
                              description: shortDesc,
                              ticket: t,
                              status: t.status,
                              statusColor: _getStatusColor(t.status),
                            );
                          },
                        ),
            ),

            // "Raise a new ticket" button
            Padding(
              padding: EdgeInsets.only(bottom: 32.h, top: 16.h),
              child: Center(
                child: SizedBox(
                  width: 240.w,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RaiseTicketScreen(),
                        ),
                      ).then((didSubmit) {
                        if (didSubmit == true) {
                          _fetchTickets();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiaryDarker,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.add, size: 20.sp),
                    label: Text(
                      "Raise a new ticket",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard({
    required BuildContext context,
    required String ticketNo,
    required String date,
    required String category,
    required String description,
    required Ticket ticket,
    required String status,
    required Color statusColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailScreen(
              ticket: ticket,
              statusColor: statusColor,
            ),
          ),
        );
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
            // Ticket number + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ticket no. $ticketNo",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Type / category
            _buildDetailRow("Ticket type /\ncategory", category),
            SizedBox(height: 12.h),

            // Description
            _buildDetailRow("Description", description),
            SizedBox(height: 12.h),

            // Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120.w,
                  child: Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    status,
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
          width: 120.w,
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
