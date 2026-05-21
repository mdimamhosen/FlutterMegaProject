import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/database_service.dart';

class PublicDishesScreen extends StatefulWidget {
  const PublicDishesScreen({super.key});

  @override
  State<PublicDishesScreen> createState() => _PublicDishesScreenState();
}

class _PublicDishesScreenState extends State<PublicDishesScreen> {
  final _db = DatabaseService();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    final list = await _db.getAllMenuItems();
    if (mounted) {
      setState(() {
        _items = list;
        _filteredItems = list;
        _isLoading = false;
      });
    }
  }

  void _applyFilter(String catId, String query) {
    setState(() {
      _selectedCategory = catId;
      _searchQuery = query;
      _filteredItems = _items.where((itm) {
        final matchesCat = catId == 'all' || itm['category_id'] == catId;
        final matchesQuery = itm['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            itm['description'].toString().toLowerCase().contains(query.toLowerCase());
        return matchesCat && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = size.width < 900;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: isMobile ? 120 : 160,
              bottom: 60,
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
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Text(
                      'Specialty Menu Catalog',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Outfit',
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore our gourmet creations prepared by award-winning chefs using premium local ingredients.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
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
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF131A26) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                                  ),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: 'Search dishes, ingredients, starters...',
                                      prefixIcon: Icon(Icons.search_rounded),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    onChanged: (val) => _applyFilter(_selectedCategory, val),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildCategoryPill('All creations', 'all', isDark),
                                _buildCategoryPill('Starters', 'cat-starters', isDark),
                                _buildCategoryPill('Main Courses', 'cat-mains', isDark),
                                _buildCategoryPill('Desserts', 'cat-desserts', isDark),
                                _buildCategoryPill('Drinks', 'cat-drinks', isDark),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _filteredItems.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Text(
                                      'No specialties found matching criteria.',
                                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isMobile ? 1 : 3,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    childAspectRatio: isMobile ? 1.05 : 0.88,
                                  ),
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, idx) {
                                    final item = _filteredItems[idx];
                                    return _buildDishCard(context, item, isDark);
                                  },
                                ),
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

  Widget _buildCategoryPill(String label, String catId, bool isDark) {
    final isActive = _selectedCategory == catId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Outfit')),
        selected: isActive,
        onSelected: (val) => _applyFilter(catId, _searchQuery),
        selectedColor: const Color(0xFF8B5CF6),
        labelStyle: TextStyle(color: isActive ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700])),
        backgroundColor: isDark ? const Color(0xFF1E293B).withOpacity(0.04) : Colors.grey[100],
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, Map<String, dynamic> item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A26) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Image.network(
                item['image_url'],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.restaurant_rounded, color: Colors.white24, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${item['price'].toInt()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['description'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => context.go('/dishes/${item['id']}'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Inspect Dish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
          'MEGA Digital Gastronomy Services. Clean code pipeline active.',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
