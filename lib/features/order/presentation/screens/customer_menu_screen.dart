import 'package:flutter/material.dart';
import '../../../../core/network/database_service.dart';

class CustomerMenuScreen extends StatefulWidget {
  final String tableId;
  final String tableNumber;

  const CustomerMenuScreen({super.key, required this.tableId, required this.tableNumber});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  final _db = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _allItems = [];
  String? _activeCategoryId;

  final List<Map<String, dynamic>> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final cats = await _db.getCategories();
    final items = await _db.getAllMenuItems();
    if (mounted) {
      setState(() {
        _categories = cats;
        _allItems = items;
        if (cats.isNotEmpty) {
          _activeCategoryId = cats.first['id'];
        }
        _isLoading = false;
      });
    }
  }

  void _addToCart(Map<String, dynamic> item, List<String> selectedAddons) {
    setState(() {
      final existingIdx = _cart.indexWhere((x) =>
          x['item']['id'] == item['id'] &&
          _areAddonsEqual(x['selectedAddons'] as List<String>, selectedAddons));

      if (existingIdx != -1) {
        _cart[existingIdx]['quantity']++;
      } else {
        _cart.add({
          'item': item,
          'quantity': 1,
          'selectedAddons': selectedAddons,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  bool _areAddonsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var x in a) {
      if (!b.contains(x)) return false;
    }
    return true;
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var x in _cart) {
      double itemBasePrice = x['item']['price'] as double;
      double addonPriceSum = 0.0;
      for (var addon in x['selectedAddons'] as List<String>) {
        final regExp = RegExp(r'\+\$?([0-9.]+)');
        final match = regExp.firstMatch(addon);
        if (match != null) {
          addonPriceSum += double.tryParse(match.group(1) ?? '0') ?? 0.0;
        }
      }
      total += (itemBasePrice + addonPriceSum) * (x['quantity'] as int);
    }
    return total;
  }

  void _showAddonChangeModal(Map<String, dynamic> item) {
    final addons = List<String>.from(item['addons'] as List? ?? []);
    final selected = <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Outfit'),
                    ),
                  ),
                  Text(
                    '\$${(item['price'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF10B981)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item['description'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
              if (addons.isNotEmpty) ...[
                const Divider(height: 32),
                const Text('Customize Add-ons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Column(
                  children: addons.map((addon) {
                    final isSel = selected.contains(addon);
                    return CheckboxListTile(
                      title: Text(addon, style: const TextStyle(fontSize: 13)),
                      value: isSel,
                      onChanged: (val) {
                        setModalState(() {
                          if (val == true) {
                            selected.add(addon);
                          } else {
                            selected.remove(addon);
                          }
                        });
                      },
                    );
                  }).toList(),
                )
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _addToCart(item, selected);
                  Navigator.pop(context);
                },
                child: const Text('Add to Order Cart', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final double total = _calculateTotal();

          return Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Table ${widget.tableNumber} Order', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Outfit')),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(child: Text('Your order cart is empty'))
                      : ListView.separated(
                          itemCount: _cart.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, idx) {
                            final row = _cart[idx];
                            final item = row['item'];
                            final selectedAddons = row['selectedAddons'] as List<String>;
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      if (selectedAddons.isNotEmpty)
                                        Text(selectedAddons.join(', '), style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
                                      onPressed: () {
                                        setModalState(() {
                                          setState(() {
                                            if (row['quantity'] > 1) {
                                              row['quantity']--;
                                            } else {
                                              _cart.removeAt(idx);
                                            }
                                          });
                                        });
                                      },
                                    ),
                                    Text('${row['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF10B981)),
                                      onPressed: () {
                                        setModalState(() {
                                          setState(() {
                                            row['quantity']++;
                                          });
                                        });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                        ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Prep Time', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const Text('~15 mins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _cart.isEmpty
                      ? null
                      : () async {
                          final formattedItems = _cart.map((row) {
                            return {
                              'name': row['item']['name'],
                              'price': row['item']['price'] as double,
                              'quantity': row['quantity'] as int,
                              'addons': row['selectedAddons'],
                            };
                          }).toList();

                          await _db.placeCustomerOrder(
                            tableId: widget.tableId,
                            tableNumber: widget.tableNumber,
                            items: formattedItems,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            setState(() => _cart.clear());
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text('Order Placed Successfully! 🎉'),
                                content: const Text(
                                  'Your order has been pushed directly to the kitchen queue. Chefs are beginning preparation right now!',
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Back to Menu'),
                                  )
                                ],
                              ),
                            );
                          }
                        },
                  child: const Text('Place Order (Pushes to Kitchen)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredItems = _allItems.where((i) => i['category_id'] == _activeCategoryId && i['is_available'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('La Parisienne Bistro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit')),
            Text('Digital Menu - Table ${widget.tableNumber}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.room_service_outlined, color: Color(0xFF10B981)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Waiter has been summoned to your table!')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Direct Table Ordering', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Outfit')),
                  Text('Scan, Select, and Dine in Comfort', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSel = cat['id'] == _activeCategoryId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat['name'], style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                    selected: isSel,
                    onSelected: (_) {
                      setState(() => _activeCategoryId = cat['id']);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No active items in this category.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = filteredItems[idx];
                      return Card(
                        child: InkWell(
                          onTap: () => _showAddonChangeModal(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item['image_url'],
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Outfit'),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item['description'],
                                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '\$${(item['price'] as double).toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF10B981)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_rounded, color: Color(0xFF10B981), size: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _cart.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: const Color(0xFF10B981),
              onPressed: _showCartModal,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                'View Table Order (${_cart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
