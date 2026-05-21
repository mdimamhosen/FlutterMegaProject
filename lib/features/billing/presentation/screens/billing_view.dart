import 'package:flutter/material.dart';
import '../../../../core/network/database_service.dart';

class BillingView extends StatefulWidget {
  const BillingView({super.key});

  @override
  State<BillingView> createState() => _BillingViewState();
}

class _BillingViewState extends State<BillingView> {
  final _db = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _billingSummary;

  @override
  void initState() {
    super.initState();
    _loadBillingData();
  }

  Future<void> _loadBillingData() async {
    final summary = await _db.getBillingSummary();
    if (mounted) {
      setState(() {
        _billingSummary = summary;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpgrade(String planId) async {
    setState(() => _isLoading = true);
    await _db.upgradePlan(planId);
    await _loadBillingData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully upgraded to ${planId.replaceAll('plan-', '').toUpperCase()}! Stripe subscription active.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = _billingSummary!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    final double ordersPercent = summary['current_month_orders'] / summary['limit_orders'];
    final double staffPercent = summary['current_staff_count'] / summary['limit_staff'];
    final double branchesPercent = summary['current_branches_count'] / summary['limit_branches'];

    return Scaffold(
      body: SingleChildScrollView(
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
                      'SaaS Subscription',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'Outfit',
                            fontSize: 28,
                          ),
                    ),
                    Text(
                      'Manage your Stripe billing plans, trial period, and platform resource limits.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
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
                              'Current Plan: ${summary['plan_name']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Outfit', color: Color(0xFF10B981)),
                            ),
                            Text(
                              summary['subscription_status'].toString().toUpperCase() == 'TRIALING'
                                  ? 'Active 14-day Free Trial'
                                  : 'Stripe Direct Billing Active',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${summary['plan_price'].toInt()}/mo',
                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 32),
                    const Text('Workspace Usage Limits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    _buildUsageBar(
                      title: 'Monthly Food Orders',
                      current: summary['current_month_orders'],
                      limit: summary['limit_orders'],
                      percent: ordersPercent,
                    ),
                    const SizedBox(height: 16),
                    _buildUsageBar(
                      title: 'Staff Member Seats',
                      current: summary['current_staff_count'],
                      limit: summary['limit_staff'],
                      percent: staffPercent,
                    ),
                    const SizedBox(height: 16),
                    _buildUsageBar(
                      title: 'Active Restaurant Branches',
                      current: summary['current_branches_count'],
                      limit: summary['limit_branches'],
                      percent: branchesPercent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Available Plans',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.2 : 0.8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPlanCard(
                  name: 'BASIC',
                  price: '\$29',
                  description: 'Best for single small cafeterias or local food trucks.',
                  features: ['Max 150 orders/month', 'Max 3 staff seats', '1 active branch', 'QR digital menu scanning'],
                  planId: 'plan-basic',
                  currentPlanId: _billingSummary!['plan_name'] == 'Basic Plan',
                ),
                _buildPlanCard(
                  name: 'PRO',
                  price: '\$79',
                  description: 'Best for thriving dining bistros and multi-table places.',
                  features: ['Max 1000 orders/month', 'Max 15 staff seats', 'Up to 5 branches', 'Stripe customer payments', 'Realtime Kitchen queue'],
                  planId: 'plan-pro',
                  currentPlanId: _billingSummary!['plan_name'] == 'Pro Plan',
                  isPopular: true,
                ),
                _buildPlanCard(
                  name: 'ENTERPRISE',
                  price: '\$199',
                  description: 'Best for multi-branch chains and massive operations.',
                  features: ['Unlimited orders', 'Unlimited staff seats', 'Unlimited branches', 'Platform Super Admin tools', '24/7 Priority support'],
                  planId: 'plan-enterprise',
                  currentPlanId: _billingSummary!['plan_name'] == 'Enterprise Plan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageBar({required String title, required int current, required int limit, required double percent}) {
    final double safePercent = percent.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            Text('$current / ${limit >= 999999 ? 'Unlimited' : limit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: safePercent,
            minHeight: 8,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(safePercent > 0.85 ? Colors.red : const Color(0xFF10B981)),
          ),
        )
      ],
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required String description,
    required List<String> features,
    required String planId,
    required bool currentPlanId,
    bool isPopular = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPopular ? const Color(0xFF10B981) : (isDark ? Colors.white10 : Colors.black12),
          width: isPopular ? 2.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                const Text('/month', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const Divider(height: 24),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: features.length,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Color(0xFF10B981), size: 14),
                        const SizedBox(width: 8),
                        Expanded(child: Text(features[idx], style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: currentPlanId ? Colors.grey : (isPopular ? const Color(0xFF10B981) : Theme.of(context).colorScheme.secondary),
                foregroundColor: Colors.white,
              ),
              onPressed: currentPlanId ? null : () => _handleUpgrade(planId),
              child: Text(currentPlanId ? 'Active Plan' : 'Select Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
