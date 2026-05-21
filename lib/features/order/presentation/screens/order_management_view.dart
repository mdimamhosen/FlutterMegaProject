import 'package:flutter/material.dart';
import '../../../../core/network/database_service.dart';
import 'package:intl/intl.dart';

class OrderManagementView extends StatefulWidget {
  const OrderManagementView({super.key});

  @override
  State<OrderManagementView> createState() => _OrderManagementViewState();
}

class _OrderManagementViewState extends State<OrderManagementView> with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late TabController _tabController;
  List<Map<String, dynamic>> _allOrders = [];
  bool _newOrderAlert = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Bind to database realtime order stream!
    _db.ordersStream.listen((orders) {
      if (mounted) {
        // Detect if a new pending order arrived to show notification flash!
        final hadNewPending = _allOrders.length < orders.length &&
            orders.any((o) => o['status'] == 'pending' && !_allOrders.any((x) => x['id'] == o['id']));

        setState(() {
          _allOrders = orders;
          if (hadNewPending) {
            _newOrderAlert = true;
          }
        });

        if (hadNewPending) {
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) setState(() => _newOrderAlert = false);
          });
        }
      }
    });

    // Populate initial orders
    _loadInitialOrders();
  }

  void _loadInitialOrders() async {
    // DatabaseService initializes with dummy data, we pull it synchronously
    await _db.getBillingSummary(); // just a trigger
    setState(() {
      // Pull direct orders from db through stream trigger
      _allOrders = [];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    final pendingOrders = _allOrders.where((o) => o['status'] == 'pending').toList();
    final preparingOrders = _allOrders.where((o) => o['status'] == 'preparing').toList();
    final completedOrders = _allOrders.where((o) => o['status'] == 'completed' || o['status'] == 'served').toList();

    return Column(
      children: [
        // --- Realtime Toast Warning Banner on New Order ---
        if (_newOrderAlert)
          Container(
            width: double.infinity,
            color: Colors.amber[700],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.ring_volume_rounded, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'NEW TICKET RECEIVED! Dynamic refresh updated kitchen queue.',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => setState(() => _newOrderAlert = false),
                )
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kitchen & Waiter Queue',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Outfit',
                          fontSize: 28,
                        ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Dashboard Connected',
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'Pending (${pendingOrders.length})'),
                  Tab(text: 'Preparing (${preparingOrders.length})'),
                  Tab(text: 'Completed (${completedOrders.length})'),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrderColumn(pendingOrders, 'pending', isDark, isMobile),
              _buildOrderColumn(preparingOrders, 'preparing', isDark, isMobile),
              _buildOrderColumn(completedOrders, 'completed', isDark, isMobile),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildOrderColumn(List<Map<String, dynamic>> orders, String colType, bool isDark, bool isMobile) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('No orders in this queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Enjoy the downtime chef!', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 13)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemCount: orders.length,
      itemBuilder: (context, idx) {
        final order = orders[idx];
        return _buildOrderCard(order, isDark);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark) {
    final itemsList = order['items'] as List;
    final dt = DateTime.parse(order['created_at']);
    final timeStr = DateFormat('hh:mm a').format(dt);

    Color badgeColor;
    if (order['status'] == 'pending') {
      badgeColor = Colors.amber;
    } else if (order['status'] == 'preparing') {
      badgeColor = Colors.blue;
    } else {
      badgeColor = const Color(0xFF10B981);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Table ${order['table_number']}',
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                Text(
                  timeStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: #${order['id']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: itemsList.length,
                itemBuilder: (context, i) {
                  final item = itemsList[i];
                  final addons = item['addons'] as List?;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['quantity']}x ${item['name']}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            '\$${((item['price'] as double) * (item['quantity'] as int)).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13),
                          )
                        ],
                      ),
                      if (addons != null && addons.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                          child: Text(
                            addons.join(', '),
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total (incl. tax)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Text('\$${(order['total'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981))),
                  ],
                ),
                _buildActionButtons(order),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    if (order['status'] == 'pending') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(100, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _db.updateOrderStatus(order['id'], 'preparing'),
        child: const Text('Prepare', style: TextStyle(fontWeight: FontWeight.bold)),
      );
    } else if (order['status'] == 'preparing') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          minimumSize: const Size(100, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _db.updateOrderStatus(order['id'], 'completed'),
        child: const Text('Serve', style: TextStyle(fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          children: [
            Icon(Icons.check, color: Color(0xFF10B981), size: 14),
            SizedBox(width: 4),
            Text('Served', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      );
    }
  }
}
