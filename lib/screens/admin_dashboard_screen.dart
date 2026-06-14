import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../services/admin_dashboard_service.dart';
import '../services/order_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedTimeframe = 'Day'; // Day, Month, Year
  
  bool _isLoadingMetrics = true;
  bool _isLoadingChart = true;
  bool _isLoadingOrders = true;
  bool _isLoadingProducts = true;

  Map<String, dynamic>? _metrics;
  Map<String, dynamic>? _chartData;
  List<dynamic> _recentOrders = [];
  List<dynamic> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    _fetchMetrics();
    _fetchChartData();
    _fetchRecentOrders();
    _fetchTopProducts();
  }

  Future<void> _fetchMetrics() async {
    setState(() => _isLoadingMetrics = true);
    final data = await AdminDashboardService.getKeyMetrics();
    if (mounted) {
      setState(() {
        _metrics = data;
        _isLoadingMetrics = false;
      });
    }
  }

  Future<void> _fetchChartData() async {
    setState(() => _isLoadingChart = true);
    final data = await AdminDashboardService.getRevenueChartData(_selectedTimeframe);
    if (mounted) {
      setState(() {
        _chartData = data;
        _isLoadingChart = false;
      });
    }
  }

  Future<void> _fetchRecentOrders() async {
    setState(() => _isLoadingOrders = true);
    final orders = await OrderService.getAllOrdersAdmin();
    if (mounted) {
      setState(() {
        // Sort descending and take top 5
        orders.sort((a, b) {
          final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        _recentOrders = orders.take(5).toList();
        _isLoadingOrders = false;
      });
    }
  }

  Future<void> _fetchTopProducts() async {
    setState(() => _isLoadingProducts = true);
    final products = await AdminDashboardService.getTopSellingProducts(limit: 5);
    if (mounted) {
      setState(() {
        _topProducts = products;
        _isLoadingProducts = false;
      });
    }
  }

  void _onTimeframeChanged(String timeframe) {
    if (_selectedTimeframe != timeframe) {
      setState(() {
        _selectedTimeframe = timeframe;
      });
      _fetchChartData();
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Metrics Header
          _isLoadingMetrics
              ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
              : Row(
                  children: [
                    Expanded(
                        child: _buildMetricCard(
                            "Revenue",
                            "₫${((_metrics?['totalRevenue'] as num?) ?? 0).toStringAsFixed(0)}",
                            Icons.attach_money,
                            AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildMetricCard(
                            "Orders",
                            "${_metrics?['totalOrders'] ?? 0}",
                            Icons.shopping_bag_outlined,
                            Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildMetricCard(
                            "Products",
                            "${_metrics?['totalProducts'] ?? 0}",
                            Icons.inventory_2_outlined,
                            Colors.orange)),
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
                ]),
            child: _isLoadingChart
                ? const Center(child: CircularProgressIndicator())
                : _chartData == null || (_chartData!['data'] as List).isEmpty
                    ? const Center(child: Text("No chart data available."))
                    : _buildRevenueChart(),
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
          _isLoadingOrders
              ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
              : _recentOrders.isEmpty
                  ? const Center(child: Text("No recent orders."))
                  : Column(
                      children: _recentOrders.map((order) {
                        final userName = order['user']?['name'] ?? order['shippingName'] ?? 'Unknown';
                        final date = _formatDate(order['createdAt'] ?? '');
                        final total = order['total'] ?? 0.0;
                        final status = order['status'] ?? 'Pending';
                        return _buildRecentOrderTile(
                            userName, date, "₫${total.toStringAsFixed(0)}", status);
                      }).toList(),
                    ),

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
          _isLoadingProducts
              ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
              : _topProducts.isEmpty
                  ? const Center(child: Text("No top products."))
                  : SizedBox(
                      height: 240, // Height for horizontal product strip
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _topProducts.map((p) {
                          final title = p['title'] ?? 'Unknown';
                          final price = p['price'] ?? 0.0;
                          final image = p['imageUrl'];
                          return _buildProductTile(title, "₫${price.toStringAsFixed(0)}", image);
                        }).toList(),
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
      onTap: () => _onTimeframeChanged(title),
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
          ]),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final labels = _chartData!['labels'] as List<dynamic>? ?? [];
    final dataValues = _chartData!['data'] as List<dynamic>? ?? [];

    double maxY = 100;
    for (var val in dataValues) {
      final numValue = (val as num).toDouble();
      if (numValue > maxY) {
        maxY = numValue + (numValue * 0.2); // Add 20% headroom
      }
    }

    final mockData = List.generate(dataValues.length, (index) {
      final val = (dataValues[index] as num).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: val,
            color: AppColors.tertiaryNormal,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: Colors.grey.shade100,
            ),
          )
        ],
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₫${rod.toY.round()}',
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
                final idx = value.toInt();
                final text = (idx >= 0 && idx < labels.length) ? labels[idx].toString() : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Clean look, hide Y axis
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 25,
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

  Widget _buildRecentOrderTile(String name, String date, String price, String status) {
    Color statusColor = status == 'Pending' ? Colors.orange : (status == 'Shipped' ? Colors.blue : (status == 'Cancelled' ? Colors.red : AppColors.success));
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
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

  Widget _buildProductTile(String name, String price, String? imageUrl) {
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
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (c,e,s) => Icon(Icons.phone_iphone, size: 40, color: Colors.grey.shade400)),
                      )
                    : Icon(Icons.phone_iphone, size: 40, color: Colors.grey.shade400),
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
