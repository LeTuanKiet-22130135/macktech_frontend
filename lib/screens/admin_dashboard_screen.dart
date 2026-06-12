import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedTimeframe = 'Month'; // Day, Month, Year

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Metrics Header
          Row(
            children: [
              Expanded(child: _buildMetricCard("Revenue", "₫42,800", Icons.attach_money, AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard("Orders", "1,204", Icons.shopping_bag_outlined, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard("Products", "342", Icons.inventory_2_outlined, Colors.orange)),
            ],
          ),
          const SizedBox(height: 32),

          // 2. Revenue Chart Header & Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Revenue Analytics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTimeToggle("Day"),
                    _buildTimeToggle("Month"),
                    _buildTimeToggle("Year"),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // 3. FL Chart Box
          Container(
            height: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: _buildRevenueChart(),
          ),

          const SizedBox(height: 32),

          // 4. Previews (Orders and Products)
          const Text(
            "Recent Orders",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentOrderTile("Mark Anthony", "Oct 22, 2026", "₫389,900.00", "Pending"),
          _buildRecentOrderTile("Samantha Green", "Oct 20, 2026", "₫18,900.00", "Delivered"),
          
          const SizedBox(height: 32),
          const Text(
            "Top Selling Products",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240, // Height for horizontal product strip
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildProductTile("Apple iPhone 16 Pro Max", "₫389,900.00"),
                _buildProductTile("Samsung Galaxy Z Fold", "₫189,900.00"),
                _buildProductTile("Spigen Galaxy S23 Case", "₫12,900.00"),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTimeToggle(String title) {
    bool isSelected = _selectedTimeframe == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeframe = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tertiaryNormal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    List<BarChartGroupData> mockData;

    // Simulate different bar layouts based on timeframe interaction
    if (_selectedTimeframe == 'Day') {
      mockData = _generateChartData([2, 5, 4, 8, 6, 9, 3]); // Days of week
    } else if (_selectedTimeframe == 'Month') {
      mockData = _generateChartData([12, 18, 14, 22, 16, 20]); // 6 months preview
    } else {
      mockData = _generateChartData([45, 60, 50, 80, 75]); // 5 years preview
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₫${rod.toY.round()}k',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final text = _getBottomTitle(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Clean look, hide Y axis
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: mockData,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutBack,
    );
  }

  List<BarChartGroupData> _generateChartData(List<double> values) {
    return List.generate(values.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: values[index],
            color: AppColors.tertiaryNormal,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // Slightly rounded tops
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: Colors.grey.shade100,
            ),
          )
        ],
      );
    });
  }

  String _getBottomTitle(int value) {
    if (_selectedTimeframe == 'Day') {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      if (value >= 0 && value < days.length) return days[value];
    } else if (_selectedTimeframe == 'Month') {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
      if (value >= 0 && value < months.length) return months[value];
    } else {
      const years = ['2023', '2024', '2025', '2026', '2027'];
      if (value >= 0 && value < years.length) return years[value];
    }
    return '';
  }

  Widget _buildRecentOrderTile(String name, String date, String price, String status) {
    Color statusColor = status == 'Pending' ? Colors.orange : AppColors.success;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.backgroundLight,
            radius: 20,
            child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductTile(String name, String price) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.phone_iphone, size: 40, color: Colors.grey.shade400),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
