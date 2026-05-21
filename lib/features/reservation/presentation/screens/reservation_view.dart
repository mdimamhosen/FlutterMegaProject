import 'package:flutter/material.dart';
import '../../../../core/network/database_service.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  final _db = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _reservations = [];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guestsController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final r = await _db.getReservations();
    if (mounted) {
      setState(() {
        _reservations = r;
        _isLoading = false;
      });
    }
  }

  void _showAddBookingDialog() {
    _nameController.clear();
    _phoneController.clear();
    _guestsController.text = '2';
    _dateController.text = DateTime.now().toIso8601String().substring(0, 10);
    _timeController.text = '19:00';
    _notesController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reservation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Customer Name')),
              const SizedBox(height: 12),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Customer Phone')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _guestsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Guests Count'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _timeController,
                      decoration: const InputDecoration(labelText: 'Time (e.g. 19:30)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', prefixIcon: Icon(Icons.date_range)),
              ),
              const SizedBox(height: 12),
              TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Special Notes')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            onPressed: () async {
              if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                await _db.createReservation(
                  customerName: _nameController.text.trim(),
                  customerPhone: _phoneController.text.trim(),
                  guests: int.tryParse(_guestsController.text) ?? 2,
                  date: _dateController.text.trim(),
                  time: _timeController.text.trim(),
                  notes: _notesController.text.trim(),
                );
                Navigator.pop(context);
                _loadReservations();
              }
            },
            child: const Text('Book Table'),
          )
        ],
      ),
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
                            'Table Bookings',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontSize: 28,
                                ),
                          ),
                          Text(
                            'Monitor customer table bookings, approve requests, and manage active dining slots.',
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          minimumSize: const Size(140, 46),
                        ),
                        onPressed: _showAddBookingDialog,
                        icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white),
                        label: const Text('New Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_reservations.isEmpty)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No reservation requests found. Add one manually or wait for online scans!'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reservations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, idx) {
                        final res = _reservations[idx];
                        final status = res['status'].toString().toLowerCase();

                        Color statusColor;
                        String statusLabel;
                        if (status == 'pending') {
                          statusColor = Colors.amber;
                          statusLabel = 'Pending Review';
                        } else if (status == 'approved') {
                          statusColor = const Color(0xFF10B981);
                          statusLabel = 'Approved & Seated';
                        } else {
                          statusColor = Colors.red;
                          statusLabel = 'Declined';
                        }

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    status == 'approved'
                                        ? Icons.check_circle_rounded
                                        : (status == 'declined' ? Icons.cancel_rounded : Icons.pending_rounded),
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            res['customer_name'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${res['guests']} Guests',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 12, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(res['customer_phone'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.schedule, size: 12, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text('${res['date']} at ${res['time']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                      if (res['notes'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Notes: "${res['notes']}"',
                                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 12),
                                        )
                                      ]
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                    if (status == 'pending') ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () async {
                                              await _db.updateReservationStatus(res['id'], 'rejected');
                                              _loadReservations();
                                            },
                                            child: const Text('Decline', style: TextStyle(color: Colors.red, fontSize: 12)),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF10B981),
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(80, 32),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () async {
                                              await _db.updateReservationStatus(res['id'], 'approved');
                                              _loadReservations();
                                            },
                                            child: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      )
                                    ]
                                  ],
                                )
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
