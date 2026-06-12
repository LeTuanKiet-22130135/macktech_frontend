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
        title: const Text(
          "Customer Support",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.tertiaryDarker,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Section title
            const Text(
              "Raised ticket history",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.tertiaryDarker,
              ),
            ),
            const SizedBox(height: 20),

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
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
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
              padding: const EdgeInsets.only(bottom: 32, top: 16),
              child: Center(
                child: SizedBox(
                  width: 240,
                  height: 52,
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      "Raise a new ticket",
                      style: TextStyle(
                        fontSize: 16,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.tertiaryDarker,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Type / category
            _buildDetailRow("Ticket type /\ncategory", category),
            const SizedBox(height: 12),

            // Description
            _buildDetailRow("Description", description),
            const SizedBox(height: 12),

            // Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
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
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.tertiaryDarker,
            ),
          ),
        ),
      ],
    );
  }
}
