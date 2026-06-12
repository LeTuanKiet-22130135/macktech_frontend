import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AdminOrderListScreen extends StatelessWidget {
  const AdminOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Orders",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 4, // Simulated static data
              itemBuilder: (context, index) {
                return _buildOrderCard(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, int index) {
    final Map<String, dynamic> sampleCustomer = [
      {
        "name": "Alex Taylor",
        "email": "alex.taylor@example.com",
        "total": "₫199,900.00",
        "status": "Pending",
        "productCount": 2,
        "date": "Oct 24, 2026",
      },
      {
        "name": "Mark Anthony",
        "email": "markanthony@gmail.com",
        "total": "₫389,900.00",
        "status": "Shipped",
        "productCount": 1,
        "date": "Oct 22, 2026",
      },
      {
        "name": "Samantha Green",
        "email": "sam.green@mail.co",
        "total": "₫18,900.00",
        "status": "Delivered",
        "productCount": 1,
        "date": "Oct 20, 2026",
      },
      {
        "name": "Alex Taylor",
        "email": "alex.taylor@example.com",
        "total": "₫14,900.00",
        "status": "Cancelled",
        "productCount": 1,
        "date": "Oct 19, 2026",
      },
    ][index];

    Color statusColor;
    if (sampleCustomer['status'] == 'Pending') {
      statusColor = Colors.orange;
    } else if (sampleCustomer['status'] == 'Shipped') {
      statusColor = Colors.blue;
    } else if (sampleCustomer['status'] == 'Delivered') {
      statusColor = AppColors.success;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Email
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.backgroundLight,
                child: Text(
                  sampleCustomer['name'][0],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampleCustomer['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      sampleCustomer['email'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sampleCustomer['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: AppColors.borderGrey, height: 1),
          ),
          // Order summary details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Date",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sampleCustomer['date'],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Items: ${sampleCustomer['productCount']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sampleCustomer['total'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
