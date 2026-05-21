import 'package:flutter/material.dart';
import '../../../../core/network/database_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _db = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _branches = [];

  final _nameController = TextEditingController();
  final _logoController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _branchAddrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettingsData();
  }

  Future<void> _loadSettingsData() async {
    final p = await _db.getRestaurantProfile();
    final b = await _db.getBranches();
    if (mounted) {
      setState(() {
        _profile = p;
        _branches = b;
        _nameController.text = p['name'];
        _logoController.text = p['logo_url'];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    setState(() => _isLoading = true);
    await _db.updateRestaurantProfile(_nameController.text.trim(), _logoController.text.trim());
    await _loadSettingsData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restaurant profile updated successfully!')),
      );
    }
  }

  void _showAddBranchDialog() {
    _branchNameController.clear();
    _branchAddrController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Branch Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _branchNameController,
              decoration: const InputDecoration(labelText: 'Branch Name', hintText: 'e.g. Westside Diner'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _branchAddrController,
              decoration: const InputDecoration(labelText: 'Branch Address', hintText: 'e.g. 500 West Ave, NY'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            onPressed: () async {
              if (_branchNameController.text.isNotEmpty && _branchAddrController.text.isNotEmpty) {
                await _db.createBranch(_branchNameController.text.trim(), _branchAddrController.text.trim());
                Navigator.pop(context);
                _loadSettingsData();
              }
            },
            child: const Text('Add Branch'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

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
                      'Workspace Settings',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'Outfit',
                            fontSize: 28,
                          ),
                    ),
                    Text(
                      'Configure your business branding, logo details, and register multiple branch locations.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (isMobile) ...[
              _buildProfileForm(isDark),
              const SizedBox(height: 24),
              _buildBranchesList(isDark),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildProfileForm(isDark)),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: _buildBranchesList(isDark)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restaurant Metadata',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 20),
            Text('Brand Name', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'e.g. La Bella Vita'),
            ),
            const SizedBox(height: 18),
            Text('Logo Image URL', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 6),
            TextField(
              controller: _logoController,
              decoration: const InputDecoration(
                hintText: 'e.g. https://domain.com/logo.png',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSaveProfile,
              child: const Text('Save Branding Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesList(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Branches Locations',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
                ),
                IconButton(
                  icon: const Icon(Icons.add_location_alt_rounded, color: Color(0xFF10B981)),
                  onPressed: _showAddBranchDialog,
                )
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _branches.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, idx) {
                final b = _branches[idx];
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(b['address'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
