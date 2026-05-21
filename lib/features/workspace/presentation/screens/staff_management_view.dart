import 'package:flutter/material.dart';
import '../../../../core/network/database_service.dart';

class StaffManagementView extends StatefulWidget {
  const StaffManagementView({super.key});

  @override
  State<StaffManagementView> createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends State<StaffManagementView> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.waiter;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    final s = await _db.getStaffList();
    if (mounted) {
      setState(() {
        _staff = s;
        _isLoading = false;
      });
    }
  }

  void _showInviteStaffDialog() {
    _nameController.clear();
    _emailController.clear();
    _selectedRole = UserRole.waiter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Invite Staff Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Staff Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Staff Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Assigned Role'),
                items: UserRole.values
                    .map((role) => DropdownMenuItem<UserRole>(
                          value: role,
                          child: Text(role.name.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => _selectedRole = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
              onPressed: () async {
                if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) {
                  await _db.inviteStaff(
                    _nameController.text.trim(),
                    _emailController.text.trim(),
                    _selectedRole,
                  );
                  Navigator.pop(context);
                  _loadStaffData();
                }
              },
              child: const Text('Send Invite'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

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
                            'Staff Directory',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontSize: 28,
                                ),
                          ),
                          Text(
                            'Invite team members, assign secure access roles, and control permission restrictions.',
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          minimumSize: const Size(140, 46),
                        ),
                        onPressed: _showInviteStaffDialog,
                        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                        label: const Text('Invite Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (isMobile) ...[
                    _buildStaffList(isDark),
                    const SizedBox(height: 24),
                    _buildPermissionsMatrix(isDark),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildStaffList(isDark)),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _buildPermissionsMatrix(isDark)),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStaffList(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Members',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _staff.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, idx) {
                final member = _staff[idx];
                final role = member['role'].toString().toLowerCase();

                Color roleColor;
                if (role == 'owner') {
                  roleColor = Colors.purple;
                } else if (role == 'manager') {
                  roleColor = Colors.blue;
                } else if (role == 'kitchen') {
                  roleColor = Colors.orange;
                } else if (role == 'waiter') {
                  roleColor = Colors.teal;
                } else {
                  roleColor = Colors.grey;
                }

                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: roleColor.withOpacity(0.12),
                      radius: 20,
                      child: Text(
                        member['name'][0].toUpperCase(),
                        style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(member['email'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsMatrix(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Access Roles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Role-based permissions restricts interface dashboard panels dynamically.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _buildPermissionRow('Owner', 'All dashboard panels (analytics, orders, menus, billing, staff, setting) and RLS data authorization bypass.'),
            const Divider(height: 24),
            _buildPermissionRow('Manager', 'Full control over menus, branch configs, table reservation approvals, and general staff directories.'),
            const Divider(height: 24),
            _buildPermissionRow('Kitchen Staff', 'Read/Write access specifically to the Realtime Kitchen order Kanban board and estimated preparing times.'),
            const Divider(height: 24),
            _buildPermissionRow('Waiter', 'Access to Table tracking maps and Waiter service order alerts.'),
            const Divider(height: 24),
            _buildPermissionRow('Cashier', 'Access to billing payments, checkout orders, and print invoices.'),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String role, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 16),
            const SizedBox(width: 8),
            Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
