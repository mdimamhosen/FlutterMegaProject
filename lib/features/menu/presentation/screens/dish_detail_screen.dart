import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/database_service.dart';

class DishDetailScreen extends StatefulWidget {
  final String dishId;
  const DishDetailScreen({super.key, required this.dishId});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  final _db = DatabaseService();
  Map<String, dynamic>? _item;
  bool _isLoading = true;
  final List<String> _selectedAddons = [];

  @override
  void initState() {
    super.initState();
    _loadItemDetails();
  }

  Future<void> _loadItemDetails() async {
    final list = await _db.getMenuItems();
    final match = list.firstWhere(
      (itm) => itm['id'] == widget.dishId,
      orElse: () => {},
    );
    if (mounted) {
      setState(() {
        if (match.isNotEmpty) {
          _item = match;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = size.width < 900;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_item == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Specialty plate not found.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/dishes'),
                child: const Text('Back to specialties'),
              ),
            ],
          ),
        ),
      );
    }

    final item = _item!;
    final addons = item['addons'] as List? ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: isMobile ? 120 : 160,
              bottom: 40,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF090D16)]
                    : [const Color(0xFFEEF2F6), const Color(0xFFF8FAFC)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/dishes'),
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF8B5CF6)),
                      label: const Text('Back to specialties catalog', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            color: isDark ? const Color(0xFF0D131F) : Colors.white,
            width: double.infinity,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: isMobile
                    ? Column(
                        children: [
                          _buildImageCard(item, isDark),
                          const SizedBox(height: 32),
                          _buildInfoSection(item, addons, isDark),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildImageCard(item, isDark)),
                          const SizedBox(width: 48),
                          Expanded(flex: 6, child: _buildInfoSection(item, addons, isDark)),
                        ],
                      ),
              ),
            ),
          ),
          _buildMiniFooter(isDark),
        ],
      ),
    );
  }

  Widget _buildImageCard(Map<String, dynamic> item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 5,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: AspectRatio(
          aspectRatio: 1.1,
          child: Image.network(
            item['image_url'],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.restaurant_rounded, color: Colors.white24, size: 80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> item, List addons, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.black,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${item['price'].toInt()}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.black,
                color: Color(0xFF10B981),
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...List.generate(5, (_) => const Icon(Icons.star, color: Colors.amber, size: 18)),
            const SizedBox(width: 8),
            Text(
              '(4.9 from 120 ratings)',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        const Divider(height: 32),
        Text(
          item['description'],
          style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 24),
        const Text(
          'Micro-Nutrition scorecard',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.25,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildNutriTile('Calories', '480 kcal', isDark),
            _buildNutriTile('Protein', '24g', isDark),
            _buildNutriTile('Carbs', '42g', isDark),
            _buildNutriTile('Fats', '18g', isDark),
          ],
        ),
        if (addons.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Simulate Plate Customization',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 12),
          Column(
            children: addons.map((add) {
              final isChecked = _selectedAddons.contains(add);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(add.toString(), style: const TextStyle(fontSize: 13)),
                value: isChecked,
                activeColor: const Color(0xFF8B5CF6),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedAddons.add(add.toString());
                    } else {
                      _selectedAddons.remove(add.toString());
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chef recommendation: Pair this specialty item with premium dry wine and roasted root vegetables.',
                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 12, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Simulation payload generated! Scan a table QR-Code to place actual realtime kitchen orders.',
                ),
              ),
            );
          },
          child: const Text('Try Simulated Customization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildNutriTile(String label, String value, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.04) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Outfit')),
        ],
      ),
    );
  }

  Widget _buildMiniFooter(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      color: isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A),
      child: const Center(
        child: Text(
          'MEGA Plate Inspector. Complete visual details active.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
