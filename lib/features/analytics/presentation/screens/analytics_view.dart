import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/network/database_service.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final _db = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _db.getAnalyticsData();
    if (mounted) {
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _analyticsData!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Overview',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Outfit',
                          fontSize: 28,
                        ),
                  ),
                  Text(
                    'Monitor your restaurant performance across all active branches.',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(140, 46),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating PDF Report...')),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text('Export PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // --- KPI Cards Grid ---
          GridView.count(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 2.5 : 1.7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildKpiCard(
                context: context,
                title: 'Total Revenue',
                value: '\$${(data['total_revenue'] as double).toStringAsFixed(2)}',
                subtitle: '+12.4% from last week',
                icon: Icons.attach_money_rounded,
                color: const Color(0xFF10B981),
              ),
              _buildKpiCard(
                context: context,
                title: 'Active Orders',
                value: '${data['total_orders']}',
                subtitle: 'Live kitchen ticket volume',
                icon: Icons.shopping_bag_outlined,
                color: Colors.blue,
              ),
              _buildKpiCard(
                context: context,
                title: 'Average Ticket',
                value: '\$${(data['average_order_value'] as double).toStringAsFixed(2)}',
                subtitle: 'High ticket customer value',
                icon: Icons.analytics_outlined,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Charts Grid ---
          if (isMobile) ...[
            _buildRevenueChart(data, isDark),
            const SizedBox(height: 24),
            _buildTopSellingCard(data, isDark),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _buildRevenueChart(data, isDark)),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: _buildTopSellingCard(data, isDark)),
              ],
            ),
          const SizedBox(height: 24),

          // --- Branch Performance List ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Branch Performance',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (data['branch_performance'] as List).length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, idx) {
                      final b = data['branch_performance'][idx];
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.storefront_rounded, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b['branch_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('${b['orders']} completed orders', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$${(b['revenue'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981))),
                              const Text('Contribution 70%', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          )
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 1200 ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, dynamic> data, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Trends (Hourly Distribution)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (val, meta) {
                          int hour = val.toInt();
                          if (hour == 11) return const Text('11 AM');
                          if (hour == 14) return const Text('2 PM');
                          if (hour == 17) return const Text('5 PM');
                          if (hour == 20) return const Text('8 PM');
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(11, 45.0),
                        const FlSpot(12, 120.0),
                        const FlSpot(14, 90.0),
                        const FlSpot(17, 180.0),
                        const FlSpot(20, 240.0),
                        const FlSpot(22, 95.0),
                      ],
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingCard(Map<String, dynamic> data, bool isDark) {
    final topFoods = data['top_foods'] as List;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Food Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 36,
                  sections: [
                    PieChartSectionData(color: const Color(0xFF10B981), value: 40, title: 'Wagyu', radius: 24, showTitle: false),
                    PieChartSectionData(color: Colors.blue, value: 30, title: 'Mojito', radius: 24, showTitle: false),
                    PieChartSectionData(color: Colors.purple, value: 20, title: 'Fries', radius: 24, showTitle: false),
                    PieChartSectionData(color: Colors.orange, value: 10, title: 'Lava', radius: 24, showTitle: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Column(
              children: topFoods.map((food) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(food['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        ],
                      ),
                      Text('${food['quantity']} sold', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
