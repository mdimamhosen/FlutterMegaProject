import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/network/database_service.dart';

class TableManagementView extends StatefulWidget {
  const TableManagementView({super.key});

  @override
  State<TableManagementView> createState() => _TableManagementViewState();
}

class _TableManagementViewState extends State<TableManagementView> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _tables = [];
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  Future<void> _loadTableData() async {
    final t = await _db.getTables();
    final s = await _db.getStaffList();
    if (mounted) {
      setState(() {
        _tables = t;
        _staff = s.where((member) => member['role'] == UserRole.waiter.name).toList();
        _isLoading = false;
      });
    }
  }

  void _showQrCodeModal(Map<String, dynamic> table) {
    // Construct the QR code content. Pointing to standard web route.
    // e.g. https://mega.example.com/menu/table/table-id/table-number
    final qrContent = 'https://mega-restaurant-saas.web.app/menu/table/${table['id']}/${table['number']}';

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('QR Ordering Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit')),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              // Premium Print Card Design
              Container(
                width: 260,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B).withOpacity(0.04) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Table ${table['number']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Outfit', color: Color(0xFF10B981)),
                    ),
                    const SizedBox(height: 4),
                    const Text('LA PARISIENNE BISTRO', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: qrContent,
                        version: QrVersions.auto,
                        size: 160.0,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, size: 16, color: Color(0xFF10B981)),
                        SizedBox(width: 8),
                        Text('Scan to browse menu & order', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(42)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulated Print triggered.')));
                      },
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Print Card'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(42)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloaded QR card to device downloads.')));
                      },
                      icon: const Icon(Icons.download_rounded, color: Colors.white),
                      label: const Text('Download', style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            'Table Tracking',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontSize: 28,
                                ),
                          ),
                          Text(
                            'Manage live table occupancy, assign default waiters, and generate ordering QR cards.',
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Table Grid ---
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: _tables.length,
                    itemBuilder: (context, idx) {
                      final table = _tables[idx];
                      final status = table['status'].toString().toLowerCase();

                      Color statusColor;
                      IconData statusIcon;
                      if (status == 'available') {
                        statusColor = const Color(0xFF10B981);
                        statusIcon = Icons.check_circle_outline_rounded;
                      } else if (status == 'occupied') {
                        statusColor = Colors.amber;
                        statusIcon = Icons.dining_outlined;
                      } else {
                        statusColor = Colors.blue;
                        statusIcon = Icons.bookmark_border_rounded;
                      }

                      // Find waiter name
                      final waiterId = table['waiter_id'];
                      final assignedWaiter = _staff.firstWhere((s) => s['user_id'] == waiterId, orElse: () => {});
                      final waiterName = assignedWaiter.isNotEmpty ? assignedWaiter['name'] : 'Unassigned';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                        'Table ${table['number']}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
                                      ),
                                      Text(
                                        'Capacity: ${table['capacity']} guests',
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(statusIcon, color: statusColor, size: 20),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.person_pin_rounded, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    waiterName,
                                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  DropdownButton<String>(
                                    underline: const SizedBox(),
                                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                                    hint: const Text('Waiter', style: TextStyle(fontSize: 11)),
                                    items: [
                                      const DropdownMenuItem<String>(value: 'clear', child: Text('Unassign', style: TextStyle(fontSize: 12))),
                                      ..._staff.map((w) => DropdownMenuItem<String>(
                                            value: w['user_id'],
                                            child: Text(w['name'], style: const TextStyle(fontSize: 12)),
                                          ))
                                    ],
                                    onChanged: (val) async {
                                      if (val == 'clear') {
                                        await _db.assignWaiter(table['id'], null);
                                      } else {
                                        await _db.assignWaiter(table['id'], val);
                                      }
                                      _loadTableData();
                                    },
                                  )
                                ],
                              ),
                              const Divider(height: 18),
                              Row(
                                children: [
                                  // Change Status Quick Button
                                  GestureDetector(
                                    onTap: () async {
                                      final nextStatus = status == 'available'
                                          ? 'occupied'
                                          : (status == 'occupied' ? 'reserved' : 'available');
                                      await _db.updateTableStatus(table['id'], nextStatus);
                                      _loadTableData();
                                    },
                                    child: Text(
                                      'Mark ${status == 'available' ? 'Occupied' : (status == 'occupied' ? 'Reserved' : 'Available')}',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF10B981), size: 22),
                                    onPressed: () => _showQrCodeModal(table),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
