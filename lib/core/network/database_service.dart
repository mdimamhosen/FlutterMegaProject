import 'dart:async';
import 'package:uuid/uuid.dart';

enum UserRole { owner, manager, cashier, waiter, kitchen }

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _initializeMockData();
  }

  // --- Realtime Streams ---
  final _orderStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _tableStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get ordersStream => _orderStreamController.stream;
  Stream<List<Map<String, dynamic>>> get tablesStream => _tableStreamController.stream;

  // --- In-Memory Mock Database tables ---
  final List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _restaurants = [];
  final List<Map<String, dynamic>> _branches = [];
  final List<Map<String, dynamic>> _staff = [];
  final List<Map<String, dynamic>> _menuCategories = [];
  final List<Map<String, dynamic>> _menuItems = [];
  final List<Map<String, dynamic>> _tables = [];
  final List<Map<String, dynamic>> _orders = [];
  final List<Map<String, dynamic>> _reservations = [];
  final List<Map<String, dynamic>> _billingPlans = [];

  // Active Session State
  Map<String, dynamic>? _currentUser;
  String? _currentRestaurantId;

  Map<String, dynamic>? get currentUser => _currentUser;
  String? get currentRestaurantId => _currentRestaurantId;

  void _initializeMockData() {
    final uuid = const Uuid();
    final restId = 'restaurant-mega-1';
    _currentRestaurantId = restId;

    // 1. Initial Billing Plans
    _billingPlans.addAll([
      {'id': 'plan-basic', 'name': 'Basic Plan', 'price': 29.0, 'limit_orders': 150, 'limit_staff': 3, 'limit_branches': 1},
      {'id': 'plan-pro', 'name': 'Pro Plan', 'price': 79.0, 'limit_orders': 1000, 'limit_staff': 15, 'limit_branches': 5},
      {'id': 'plan-enterprise', 'name': 'Enterprise Plan', 'price': 199.0, 'limit_orders': 999999, 'limit_staff': 99, 'limit_branches': 99},
    ]);

    // 2. Initial Restaurant
    _restaurants.add({
      'id': restId,
      'name': 'La Parisienne Bistro',
      'logo_url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
      'subscription_id': 'plan-pro',
      'subscription_status': 'active',
      'trial_ends_at': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });

    // 3. Branches
    _branches.addAll([
      {'id': 'branch-1', 'restaurant_id': restId, 'name': 'Downtown (Main)', 'address': '120 Broadway St, NY'},
      {'id': 'branch-2', 'restaurant_id': restId, 'name': 'Uptown Express', 'address': '250 Park Ave, NY'},
    ]);

    // 4. Owner & Staff Users
    _currentUser = {
      'id': 'user-owner-1',
      'restaurant_id': restId,
      'name': 'Imam Hosen',
      'email': 'owner@mega.com',
      'role': UserRole.owner.name,
    };
    _users.add(_currentUser!);

    _users.addAll([
      {'id': 'user-mgr-1', 'restaurant_id': restId, 'name': 'Sarah Connor', 'email': 'sarah@mega.com', 'role': UserRole.manager.name},
      {'id': 'user-waiter-1', 'restaurant_id': restId, 'name': 'Alex Rivera', 'email': 'alex@mega.com', 'role': UserRole.waiter.name},
      {'id': 'user-kitchen-1', 'restaurant_id': restId, 'name': 'Chef Jacques', 'email': 'jacques@mega.com', 'role': UserRole.kitchen.name},
    ]);

    // Populate Staff directory
    for (var u in _users) {
      _staff.add({
        'id': uuid.v4(),
        'restaurant_id': u['restaurant_id'],
        'user_id': u['id'],
        'name': u['name'],
        'email': u['email'],
        'role': u['role'],
        'joined_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      });
    }

    // 5. Menu Categories
    _menuCategories.addAll([
      {'id': 'cat-starters', 'restaurant_id': restId, 'name': 'Starters', 'sort_order': 0},
      {'id': 'cat-mains', 'restaurant_id': restId, 'name': 'Main Courses', 'sort_order': 1},
      {'id': 'cat-desserts', 'restaurant_id': restId, 'name': 'Desserts', 'sort_order': 2},
      {'id': 'cat-drinks', 'restaurant_id': restId, 'name': 'Drinks', 'sort_order': 3},
    ]);

    // 6. Menu Items
    _menuItems.addAll([
      {
        'id': 'item-starter-1',
        'restaurant_id': restId,
        'category_id': 'cat-starters',
        'name': 'Truffle Garlic Fries',
        'description': 'Crispy fries tossed in pure Italian white truffle oil and sea salt.',
        'price': 12.0,
        'image_url': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=300',
        'is_available': true,
        'addons': ['Extra Truffle Mayo (+1.50)', 'Parmesan Snow (+2.00)']
      },
      {
        'id': 'item-main-1',
        'restaurant_id': restId,
        'category_id': 'cat-mains',
        'name': 'Wagyu Smash Burger',
        'description': 'Double smashed Wagyu patties, aged cheddar, caramelised onions, brioche bun.',
        'price': 22.0,
        'image_url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300',
        'is_available': true,
        'addons': ['Add Thick-Cut Bacon (+3.00)', 'Gluten-Free Bun (+1.50)', 'Extra Patty (+6.00)']
      },
      {
        'id': 'item-main-2',
        'restaurant_id': restId,
        'category_id': 'cat-mains',
        'name': 'Seared Salmon Filet',
        'description': 'Crispy skin salmon, asparagus, lemon-herb butter sauce.',
        'price': 28.0,
        'image_url': 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=300',
        'is_available': true,
        'addons': ['Herb Butter Glaze (+1.00)', 'Double Asparagus (+4.00)']
      },
      {
        'id': 'item-dessert-1',
        'restaurant_id': restId,
        'category_id': 'cat-desserts',
        'name': 'Molten Lava Cake',
        'description': 'Rich dark chocolate cake with a warm flowing liquid core, vanilla bean gelato.',
        'price': 10.0,
        'image_url': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=300',
        'is_available': true,
        'addons': ['Extra Gelato scoop (+2.50)']
      },
      {
        'id': 'item-drink-1',
        'restaurant_id': restId,
        'category_id': 'cat-drinks',
        'name': 'Passionfruit Mojito',
        'description': 'Fresh mint, lime, white rum, premium passionfruit puree, soda splash.',
        'price': 14.0,
        'image_url': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300',
        'is_available': true,
        'addons': ['Virgin (No Alcohol) (-3.00)', 'Extra Mint (+0.50)']
      },
    ]);

    // 7. Restaurant Tables
    _tables.addAll([
      {'id': 'table-1', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-01', 'capacity': 2, 'status': 'available', 'waiter_id': 'user-waiter-1'},
      {'id': 'table-2', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-02', 'capacity': 4, 'status': 'occupied', 'waiter_id': 'user-waiter-1'},
      {'id': 'table-3', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-03', 'capacity': 6, 'status': 'reserved', 'waiter_id': 'user-waiter-1'},
      {'id': 'table-4', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-04', 'capacity': 4, 'status': 'available', 'waiter_id': null},
      {'id': 'table-5', 'restaurant_id': restId, 'branch_id': 'branch-2', 'number': 'T-05', 'capacity': 2, 'status': 'available', 'waiter_id': null},
    ]);

    // 8. Orders (Initial)
    _orders.addAll([
      {
        'id': 'order-1',
        'restaurant_id': restId,
        'table_id': 'table-2',
        'table_number': 'T-02',
        'items': [
          {'name': 'Wagyu Smash Burger', 'price': 22.0, 'quantity': 2, 'addons': ['Add Thick-Cut Bacon (+3.00)']},
          {'name': 'Passionfruit Mojito', 'price': 14.0, 'quantity': 2, 'addons': []}
        ],
        'total': 78.0,
        'status': 'preparing',
        'created_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        'estimated_minutes': 20,
      },
      {
        'id': 'order-2',
        'restaurant_id': restId,
        'table_id': 'table-3',
        'table_number': 'T-03',
        'items': [
          {'name': 'Seared Salmon Filet', 'price': 28.0, 'quantity': 1, 'addons': []},
          {'name': 'Truffle Garlic Fries', 'price': 12.0, 'quantity': 1, 'addons': ['Parmesan Snow (+2.00)']}
        ],
        'total': 42.0,
        'status': 'pending',
        'created_at': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
        'estimated_minutes': 15,
      }
    ]);

    // 9. Reservations
    _reservations.addAll([
      {
        'id': 'res-1',
        'restaurant_id': restId,
        'customer_name': 'Sophia Loren',
        'customer_phone': '+1 (555) 234-5678',
        'guests': 4,
        'date': DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10),
        'time': '19:30',
        'status': 'pending',
        'notes': 'Gluten allergy at table.',
      },
      {
        'id': 'res-2',
        'restaurant_id': restId,
        'customer_name': 'Marcus Aurelius',
        'customer_phone': '+1 (555) 987-6543',
        'guests': 2,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'time': '20:00',
        'status': 'approved',
        'notes': 'Quiet corner table preferred.',
      }
    ]);

    // Publish initial lists to streams
    _triggerOrderUpdate();
    _triggerTableUpdate();
  }

  void _triggerOrderUpdate() {
    final filtered = _orders.where((o) => o['restaurant_id'] == _currentRestaurantId).toList();
    _orderStreamController.add(List.from(filtered));
  }

  void _triggerTableUpdate() {
    final filtered = _tables.where((t) => t['restaurant_id'] == _currentRestaurantId).toList();
    _tableStreamController.add(List.from(filtered));
  }

  // --- API Authentication CRUD ---
  Future<Map<String, dynamic>?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate roundtrip
    final found = _users.firstWhere(
      (u) => u['email'].toString().toLowerCase() == email.trim().toLowerCase(),
      orElse: () => {},
    );

    if (found.isEmpty) {
      throw Exception('Invalid email or password.');
    }

    _currentUser = found;
    _currentRestaurantId = found['restaurant_id'];
    _triggerOrderUpdate();
    _triggerTableUpdate();
    return _currentUser;
  }

  Future<Map<String, dynamic>> registerOwner({
    required String name,
    required String email,
    required String password,
    required String restaurantName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final existing = _users.any((u) => u['email'] == email);
    if (existing) {
      throw Exception('A user with this email already exists.');
    }

    final uuid = const Uuid();
    final restId = 'restaurant-${uuid.v4()}';
    _currentRestaurantId = restId;

    // Create Restaurant
    final newRestaurant = {
      'id': restId,
      'name': restaurantName,
      'logo_url': '',
      'subscription_id': 'plan-basic',
      'subscription_status': 'trialing',
      'trial_ends_at': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
    _restaurants.add(newRestaurant);

    // Create Primary Branch
    _branches.add({
      'id': 'branch-${uuid.v4()}',
      'restaurant_id': restId,
      'name': 'Main Branch',
      'address': 'Set restaurant address in settings',
    });

    // Create User
    _currentUser = {
      'id': 'user-${uuid.v4()}',
      'restaurant_id': restId,
      'name': name,
      'email': email,
      'role': UserRole.owner.name,
    };
    _users.add(_currentUser!);

    // Add Staff Row
    _staff.add({
      'id': uuid.v4(),
      'restaurant_id': restId,
      'user_id': _currentUser!['id'],
      'name': name,
      'email': email,
      'role': UserRole.owner.name,
      'joined_at': DateTime.now().toIso8601String(),
    });

    // Seed default categories and tables for a fast trial experience
    _menuCategories.addAll([
      {'id': 'cat-star-${uuid.v4()}', 'restaurant_id': restId, 'name': 'Appetizers', 'sort_order': 0},
      {'id': 'cat-main-${uuid.v4()}', 'restaurant_id': restId, 'name': 'Entrées', 'sort_order': 1},
    ]);

    for (int i = 1; i <= 4; i++) {
      _tables.add({
        'id': 'table-$i-${uuid.v4()}',
        'restaurant_id': restId,
        'branch_id': _branches.last['id'],
        'number': 'T-0$i',
        'capacity': 4,
        'status': 'available',
        'waiter_id': null,
      });
    }

    _triggerOrderUpdate();
    _triggerTableUpdate();
    return _currentUser!;
  }

  Future<void> logout() async {
    _currentUser = null;
    _currentRestaurantId = null;
  }

  // --- Restaurant Workspace CRUD ---
  Future<Map<String, dynamic>> getRestaurantProfile() async {
    if (_currentRestaurantId == null) throw Exception('No active session.');
    return _restaurants.firstWhere((r) => r['id'] == _currentRestaurantId);
  }

  Future<void> updateRestaurantProfile(String name, String logoUrl) async {
    if (_currentRestaurantId == null) throw Exception('No active session.');
    final idx = _restaurants.indexWhere((r) => r['id'] == _currentRestaurantId);
    if (idx != -1) {
      _restaurants[idx]['name'] = name;
      _restaurants[idx]['logo_url'] = logoUrl;
    }
  }

  // --- Branch Operations ---
  Future<List<Map<String, dynamic>>> getBranches() async {
    return _branches.where((b) => b['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> createBranch(String name, String address) async {
    final uuid = const Uuid();
    _branches.add({
      'id': 'branch-${uuid.v4()}',
      'restaurant_id': _currentRestaurantId,
      'name': name,
      'address': address,
    });
  }

  // --- Staff Operations ---
  Future<List<Map<String, dynamic>>> getStaffList() async {
    return _staff.where((s) => s['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> inviteStaff(String name, String email, UserRole role) async {
    final uuid = const Uuid();
    _staff.add({
      'id': uuid.v4(),
      'restaurant_id': _currentRestaurantId,
      'user_id': 'user-invited-${uuid.v4()}',
      'name': name,
      'email': email,
      'role': role.name,
      'joined_at': DateTime.now().toIso8601String(),
    });
  }

  // --- Menu Operations ---
  Future<List<Map<String, dynamic>>> getCategories() async {
    final list = _menuCategories.where((c) => c['restaurant_id'] == _currentRestaurantId).toList();
    list.sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));
    return list;
  }

  Future<void> createCategory(String name) async {
    final uuid = const Uuid();
    final currentCount = _menuCategories.where((c) => c['restaurant_id'] == _currentRestaurantId).length;
    _menuCategories.add({
      'id': 'cat-${uuid.v4()}',
      'restaurant_id': _currentRestaurantId,
      'name': name,
      'sort_order': currentCount,
    });
  }

  Future<List<Map<String, dynamic>>> getMenuItems(String categoryId) async {
    return _menuItems.where((i) => i['restaurant_id'] == _currentRestaurantId && i['category_id'] == categoryId).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMenuItems() async {
    return _menuItems.where((i) => i['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> createMenuItem({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required List<String> addons,
  }) async {
    final uuid = const Uuid();
    _menuItems.add({
      'id': 'item-${uuid.v4()}',
      'restaurant_id': _currentRestaurantId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=300' : imageUrl,
      'is_available': true,
      'addons': addons,
    });
  }

  Future<void> toggleItemAvailability(String itemId, bool isAvailable) async {
    final idx = _menuItems.indexWhere((i) => i['id'] == itemId);
    if (idx != -1) {
      _menuItems[idx]['is_available'] = isAvailable;
    }
  }

  // --- Table Operations ---
  Future<List<Map<String, dynamic>>> getTables() async {
    return _tables.where((t) => t['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    final idx = _tables.indexWhere((t) => t['id'] == tableId);
    if (idx != -1) {
      _tables[idx]['status'] = status;
      _triggerTableUpdate();
    }
  }

  Future<void> assignWaiter(String tableId, String? waiterId) async {
    final idx = _tables.indexWhere((t) => t['id'] == tableId);
    if (idx != -1) {
      _tables[idx]['waiter_id'] = waiterId;
      _triggerTableUpdate();
    }
  }

  // --- Realtime Order Flow ---
  Future<void> placeCustomerOrder({
    required String tableId,
    required String tableNumber,
    required List<Map<String, dynamic>> items,
  }) async {
    final uuid = const Uuid();
    double total = 0.0;
    for (var item in items) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }

    final newOrder = {
      'id': 'order-${uuid.v4().substring(0, 8)}',
      'restaurant_id': _currentRestaurantId,
      'table_id': tableId,
      'table_number': tableNumber,
      'items': items,
      'total': total,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'estimated_minutes': 15,
    };

    _orders.add(newOrder);

    // Automatically set table to occupied
    final tIdx = _tables.indexWhere((t) => t['id'] == tableId);
    if (tIdx != -1) {
      _tables[tIdx]['status'] = 'occupied';
      _triggerTableUpdate();
    }

    _triggerOrderUpdate();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final idx = _orders.indexWhere((o) => o['id'] == orderId);
    if (idx != -1) {
      _orders[idx]['status'] = status;

      // If marked completed or cancelled, optionally release table
      if (status == 'completed' || status == 'served') {
        final tableId = _orders[idx]['table_id'];
        final tIdx = _tables.indexWhere((t) => t['id'] == tableId);
        if (tIdx != -1) {
          _tables[tIdx]['status'] = 'available';
          _triggerTableUpdate();
        }
      }

      _triggerOrderUpdate();
    }
  }

  // --- Reservations ---
  Future<List<Map<String, dynamic>>> getReservations() async {
    return _reservations.where((r) => r['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> createReservation({
    required String customerName,
    required String customerPhone,
    required int guests,
    required String date,
    required String time,
    required String notes,
  }) async {
    final uuid = const Uuid();
    _reservations.add({
      'id': 'res-${uuid.v4()}',
      'restaurant_id': _currentRestaurantId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'guests': guests,
      'date': date,
      'time': time,
      'status': 'pending',
      'notes': notes,
    });
  }

  Future<void> updateReservationStatus(String reservationId, String status) async {
    final idx = _reservations.indexWhere((r) => r['id'] == reservationId);
    if (idx != -1) {
      _reservations[idx]['status'] = status;
    }
  }

  // --- Billing & Analytics ---
  Future<Map<String, dynamic>> getBillingSummary() async {
    final restaurant = await getRestaurantProfile();
    final planId = restaurant['subscription_id'];
    final plan = _billingPlans.firstWhere((p) => p['id'] == planId);

    // Calculate usage
    final currentMonthStart = DateTime.now().subtract(Duration(days: DateTime.now().day - 1));
    final ordersCount = _orders.where((o) {
      final dt = DateTime.parse(o['created_at']);
      return o['restaurant_id'] == _currentRestaurantId && dt.isAfter(currentMonthStart);
    }).length;

    return {
      'plan_name': plan['name'],
      'plan_price': plan['price'],
      'limit_orders': plan['limit_orders'],
      'limit_staff': plan['limit_staff'],
      'limit_branches': plan['limit_branches'],
      'current_month_orders': ordersCount,
      'current_staff_count': _staff.where((s) => s['restaurant_id'] == _currentRestaurantId).length,
      'current_branches_count': _branches.where((b) => b['restaurant_id'] == _currentRestaurantId).length,
      'subscription_status': restaurant['subscription_status'],
      'trial_ends_at': restaurant['trial_ends_at'],
    };
  }

  Future<void> upgradePlan(String planId) async {
    final idx = _restaurants.indexWhere((r) => r['id'] == _currentRestaurantId);
    if (idx != -1) {
      _restaurants[idx]['subscription_id'] = planId;
      _restaurants[idx]['subscription_status'] = 'active';
    }
  }

  Future<Map<String, dynamic>> getAnalyticsData() async {
    final restaurantOrders = _orders.where((o) => o['restaurant_id'] == _currentRestaurantId && o['status'] != 'cancelled').toList();

    double totalRevenue = 0.0;
    Map<String, double> topFoods = {};
    Map<int, double> hourlyOrders = {};

    for (var o in restaurantOrders) {
      totalRevenue += o['total'] as double;
      final dt = DateTime.parse(o['created_at']);
      hourlyOrders[dt.hour] = (hourlyOrders[dt.hour] ?? 0.0) + (o['total'] as double);

      final itemsList = o['items'] as List;
      for (var item in itemsList) {
        final name = item['name'] as String;
        final qty = item['quantity'] as int;
        topFoods[name] = (topFoods[name] ?? 0) + qty;
      }
    }

    final topFoodsSorted = topFoods.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total_revenue': totalRevenue,
      'total_orders': restaurantOrders.length,
      'average_order_value': restaurantOrders.isEmpty ? 0.0 : totalRevenue / restaurantOrders.length,
      'top_foods': topFoodsSorted.take(4).map((e) => {'name': e.key, 'quantity': e.value.toInt()}).toList(),
      'hourly_distribution': hourlyOrders.entries.map((e) => {'hour': e.key, 'value': e.value}).toList(),
      'branch_performance': [
        {'branch_name': 'Downtown (Main)', 'revenue': totalRevenue * 0.7, 'orders': (restaurantOrders.length * 0.7).toInt()},
        {'branch_name': 'Uptown Express', 'revenue': totalRevenue * 0.3, 'orders': (restaurantOrders.length * 0.3).toInt()},
      ]
    };
  }
}
