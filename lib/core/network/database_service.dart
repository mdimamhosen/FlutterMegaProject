import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { owner, manager, cashier, waiter, kitchen }

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _initializeMockData();
    if (isFirebaseAvailable) {
      _setupFirebaseListeners();
    }
  }

  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  final _orderStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _tableStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get ordersStream => _orderStreamController.stream;
  Stream<List<Map<String, dynamic>>> get tablesStream => _tableStreamController.stream;

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

  Map<String, dynamic>? _currentUser;
  String? _currentRestaurantId;

  Map<String, dynamic>? get currentUser => _currentUser;
  String? get currentRestaurantId => _currentRestaurantId;

  void _setupFirebaseListeners() {
    FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((o) => o['restaurant_id'] == _currentRestaurantId).toList();
      _orderStreamController.add(list);
    });

    FirebaseFirestore.instance
        .collection('tables')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((t) => t['restaurant_id'] == _currentRestaurantId).toList();
      _tableStreamController.add(list);
    });
  }

  void _initializeMockData() {
    final uuid = const Uuid();
    final restId = 'restaurant-mega-1';
    _currentRestaurantId = restId;

    _billingPlans.addAll([
      {'id': 'plan-basic', 'name': 'Basic Plan', 'price': 29.0, 'limit_orders': 150, 'limit_staff': 3, 'limit_branches': 1},
      {'id': 'plan-pro', 'name': 'Pro Plan', 'price': 79.0, 'limit_orders': 1000, 'limit_staff': 15, 'limit_branches': 5},
      {'id': 'plan-enterprise', 'name': 'Enterprise Plan', 'price': 199.0, 'limit_orders': 999999, 'limit_staff': 99, 'limit_branches': 99},
    ]);

    _restaurants.add({
      'id': restId,
      'name': 'La Parisienne Bistro',
      'logo_url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200',
      'subscription_id': 'plan-pro',
      'subscription_status': 'active',
      'trial_ends_at': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });

    _branches.addAll([
      {'id': 'branch-1', 'restaurant_id': restId, 'name': 'Downtown (Main)', 'address': '120 Broadway St, NY'},
      {'id': 'branch-2', 'restaurant_id': restId, 'name': 'Uptown Express', 'address': '250 Park Ave, NY'},
    ]);

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

    _menuCategories.addAll([
      {'id': 'cat-starters', 'restaurant_id': restId, 'name': 'Starters', 'sort_order': 0},
      {'id': 'cat-mains', 'restaurant_id': restId, 'name': 'Main Courses', 'sort_order': 1},
      {'id': 'cat-desserts', 'restaurant_id': restId, 'name': 'Desserts', 'sort_order': 2},
      {'id': 'cat-drinks', 'restaurant_id': restId, 'name': 'Drinks', 'sort_order': 3},
    ]);

    _menuItems.addAll([
      {
        'id': 'item-starter-1',
        'restaurant_id': restId,
        'category_id': 'cat-starters',
        'name': 'Truffle Garlic Fries',
        'description': 'Crispy fries tossed in pure Italian white truffle oil and sea salt.',
        'price': 12.0,
        'image_url': 'premium_truffle_fries.png',
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
        'image_url': 'premium_wagyu_steak.png',
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
        'image_url': 'premium_chef_kitchen.png',
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
        'image_url': 'premium_chocolate_lava.png',
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
        'image_url': 'premium_mojito_cocktail.png',
        'is_available': true,
        'addons': ['Virgin (No Alcohol) (-3.00)', 'Extra Mint (+0.50)']
      },
    ]);

    _tables.addAll([
      {'id': 'table-1', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-01', 'capacity': 2, 'status': 'available', 'waiter_id': 'user-waiter-1'},
      {'id': 'table-2', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-02', 'capacity': 4, 'status': 'occupied', 'waiter_id': 'user-waiter-1'},
      {'id': 'table-3', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-03', 'capacity': 6, 'status': 'reserved', 'waiter_id': 'user-waiter-1'},
      {'id': 'table-4', 'restaurant_id': restId, 'branch_id': 'branch-1', 'number': 'T-04', 'capacity': 4, 'status': 'available', 'waiter_id': null},
      {'id': 'table-5', 'restaurant_id': restId, 'branch_id': 'branch-2', 'number': 'T-05', 'capacity': 2, 'status': 'available', 'waiter_id': null},
    ]);

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

  Future<Map<String, dynamic>?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (isFirebaseAvailable) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user?.uid)
          .get();
      if (userDoc.exists) {
        _currentUser = userDoc.data();
        _currentUser!['id'] = userDoc.id;
        _currentRestaurantId = _currentUser!['restaurant_id'];
        _setupFirebaseListeners();
        return _currentUser;
      }
      throw Exception('User profile not found.');
    }

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
    if (isFirebaseAvailable) {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final restId = 'restaurant-$uid';
      _currentRestaurantId = restId;

      final newRestaurant = {
        'name': restaurantName,
        'logo_url': '',
        'subscription_id': 'plan-basic',
        'subscription_status': 'trialing',
        'trial_ends_at': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      await FirebaseFirestore.instance.collection('restaurants').doc(restId).set(newRestaurant);

      final newBranch = {
        'restaurant_id': restId,
        'name': 'Main Branch',
        'address': 'Set restaurant address in settings',
      };
      await FirebaseFirestore.instance.collection('branches').add(newBranch);

      _currentUser = {
        'restaurant_id': restId,
        'name': name,
        'email': email,
        'role': UserRole.owner.name,
      };
      await FirebaseFirestore.instance.collection('users').doc(uid).set(_currentUser!);
      _currentUser!['id'] = uid;

      final newStaff = {
        'restaurant_id': restId,
        'user_id': uid,
        'name': name,
        'email': email,
        'role': UserRole.owner.name,
        'joined_at': DateTime.now().toIso8601String(),
      };
      await FirebaseFirestore.instance.collection('staff').add(newStaff);

      final catAppetizers = {
        'restaurant_id': restId,
        'name': 'Appetizers',
        'sort_order': 0,
      };
      final catEntrees = {
        'restaurant_id': restId,
        'name': 'Entrées',
        'sort_order': 1,
      };
      await FirebaseFirestore.instance.collection('menuCategories').add(catAppetizers);
      await FirebaseFirestore.instance.collection('menuCategories').add(catEntrees);

      for (int i = 1; i <= 4; i++) {
        final newTable = {
          'restaurant_id': restId,
          'branch_id': 'branch-main',
          'number': 'T-0$i',
          'capacity': 4,
          'status': 'available',
          'waiter_id': null,
        };
        await FirebaseFirestore.instance.collection('tables').add(newTable);
      }

      _setupFirebaseListeners();
      return _currentUser!;
    }

    final existing = _users.any((u) => u['email'] == email);
    if (existing) {
      throw Exception('A user with this email already exists.');
    }

    final uuid = const Uuid();
    final restId = 'restaurant-${uuid.v4()}';
    _currentRestaurantId = restId;

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

    _branches.add({
      'id': 'branch-${uuid.v4()}',
      'restaurant_id': restId,
      'name': 'Main Branch',
      'address': 'Set restaurant address in settings',
    });

    _currentUser = {
      'id': 'user-${uuid.v4()}',
      'restaurant_id': restId,
      'name': name,
      'email': email,
      'role': UserRole.owner.name,
    };
    _users.add(_currentUser!);

    _staff.add({
      'id': uuid.v4(),
      'restaurant_id': restId,
      'user_id': _currentUser!['id'],
      'name': name,
      'email': email,
      'role': UserRole.owner.name,
      'joined_at': DateTime.now().toIso8601String(),
    });

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
    if (isFirebaseAvailable) {
      await FirebaseAuth.instance.signOut();
    }
    _currentUser = null;
    _currentRestaurantId = null;
  }

  Future<Map<String, dynamic>> getRestaurantProfile() async {
    if (_currentRestaurantId == null) throw Exception('No active session.');
    if (isFirebaseAvailable) {
      final doc = await FirebaseFirestore.instance.collection('restaurants').doc(_currentRestaurantId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
    }
    return _restaurants.firstWhere((r) => r['id'] == _currentRestaurantId);
  }

  Future<void> updateRestaurantProfile(String name, String logoUrl) async {
    if (_currentRestaurantId == null) throw Exception('No active session.');
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('restaurants').doc(_currentRestaurantId).update({
        'name': name,
        'logo_url': logoUrl,
      });
      return;
    }
    final idx = _restaurants.indexWhere((r) => r['id'] == _currentRestaurantId);
    if (idx != -1) {
      _restaurants[idx]['name'] = name;
      _restaurants[idx]['logo_url'] = logoUrl;
    }
  }

  Future<List<Map<String, dynamic>>> getBranches() async {
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('branches')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
    return _branches.where((b) => b['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> createBranch(String name, String address) async {
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('branches').add({
        'restaurant_id': _currentRestaurantId,
        'name': name,
        'address': address,
      });
      return;
    }
    final uuid = const Uuid();
    _branches.add({
      'id': 'branch-${uuid.v4()}',
      'restaurant_id': _currentRestaurantId,
      'name': name,
      'address': address,
    });
  }

  Future<List<Map<String, dynamic>>> getStaffList() async {
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('staff')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
    return _staff.where((s) => s['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> inviteStaff(String name, String email, UserRole role) async {
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('staff').add({
        'restaurant_id': _currentRestaurantId,
        'user_id': 'user-invited-${Uuid().v4()}',
        'name': name,
        'email': email,
        'role': role.name,
        'joined_at': DateTime.now().toIso8601String(),
      });
      return;
    }
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

  Future<List<Map<String, dynamic>>> getCategories() async {
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('menuCategories')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      list.sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));
      return list;
    }
    final list = _menuCategories.where((c) => c['restaurant_id'] == _currentRestaurantId).toList();
    list.sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));
    return list;
  }

  Future<void> createCategory(String name) async {
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('menuCategories')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      final currentCount = snapshot.docs.length;
      await FirebaseFirestore.instance.collection('menuCategories').add({
        'restaurant_id': _currentRestaurantId,
        'name': name,
        'sort_order': currentCount,
      });
      return;
    }
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
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('menuItems')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .where('category_id', isEqualTo: categoryId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
    return _menuItems.where((i) => i['restaurant_id'] == _currentRestaurantId && i['category_id'] == categoryId).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMenuItems() async {
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('menuItems')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
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
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('menuItems').add({
        'restaurant_id': _currentRestaurantId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=300' : imageUrl,
        'is_available': true,
        'addons': addons,
      });
      return;
    }
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
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('menuItems').doc(itemId).update({
        'is_available': isAvailable,
      });
      return;
    }
    final idx = _menuItems.indexWhere((i) => i['id'] == itemId);
    if (idx != -1) {
      _menuItems[idx]['is_available'] = isAvailable;
    }
  }

  Future<List<Map<String, dynamic>>> getTables() async {
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('tables')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
    return _tables.where((t) => t['restaurant_id'] == _currentRestaurantId).toList();
  }

  Future<void> updateTableStatus(String tableId, String status) async {
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('tables').doc(tableId).update({
        'status': status,
      });
      return;
    }
    final idx = _tables.indexWhere((t) => t['id'] == tableId);
    if (idx != -1) {
      _tables[idx]['status'] = status;
      _triggerTableUpdate();
    }
  }

  Future<void> assignWaiter(String tableId, String? waiterId) async {
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('tables').doc(tableId).update({
        'waiter_id': waiterId,
      });
      return;
    }
    final idx = _tables.indexWhere((t) => t['id'] == tableId);
    if (idx != -1) {
      _tables[idx]['waiter_id'] = waiterId;
      _triggerTableUpdate();
    }
  }

  Future<void> placeCustomerOrder({
    required String tableId,
    required String tableNumber,
    required List<Map<String, dynamic>> items,
  }) async {
    double total = 0.0;
    for (var item in items) {
      total += (item['price'] as num).toDouble() * (item['quantity'] as int);
    }

    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('orders').add({
        'restaurant_id': _currentRestaurantId,
        'table_id': tableId,
        'table_number': tableNumber,
        'items': items,
        'total': total,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'estimated_minutes': 15,
      });
      await FirebaseFirestore.instance.collection('tables').doc(tableId).update({
        'status': 'occupied',
      });
      return;
    }

    final uuid = const Uuid();
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

    final tIdx = _tables.indexWhere((t) => t['id'] == tableId);
    if (tIdx != -1) {
      _tables[tIdx]['status'] = 'occupied';
      _triggerTableUpdate();
    }

    _triggerOrderUpdate();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': status,
      });
      if (status == 'completed' || status == 'served') {
        final orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final tableId = orderDoc.data()!['table_id'];
          await FirebaseFirestore.instance.collection('tables').doc(tableId).update({
            'status': 'available',
          });
        }
      }
      return;
    }

    final idx = _orders.indexWhere((o) => o['id'] == orderId);
    if (idx != -1) {
      _orders[idx]['status'] = status;

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

  Future<List<Map<String, dynamic>>> getReservations() async {
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
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
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('reservations').add({
        'restaurant_id': _currentRestaurantId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'guests': guests,
        'date': date,
        'time': time,
        'status': 'pending',
        'notes': notes,
      });
      return;
    }
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
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('reservations').doc(reservationId).update({
        'status': status,
      });
      return;
    }
    final idx = _reservations.indexWhere((r) => r['id'] == reservationId);
    if (idx != -1) {
      _reservations[idx]['status'] = status;
    }
  }

  Future<Map<String, dynamic>> getBillingSummary() async {
    final restaurant = await getRestaurantProfile();
    final planId = restaurant['subscription_id'];
    final plan = _billingPlans.firstWhere((p) => p['id'] == planId);

    int ordersCount = 0;
    int staffCount = 0;
    int branchesCount = 0;

    if (isFirebaseAvailable) {
      final currentMonthStart = DateTime.now().subtract(Duration(days: DateTime.now().day - 1));
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      ordersCount = ordersSnapshot.docs.where((doc) {
        final dt = DateTime.parse(doc.data()['created_at']);
        return dt.isAfter(currentMonthStart);
      }).length;

      final staffSnapshot = await FirebaseFirestore.instance
          .collection('staff')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      staffCount = staffSnapshot.docs.length;

      final branchesSnapshot = await FirebaseFirestore.instance
          .collection('branches')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      branchesCount = branchesSnapshot.docs.length;
    } else {
      final currentMonthStart = DateTime.now().subtract(Duration(days: DateTime.now().day - 1));
      ordersCount = _orders.where((o) {
        final dt = DateTime.parse(o['created_at']);
        return o['restaurant_id'] == _currentRestaurantId && dt.isAfter(currentMonthStart);
      }).length;
      staffCount = _staff.where((s) => s['restaurant_id'] == _currentRestaurantId).length;
      branchesCount = _branches.where((b) => b['restaurant_id'] == _currentRestaurantId).length;
    }

    return {
      'plan_name': plan['name'],
      'plan_price': plan['price'],
      'limit_orders': plan['limit_orders'],
      'limit_staff': plan['limit_staff'],
      'limit_branches': plan['limit_branches'],
      'current_month_orders': ordersCount,
      'current_staff_count': staffCount,
      'current_branches_count': branchesCount,
      'subscription_status': restaurant['subscription_status'],
      'trial_ends_at': restaurant['trial_ends_at'],
    };
  }

  Future<void> upgradePlan(String planId) async {
    if (isFirebaseAvailable) {
      await FirebaseFirestore.instance.collection('restaurants').doc(_currentRestaurantId).update({
        'subscription_id': planId,
        'subscription_status': 'active',
      });
      return;
    }
    final idx = _restaurants.indexWhere((r) => r['id'] == _currentRestaurantId);
    if (idx != -1) {
      _restaurants[idx]['subscription_id'] = planId;
      _restaurants[idx]['subscription_status'] = 'active';
    }
  }

  Future<Map<String, dynamic>> getAnalyticsData() async {
    List<Map<String, dynamic>> restaurantOrders = [];
    if (isFirebaseAvailable) {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('restaurant_id', isEqualTo: _currentRestaurantId)
          .get();
      restaurantOrders = snapshot.docs
          .map((doc) => doc.data())
          .where((o) => o['status'] != 'cancelled')
          .toList();
    } else {
      restaurantOrders = _orders
          .where((o) => o['restaurant_id'] == _currentRestaurantId && o['status'] != 'cancelled')
          .toList();
    }

    double totalRevenue = 0.0;
    Map<String, double> topFoods = {};
    Map<int, double> hourlyOrders = {};

    for (var o in restaurantOrders) {
      totalRevenue += (o['total'] as num).toDouble();
      final dt = DateTime.parse(o['created_at']);
      hourlyOrders[dt.hour] = (hourlyOrders[dt.hour] ?? 0.0) + (o['total'] as num).toDouble();

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
