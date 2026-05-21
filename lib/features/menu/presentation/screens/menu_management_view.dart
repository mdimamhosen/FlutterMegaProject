import 'package:flutter/material.dart';
import '../../../../core/network/database_service.dart';

class MenuManagementView extends StatefulWidget {
  const MenuManagementView({super.key});

  @override
  State<MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<MenuManagementView> {
  final _db = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _items = [];
  String? _selectedCategoryId;

  // New Category controllers
  final _catNameController = TextEditingController();

  // New Item controllers
  final _itemNameController = TextEditingController();
  final _itemDescController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemImageController = TextEditingController();
  final _itemAddonsController = TextEditingController(); // Comma-separated list

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    setState(() => _isLoading = true);
    final cats = await _db.getCategories();
    if (cats.isNotEmpty) {
      _selectedCategoryId ??= cats.first['id'];
      final items = await _db.getMenuItems(_selectedCategoryId!);
      setState(() {
        _categories = cats;
        _items = items;
        _isLoading = false;
      });
    } else {
      setState(() {
        _categories = [];
        _items = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCategory(String catId) async {
    setState(() {
      _selectedCategoryId = catId;
      _isLoading = true;
    });
    final items = await _db.getMenuItems(catId);
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _showAddCategoryDialog() {
    _catNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Category'),
        content: TextField(
          controller: _catNameController,
          decoration: const InputDecoration(hintText: 'e.g. Pasta, Appetizers, Soups'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            onPressed: () async {
              if (_catNameController.text.isNotEmpty) {
                await _db.createCategory(_catNameController.text.trim());
                Navigator.pop(context);
                _loadMenuData();
              }
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  void _showAddFoodItemDialog() {
    _itemNameController.clear();
    _itemDescController.clear();
    _itemPriceController.clear();
    _itemImageController.clear();
    _itemAddonsController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _itemDescController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _itemPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (\$)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _itemImageController,
                decoration: const InputDecoration(labelText: 'Image Unsplash URL (Optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _itemAddonsController,
                decoration: const InputDecoration(
                  labelText: 'Addons / Modifiers (Comma separated)',
                  hintText: 'e.g. Extra Cheese (+1.50), Bacon (+2.00)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            onPressed: () async {
              if (_itemNameController.text.isNotEmpty && _itemPriceController.text.isNotEmpty && _selectedCategoryId != null) {
                final double price = double.tryParse(_itemPriceController.text) ?? 0.0;
                final addonsText = _itemAddonsController.text.trim();
                List<String> addons = [];
                if (addonsText.isNotEmpty) {
                  addons = addonsText.split(',').map((e) => e.trim()).toList();
                }

                await _db.createMenuItem(
                  categoryId: _selectedCategoryId!,
                  name: _itemNameController.text.trim(),
                  description: _itemDescController.text.trim(),
                  price: price,
                  imageUrl: _itemImageController.text.trim(),
                  addons: addons,
                );

                Navigator.pop(context);
                _loadMenuData();
              }
            },
            child: const Text('Add Item'),
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
                      'Menu Designer',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'Outfit',
                            fontSize: 28,
                          ),
                    ),
                    Text(
                      'Manage categories, configure food item prices, addons, and stock availability.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(140, 46),
                  ),
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.playlist_add_rounded, color: Colors.white),
                  label: const Text('New Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Categories Tabs row ---
            if (_categories.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('No categories created yet. Click "New Category" above to start!'),
                ),
              )
            else ...[
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSel = cat['id'] == _selectedCategoryId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ChoiceChip(
                        label: Text(cat['name'], style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selected: isSel,
                        onSelected: (_) => _selectCategory(cat['id']),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // --- Food items list / Action bar ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Food & Drink Items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      minimumSize: const Size(130, 36),
                    ),
                    onPressed: _showAddFoodItemDialog,
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    label: const Text('Add Food', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_items.isEmpty)
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B).withOpacity(0.02) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  child: const Center(
                    child: Text('No food items in this category yet. Click "Add Food" to add one!'),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, idx) {
                    final item = _items[idx];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item['image_url'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey, width: 80, height: 80, child: const Icon(Icons.fastfood)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item['description'],
                                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${(item['price'] as double).toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF10B981)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Switch(
                                  value: item['is_available'] as bool,
                                  onChanged: (val) async {
                                    await _db.toggleItemAvailability(item['id'], val);
                                    _loadMenuData();
                                  },
                                ),
                                Text(
                                  item['is_available'] as bool ? 'In Stock' : 'Out of Stock',
                                  style: TextStyle(fontSize: 9, color: item['is_available'] as bool ? const Color(0xFF10B981) : Colors.red, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ]
          ],
        ),
      ),
    );
  }
}
